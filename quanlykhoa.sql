--
-- PostgreSQL database dump
--

\restrict gCg9nXMZ9ldwUyOuMWTFTNzm5bEvzxlvbCQMryNOnOizb80woGvgQaY6xT1v9op

-- Dumped from database version 18.0
-- Dumped by pg_dump version 18.0

-- Started on 2025-10-23 15:32:31

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 2 (class 3079 OID 16441)
-- Name: pg_trgm; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_trgm WITH SCHEMA public;


--
-- TOC entry 5260 (class 0 OID 0)
-- Dependencies: 2
-- Name: EXTENSION pg_trgm; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pg_trgm IS 'text similarity measurement and index searching based on trigrams';


--
-- TOC entry 3 (class 3079 OID 16931)
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- TOC entry 5261 (class 0 OID 0)
-- Dependencies: 3
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


--
-- TOC entry 344 (class 1255 OID 16973)
-- Name: create_user(text, text, text, text, bigint); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.create_user(p_tendangnhap text, p_plain_password text, p_hoten text, p_vaitro text, p_bophanid bigint DEFAULT NULL::bigint) RETURNS TABLE(created_id bigint)
    LANGUAGE plpgsql
    AS $_$
DECLARE
  v_count  int;
  v_hashed text;
BEGIN
  -- Kiểm tra trùng tên đăng nhập
  SELECT COUNT(*) INTO v_count
  FROM nguoidung
  WHERE lower(tendangnhap) = lower(p_tendangnhap);
  IF v_count > 0 THEN
    RAISE EXCEPTION 'Tên đăng nhập đã tồn tại: %', p_tendangnhap;
  END IF;

  -- Nếu là giảng viên: kiểm tra domain
  IF p_vaitro IS NOT NULL AND lower(p_vaitro) = 'giangvien' THEN
    IF NOT ( p_tendangnhap ~* '^[A-Za-z0-9._%+-]+@gv\.hcmunre\.edu\.vn$' ) THEN
      RAISE EXCEPTION 'Email của giảng viên phải có đuôi @gv.hcmunre.edu.vn';
    END IF;
  END IF;

  -- Mọi user: mật khẩu phải có ÍT NHẤT 1 chữ in HOA
  IF NOT ( p_plain_password ~ '.*[A-Z].*' ) THEN
    RAISE EXCEPTION 'Mật khẩu phải chứa ít nhất 1 chữ in hoa (Uppercase).';
  END IF;

  -- Băm mật khẩu bằng bcrypt
  v_hashed := crypt(p_plain_password, gen_salt('bf'));

  -- Insert KHÔNG có cột 'ngaytao'
  INSERT INTO nguoidung (tendangnhap, matkhaumahoa, hoten, vaitro, bophanid, trangthai)
  VALUES (p_tendangnhap, v_hashed, p_hoten, p_vaitro, p_bophanid, 'active')
  RETURNING id INTO created_id;

  RETURN;
END;
$_$;


ALTER FUNCTION public.create_user(p_tendangnhap text, p_plain_password text, p_hoten text, p_vaitro text, p_bophanid bigint) OWNER TO postgres;

--
-- TOC entry 342 (class 1255 OID 16928)
-- Name: fn_baocao_kpi_congviec(date, date, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fn_baocao_kpi_congviec(batdau date, ketthuc date, capdo text) RETURNS TABLE(bophanid bigint, tenbophan text, tong bigint, hoanthanh bigint, tre bigint, saphan bigint, danglam bigint, moi bigint)
    LANGUAGE plpgsql STABLE
    AS $$
BEGIN
  RETURN QUERY
  SELECT
    b.id AS bophanid,
    b.tenbophan,
    COUNT(*) FILTER (WHERE TRUE) AS tong,
    COUNT(*) FILTER (WHERE c.trangthai = 'hoanthanh') AS hoanthanh,
    COUNT(*) FILTER (WHERE c.trangthai <> 'hoanthanh' AND c.hanhoanthanh IS NOT NULL AND c.hanhoanthanh < CURRENT_DATE) AS tre,
    COUNT(*) FILTER (WHERE c.trangthai IN ('moi','danglam') AND c.hanhoanthanh IS NOT NULL
                     AND c.hanhoanthanh BETWEEN CURRENT_DATE AND CURRENT_DATE + INTERVAL '3 days') AS saphan,
    COUNT(*) FILTER (WHERE c.trangthai = 'danglam') AS danglam,
    COUNT(*) FILTER (WHERE c.trangthai = 'moi') AS moi
  FROM congviec c
  JOIN nguoidung u ON u.id = c.nguoithuchienid
  LEFT JOIN bophan b ON b.id = u.bophanid
  WHERE (batdau IS NULL OR c.hanhoanthanh IS NULL OR c.hanhoanthanh >= batdau)
    AND (ketthuc IS NULL OR c.hanhoanthanh IS NULL OR c.hanhoanthanh <= ketthuc)
    AND (
      (capdo = 'khoa'  AND (b.loaibophan = 'khoa'  OR b.id IS NULL)) OR
      (capdo = 'bomon' AND b.loaibophan = 'bomon')
    )
  GROUP BY b.id, b.tenbophan
  ORDER BY b.tenbophan NULLS LAST;
END; $$;


ALTER FUNCTION public.fn_baocao_kpi_congviec(batdau date, ketthuc date, capdo text) OWNER TO postgres;

--
-- TOC entry 343 (class 1255 OID 16929)
-- Name: fn_sinh_congviec_tu_lich(bigint, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fn_sinh_congviec_tu_lich(lichid bigint, mucdouutien_in text DEFAULT 'trungbinh'::text) RETURNS bigint
    LANGUAGE plpgsql
    AS $$
DECLARE
  l RECORD;
  cnt BIGINT := 0;
BEGIN
  SELECT * INTO l FROM lichcongtac WHERE id = lichid;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Khong tim thay lich %', lichid;
  END IF;

  -- assign cho tat ca giang vien active trong bophan cua lich (neu la ca_nhan thi bo qua)
  IF l.phamvi = 'chung' THEN
    FOR l IN
      SELECT u.id AS uid
      FROM nguoidung u
      WHERE u.trangthai = 'active' AND u.vaitro = 'giangvien'
    LOOP
      INSERT INTO congviec(tieude, nguoithuchienid, nguontao, hanhoanthanh, trangthai, mucdouutien)
      VALUES (l.tieude, l.uid, 'calendar', CAST(l.thoigianketthuc AS DATE), 'moi', COALESCE(mucdouutien_in,'trungbinh'));
      cnt := cnt + 1;
    END LOOP;
  END IF;
  RETURN cnt;
END; $$;


ALTER FUNCTION public.fn_sinh_congviec_tu_lich(lichid bigint, mucdouutien_in text) OWNER TO postgres;

--
-- TOC entry 334 (class 1255 OID 16927)
-- Name: fn_tim_kiem_vanban(text, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fn_tim_kiem_vanban(q text, loai text DEFAULT NULL::text) RETURNS TABLE(id bigint, tieude text, loaivanban text, trangthai text, diem real)
    LANGUAGE plpgsql STABLE
    AS $$
BEGIN
  RETURN QUERY
  WITH qts AS (
    SELECT
      COALESCE(
        NULLIF(to_tsvector('simple','')::text,''),  -- trick để đảm bảo type
        to_tsvector('simple','')
      ) AS dummy
  )
  SELECT v.id, v.tieude, v.loaivanban, v.trangthai,
         ts_rank(v.timkiem, COALESCE(websearch_to_tsquery('simple', q), plainto_tsquery('simple', q))) AS diem
  FROM vanban v
  WHERE (q IS NULL OR q = '' OR v.timkiem @@ COALESCE(websearch_to_tsquery('simple', q), plainto_tsquery('simple', q)))
    AND (loai IS NULL OR v.loaivanban = loai)
  ORDER BY diem DESC, v.ngaytao DESC;
END; $$;


ALTER FUNCTION public.fn_tim_kiem_vanban(q text, loai text) OWNER TO postgres;

--
-- TOC entry 329 (class 1255 OID 16969)
-- Name: fn_validate_email_domain(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fn_validate_email_domain() RETURNS trigger
    LANGUAGE plpgsql
    AS $_$
BEGIN
  IF NEW.vaitro IS NOT NULL AND lower(NEW.vaitro) = 'giangvien' THEN
    IF NOT ( NEW.tendangnhap ~* '^[A-Za-z0-9._%+-]+@gv\.hcmunre\.edu\.vn$' ) THEN
      RAISE EXCEPTION 'Email của giảng viên phải có đuôi @gv.hcmunre.edu.vn (tendangnhap=%)', NEW.tendangnhap;
    END IF;
  END IF;
  RETURN NEW;
END;
$_$;


ALTER FUNCTION public.fn_validate_email_domain() OWNER TO postgres;

--
-- TOC entry 291 (class 1255 OID 16565)
-- Name: trg_block_delete_user(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.trg_block_delete_user() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  RAISE EXCEPTION 'Khong duoc DELETE nguoidung. Hay dung soft delete: UPDATE trangthai=''xoa''';
END; $$;


ALTER FUNCTION public.trg_block_delete_user() OWNER TO postgres;

--
-- TOC entry 295 (class 1255 OID 16888)
-- Name: trg_validate_tepdinhkem_ref(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.trg_validate_tepdinhkem_ref() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE c INT;
BEGIN
  IF NEW.loaidt = 'vanban' THEN
    SELECT COUNT(*) INTO c FROM vanban WHERE id = NEW.madt;
  ELSIF NEW.loaidt = 'hosogiangday' THEN
    SELECT COUNT(*) INTO c FROM hosogiangday WHERE id = NEW.madt;
  ELSIF NEW.loaidt = 'baocao' THEN
    SELECT COUNT(*) INTO c FROM baocao WHERE id = NEW.madt;
  ELSIF NEW.loaidt = 'denghi' THEN
    SELECT COUNT(*) INTO c FROM denghi WHERE id = NEW.madt;
  ELSE
    RAISE EXCEPTION 'loaidt khong hop le: %', NEW.loaidt;
  END IF;

  IF c = 0 THEN
    RAISE EXCEPTION 'Tham chieu khong ton tai: loaidt=%, madt=%', NEW.loaidt, NEW.madt;
  END IF;

  IF NEW.kichthuoc IS NULL OR NEW.kichthuoc < 0 OR NEW.kichthuoc > 52428800 THEN
    RAISE EXCEPTION 'kichthuoc file khong hop le (toi da 50 MiB)';
  END IF;

  RETURN NEW;
END; $$;


ALTER FUNCTION public.trg_validate_tepdinhkem_ref() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 238 (class 1259 OID 16708)
-- Name: baocao; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.baocao (
    id bigint NOT NULL,
    bophanid bigint NOT NULL,
    tieude character varying(300) NOT NULL,
    noidung text,
    tepdinhkem character varying(500),
    ngaygui timestamp without time zone DEFAULT now() NOT NULL,
    trangthai character varying(20) DEFAULT 'choduyet'::character varying NOT NULL,
    CONSTRAINT ck_baocao_trangthai CHECK (((trangthai)::text = ANY ((ARRAY['choduyet'::character varying, 'daduyet'::character varying, 'tuchoi'::character varying])::text[])))
);


ALTER TABLE public.baocao OWNER TO postgres;

--
-- TOC entry 237 (class 1259 OID 16707)
-- Name: baocao_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.baocao_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.baocao_id_seq OWNER TO postgres;

--
-- TOC entry 5262 (class 0 OID 0)
-- Dependencies: 237
-- Name: baocao_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.baocao_id_seq OWNED BY public.baocao.id;


--
-- TOC entry 222 (class 1259 OID 16523)
-- Name: bophan; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.bophan (
    id bigint NOT NULL,
    tenbophan character varying(200) NOT NULL,
    loaibophan character varying(20) NOT NULL,
    bophanchaid bigint,
    CONSTRAINT ck_bophan_loaibophan CHECK (((loaibophan)::text = ANY ((ARRAY['khoa'::character varying, 'bomon'::character varying])::text[])))
);


ALTER TABLE public.bophan OWNER TO postgres;

--
-- TOC entry 221 (class 1259 OID 16522)
-- Name: bophan_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.bophan_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.bophan_id_seq OWNER TO postgres;

--
-- TOC entry 5263 (class 0 OID 0)
-- Dependencies: 221
-- Name: bophan_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.bophan_id_seq OWNED BY public.bophan.id;


--
-- TOC entry 244 (class 1259 OID 16777)
-- Name: cauhoikhaosat; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cauhoikhaosat (
    id bigint NOT NULL,
    khaosatid bigint NOT NULL,
    loaicauhoi character varying(15) NOT NULL,
    noidung text NOT NULL,
    luachon text,
    CONSTRAINT ck_cauhoikhaosat_loaicauhoi CHECK (((loaicauhoi)::text = ANY ((ARRAY['tracnghiem'::character varying, 'tuluan'::character varying])::text[])))
);


ALTER TABLE public.cauhoikhaosat OWNER TO postgres;

--
-- TOC entry 243 (class 1259 OID 16776)
-- Name: cauhoikhaosat_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.cauhoikhaosat_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.cauhoikhaosat_id_seq OWNER TO postgres;

--
-- TOC entry 5264 (class 0 OID 0)
-- Dependencies: 243
-- Name: cauhoikhaosat_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.cauhoikhaosat_id_seq OWNED BY public.cauhoikhaosat.id;


--
-- TOC entry 232 (class 1259 OID 16638)
-- Name: congviec; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.congviec (
    id bigint NOT NULL,
    tieude character varying(300) NOT NULL,
    nguoithuchienid bigint NOT NULL,
    nguontao character varying(10) NOT NULL,
    hanhoanthanh date,
    trangthai character varying(15) DEFAULT 'moi'::character varying NOT NULL,
    mucdouutien character varying(12),
    CONSTRAINT ck_congviec_mucdouutien CHECK (((mucdouutien IS NULL) OR ((mucdouutien)::text = ANY ((ARRAY['thap'::character varying, 'trungbinh'::character varying, 'cao'::character varying])::text[])))),
    CONSTRAINT ck_congviec_nguontao CHECK (((nguontao)::text = ANY ((ARRAY['calendar'::character varying, 'thuchong'::character varying])::text[]))),
    CONSTRAINT ck_congviec_trangthai CHECK (((trangthai)::text = ANY ((ARRAY['moi'::character varying, 'danglam'::character varying, 'saphan'::character varying, 'tre'::character varying, 'hoanthanh'::character varying])::text[])))
);


ALTER TABLE public.congviec OWNER TO postgres;

--
-- TOC entry 231 (class 1259 OID 16637)
-- Name: congviec_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.congviec_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.congviec_id_seq OWNER TO postgres;

--
-- TOC entry 5265 (class 0 OID 0)
-- Dependencies: 231
-- Name: congviec_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.congviec_id_seq OWNED BY public.congviec.id;


--
-- TOC entry 240 (class 1259 OID 16732)
-- Name: denghi; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.denghi (
    id bigint NOT NULL,
    nguoiguiid bigint NOT NULL,
    loaidenghi character varying(100) NOT NULL,
    noidung text,
    trangthai character varying(20) DEFAULT 'choduyet'::character varying NOT NULL,
    ngaygui timestamp without time zone DEFAULT now() NOT NULL,
    CONSTRAINT ck_denghi_trangthai CHECK (((trangthai)::text = ANY ((ARRAY['choduyet'::character varying, 'daduyet'::character varying, 'tuchoi'::character varying])::text[])))
);


ALTER TABLE public.denghi OWNER TO postgres;

--
-- TOC entry 239 (class 1259 OID 16731)
-- Name: denghi_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.denghi_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.denghi_id_seq OWNER TO postgres;

--
-- TOC entry 5266 (class 0 OID 0)
-- Dependencies: 239
-- Name: denghi_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.denghi_id_seq OWNED BY public.denghi.id;


--
-- TOC entry 234 (class 1259 OID 16661)
-- Name: hosogiangday; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.hosogiangday (
    id bigint NOT NULL,
    giangvienid bigint NOT NULL,
    tenhoso character varying(300) NOT NULL,
    loaihoso character varying(20) NOT NULL,
    trangthai character varying(20) DEFAULT 'nhap'::character varying NOT NULL,
    tepdinhkem character varying(500),
    ngaygui timestamp without time zone DEFAULT now() NOT NULL,
    CONSTRAINT ck_hosogiangday_loaihoso CHECK (((loaihoso)::text = ANY ((ARRAY['decuong'::character varying, 'giaotrinh'::character varying, 'baigiang'::character varying])::text[]))),
    CONSTRAINT ck_hosogiangday_trangthai CHECK (((trangthai)::text = ANY ((ARRAY['nhap'::character varying, 'choduyet'::character varying, 'daduyet'::character varying, 'tuchoi'::character varying])::text[])))
);


ALTER TABLE public.hosogiangday OWNER TO postgres;

--
-- TOC entry 233 (class 1259 OID 16660)
-- Name: hosogiangday_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.hosogiangday_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.hosogiangday_id_seq OWNER TO postgres;

--
-- TOC entry 5267 (class 0 OID 0)
-- Dependencies: 233
-- Name: hosogiangday_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.hosogiangday_id_seq OWNED BY public.hosogiangday.id;


--
-- TOC entry 242 (class 1259 OID 16755)
-- Name: khaosat; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.khaosat (
    id bigint NOT NULL,
    tieude character varying(300) NOT NULL,
    mota text,
    nguoitaoid bigint NOT NULL,
    trangthai character varying(15) DEFAULT 'moi'::character varying NOT NULL,
    ngaytao timestamp without time zone DEFAULT now() NOT NULL,
    CONSTRAINT ck_khaosat_trangthai CHECK (((trangthai)::text = ANY ((ARRAY['moi'::character varying, 'dangmo'::character varying, 'dong'::character varying])::text[])))
);


ALTER TABLE public.khaosat OWNER TO postgres;

--
-- TOC entry 241 (class 1259 OID 16754)
-- Name: khaosat_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.khaosat_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.khaosat_id_seq OWNER TO postgres;

--
-- TOC entry 5268 (class 0 OID 0)
-- Dependencies: 241
-- Name: khaosat_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.khaosat_id_seq OWNED BY public.khaosat.id;


--
-- TOC entry 248 (class 1259 OID 16825)
-- Name: layykien; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.layykien (
    id bigint NOT NULL,
    tieude character varying(300) NOT NULL,
    noidung text,
    nguoitaoid bigint NOT NULL,
    trangthai character varying(15) DEFAULT 'moi'::character varying NOT NULL,
    ngaytao timestamp without time zone DEFAULT now() NOT NULL,
    CONSTRAINT ck_layykien_trangthai CHECK (((trangthai)::text = ANY ((ARRAY['moi'::character varying, 'dangmo'::character varying, 'dong'::character varying])::text[])))
);


ALTER TABLE public.layykien OWNER TO postgres;

--
-- TOC entry 247 (class 1259 OID 16824)
-- Name: layykien_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.layykien_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.layykien_id_seq OWNER TO postgres;

--
-- TOC entry 5269 (class 0 OID 0)
-- Dependencies: 247
-- Name: layykien_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.layykien_id_seq OWNED BY public.layykien.id;


--
-- TOC entry 230 (class 1259 OID 16619)
-- Name: lichcongtac; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.lichcongtac (
    id bigint NOT NULL,
    phamvi character varying(10) NOT NULL,
    nguoisohuuid bigint,
    tieude character varying(300) NOT NULL,
    thoigianbatdau timestamp without time zone NOT NULL,
    thoigianketthuc timestamp without time zone NOT NULL,
    CONSTRAINT ck_lichcongtac_phamvi CHECK (((phamvi)::text = ANY ((ARRAY['chung'::character varying, 'canhan'::character varying])::text[]))),
    CONSTRAINT ck_lichcongtac_tg CHECK ((thoigianbatdau < thoigianketthuc))
);


ALTER TABLE public.lichcongtac OWNER TO postgres;

--
-- TOC entry 229 (class 1259 OID 16618)
-- Name: lichcongtac_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.lichcongtac_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.lichcongtac_id_seq OWNER TO postgres;

--
-- TOC entry 5270 (class 0 OID 0)
-- Dependencies: 229
-- Name: lichcongtac_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.lichcongtac_id_seq OWNED BY public.lichcongtac.id;


--
-- TOC entry 254 (class 1259 OID 16891)
-- Name: lichsuhethong; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.lichsuhethong (
    id bigint NOT NULL,
    nguoidungid bigint NOT NULL,
    hanhdong character varying(50) NOT NULL,
    doituong character varying(30) NOT NULL,
    madoituong bigint,
    noidung text,
    thoigian timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.lichsuhethong OWNER TO postgres;

--
-- TOC entry 253 (class 1259 OID 16890)
-- Name: lichsuhethong_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.lichsuhethong_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.lichsuhethong_id_seq OWNER TO postgres;

--
-- TOC entry 5271 (class 0 OID 0)
-- Dependencies: 253
-- Name: lichsuhethong_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.lichsuhethong_id_seq OWNED BY public.lichsuhethong.id;


--
-- TOC entry 224 (class 1259 OID 16539)
-- Name: nguoidung; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.nguoidung (
    id bigint NOT NULL,
    tendangnhap character varying(100) NOT NULL,
    matkhaumahoa character varying(255) NOT NULL,
    hoten character varying(200) NOT NULL,
    vaitro character varying(20) NOT NULL,
    bophanid bigint,
    trangthai character varying(20) DEFAULT 'active'::character varying NOT NULL,
    CONSTRAINT ck_nguoidung_trangthai CHECK (((trangthai)::text = ANY ((ARRAY['active'::character varying, 'tamngung'::character varying, 'xoa'::character varying])::text[]))),
    CONSTRAINT ck_nguoidung_vaitro CHECK (((vaitro)::text = ANY ((ARRAY['truongkhoa'::character varying, 'truongbomon'::character varying, 'giangvien'::character varying])::text[])))
);


ALTER TABLE public.nguoidung OWNER TO postgres;

--
-- TOC entry 223 (class 1259 OID 16538)
-- Name: nguoidung_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.nguoidung_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.nguoidung_id_seq OWNER TO postgres;

--
-- TOC entry 5272 (class 0 OID 0)
-- Dependencies: 223
-- Name: nguoidung_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.nguoidung_id_seq OWNED BY public.nguoidung.id;


--
-- TOC entry 228 (class 1259 OID 16597)
-- Name: pheduyet; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.pheduyet (
    id bigint NOT NULL,
    loaithucthe character varying(30) NOT NULL,
    mathucthe bigint NOT NULL,
    buoc character varying(10) NOT NULL,
    nguoipheduyetid bigint NOT NULL,
    quyetdinh character varying(10),
    ghichu text,
    ngayduyet timestamp without time zone,
    CONSTRAINT ck_pheduyet_buoc CHECK (((buoc)::text = ANY ((ARRAY['tbm'::character varying, 'tk'::character varying])::text[]))),
    CONSTRAINT ck_pheduyet_loaithucthe CHECK (((loaithucthe)::text = ANY ((ARRAY['vanban'::character varying, 'hosogiangday'::character varying, 'denghi'::character varying, 'baocao'::character varying])::text[]))),
    CONSTRAINT ck_pheduyet_quyetdinh CHECK (((quyetdinh IS NULL) OR ((quyetdinh)::text = ANY ((ARRAY['approve'::character varying, 'reject'::character varying])::text[]))))
);


ALTER TABLE public.pheduyet OWNER TO postgres;

--
-- TOC entry 227 (class 1259 OID 16596)
-- Name: pheduyet_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.pheduyet_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.pheduyet_id_seq OWNER TO postgres;

--
-- TOC entry 5273 (class 0 OID 0)
-- Dependencies: 227
-- Name: pheduyet_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.pheduyet_id_seq OWNED BY public.pheduyet.id;


--
-- TOC entry 236 (class 1259 OID 16685)
-- Name: tailieugiangday; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tailieugiangday (
    id bigint NOT NULL,
    tentailieu character varying(300) NOT NULL,
    loaitailieu character varying(20) NOT NULL,
    tinhtrang character varying(20) NOT NULL,
    tepdinhkem character varying(500),
    nguoitaoid bigint NOT NULL,
    ngaytao timestamp without time zone DEFAULT now() NOT NULL,
    CONSTRAINT ck_tailieugiangday_loaitailieu CHECK (((loaitailieu)::text = ANY ((ARRAY['decuong'::character varying, 'giaotrinh'::character varying, 'ebook'::character varying])::text[]))),
    CONSTRAINT ck_tailieugiangday_tinhtrang CHECK (((tinhtrang)::text = ANY ((ARRAY['danghiemthu'::character varying, 'chuanghiemthu'::character varying])::text[])))
);


ALTER TABLE public.tailieugiangday OWNER TO postgres;

--
-- TOC entry 235 (class 1259 OID 16684)
-- Name: tailieugiangday_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tailieugiangday_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.tailieugiangday_id_seq OWNER TO postgres;

--
-- TOC entry 5274 (class 0 OID 0)
-- Dependencies: 235
-- Name: tailieugiangday_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tailieugiangday_id_seq OWNED BY public.tailieugiangday.id;


--
-- TOC entry 252 (class 1259 OID 16872)
-- Name: tepdinhkem; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tepdinhkem (
    id bigint NOT NULL,
    loaidt character varying(20) NOT NULL,
    madt bigint NOT NULL,
    duongdantep character varying(500) NOT NULL,
    tengoc character varying(200) NOT NULL,
    kichthuoc bigint NOT NULL,
    CONSTRAINT ck_tepdinhkem_kichthuoc CHECK (((kichthuoc >= 0) AND (kichthuoc <= 52428800))),
    CONSTRAINT ck_tepdinhkem_loaidt CHECK (((loaidt)::text = ANY ((ARRAY['vanban'::character varying, 'hosogiangday'::character varying, 'baocao'::character varying, 'denghi'::character varying])::text[])))
);


ALTER TABLE public.tepdinhkem OWNER TO postgres;

--
-- TOC entry 251 (class 1259 OID 16871)
-- Name: tepdinhkem_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tepdinhkem_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.tepdinhkem_id_seq OWNER TO postgres;

--
-- TOC entry 5275 (class 0 OID 0)
-- Dependencies: 251
-- Name: tepdinhkem_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tepdinhkem_id_seq OWNED BY public.tepdinhkem.id;


--
-- TOC entry 246 (class 1259 OID 16796)
-- Name: traloikhaosat; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.traloikhaosat (
    id bigint NOT NULL,
    khaosatid bigint NOT NULL,
    cauhoiid bigint NOT NULL,
    nguoitraloiid bigint NOT NULL,
    giatritraloi text NOT NULL
);


ALTER TABLE public.traloikhaosat OWNER TO postgres;

--
-- TOC entry 245 (class 1259 OID 16795)
-- Name: traloikhaosat_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.traloikhaosat_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.traloikhaosat_id_seq OWNER TO postgres;

--
-- TOC entry 5276 (class 0 OID 0)
-- Dependencies: 245
-- Name: traloikhaosat_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.traloikhaosat_id_seq OWNED BY public.traloikhaosat.id;


--
-- TOC entry 250 (class 1259 OID 16847)
-- Name: traloiykien; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.traloiykien (
    id bigint NOT NULL,
    layykienid bigint NOT NULL,
    nguoitraloiid bigint NOT NULL,
    noidung text NOT NULL,
    ngaygui timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.traloiykien OWNER TO postgres;

--
-- TOC entry 249 (class 1259 OID 16846)
-- Name: traloiykien_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.traloiykien_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.traloiykien_id_seq OWNER TO postgres;

--
-- TOC entry 5277 (class 0 OID 0)
-- Dependencies: 249
-- Name: traloiykien_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.traloiykien_id_seq OWNED BY public.traloiykien.id;


--
-- TOC entry 255 (class 1259 OID 16910)
-- Name: v_congviec_saphan; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.v_congviec_saphan AS
 SELECT id,
    tieude,
    nguoithuchienid,
    nguontao,
    hanhoanthanh,
    trangthai,
    mucdouutien,
    GREATEST(0, (hanhoanthanh - CURRENT_DATE)) AS songayconlai
   FROM public.congviec c
  WHERE ((hanhoanthanh IS NOT NULL) AND ((trangthai)::text = ANY ((ARRAY['moi'::character varying, 'danglam'::character varying])::text[])) AND (hanhoanthanh >= CURRENT_DATE) AND (hanhoanthanh <= (CURRENT_DATE + '3 days'::interval)));


ALTER VIEW public.v_congviec_saphan OWNER TO postgres;

--
-- TOC entry 256 (class 1259 OID 16915)
-- Name: v_congviec_tre; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.v_congviec_tre AS
 SELECT id,
    tieude,
    nguoithuchienid,
    nguontao,
    hanhoanthanh,
    trangthai,
    mucdouutien,
    (CURRENT_DATE - hanhoanthanh) AS songaytre
   FROM public.congviec c
  WHERE ((hanhoanthanh IS NOT NULL) AND ((trangthai)::text <> 'hoanthanh'::text) AND (hanhoanthanh < CURRENT_DATE));


ALTER VIEW public.v_congviec_tre OWNER TO postgres;

--
-- TOC entry 257 (class 1259 OID 16919)
-- Name: v_lich_dangdienra; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.v_lich_dangdienra AS
 SELECT id,
    phamvi,
    nguoisohuuid,
    tieude,
    thoigianbatdau,
    thoigianketthuc
   FROM public.lichcongtac
  WHERE ((now() >= thoigianbatdau) AND (now() <= thoigianketthuc));


ALTER VIEW public.v_lich_dangdienra OWNER TO postgres;

--
-- TOC entry 226 (class 1259 OID 16568)
-- Name: vanban; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.vanban (
    id bigint NOT NULL,
    tieude character varying(300) NOT NULL,
    loaivanban character varying(20) NOT NULL,
    noidung text,
    tepdinhkem character varying(500),
    nguoitaoid bigint NOT NULL,
    trangthai character varying(20) DEFAULT 'nhap'::character varying NOT NULL,
    ngaytao timestamp without time zone DEFAULT now() NOT NULL,
    timkiem tsvector GENERATED ALWAYS AS (to_tsvector('simple'::regconfig, (((COALESCE(tieude, ''::character varying))::text || ' '::text) || COALESCE(noidung, ''::text)))) STORED,
    CONSTRAINT ck_vanban_loaivanban CHECK (((loaivanban)::text = ANY ((ARRAY['thongbao'::character varying, 'vanban'::character varying, 'bieumau'::character varying, 'quyetdinh'::character varying, 'duthao'::character varying])::text[]))),
    CONSTRAINT ck_vanban_trangthai CHECK (((trangthai)::text = ANY ((ARRAY['nhap'::character varying, 'choduyet'::character varying, 'daduyet'::character varying, 'tuchoi'::character varying])::text[])))
);


ALTER TABLE public.vanban OWNER TO postgres;

--
-- TOC entry 258 (class 1259 OID 16923)
-- Name: v_vanban_choduyet; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.v_vanban_choduyet AS
 SELECT id,
    tieude,
    loaivanban,
    nguoitaoid,
    ngaytao
   FROM public.vanban
  WHERE ((trangthai)::text = 'choduyet'::text)
  ORDER BY ngaytao DESC;


ALTER VIEW public.v_vanban_choduyet OWNER TO postgres;

--
-- TOC entry 225 (class 1259 OID 16567)
-- Name: vanban_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.vanban_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.vanban_id_seq OWNER TO postgres;

--
-- TOC entry 5278 (class 0 OID 0)
-- Dependencies: 225
-- Name: vanban_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.vanban_id_seq OWNED BY public.vanban.id;


--
-- TOC entry 4960 (class 2604 OID 16711)
-- Name: baocao id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.baocao ALTER COLUMN id SET DEFAULT nextval('public.baocao_id_seq'::regclass);


--
-- TOC entry 4944 (class 2604 OID 16526)
-- Name: bophan id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bophan ALTER COLUMN id SET DEFAULT nextval('public.bophan_id_seq'::regclass);


--
-- TOC entry 4969 (class 2604 OID 16780)
-- Name: cauhoikhaosat id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cauhoikhaosat ALTER COLUMN id SET DEFAULT nextval('public.cauhoikhaosat_id_seq'::regclass);


--
-- TOC entry 4953 (class 2604 OID 16641)
-- Name: congviec id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.congviec ALTER COLUMN id SET DEFAULT nextval('public.congviec_id_seq'::regclass);


--
-- TOC entry 4963 (class 2604 OID 16735)
-- Name: denghi id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.denghi ALTER COLUMN id SET DEFAULT nextval('public.denghi_id_seq'::regclass);


--
-- TOC entry 4955 (class 2604 OID 16664)
-- Name: hosogiangday id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.hosogiangday ALTER COLUMN id SET DEFAULT nextval('public.hosogiangday_id_seq'::regclass);


--
-- TOC entry 4966 (class 2604 OID 16758)
-- Name: khaosat id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.khaosat ALTER COLUMN id SET DEFAULT nextval('public.khaosat_id_seq'::regclass);


--
-- TOC entry 4971 (class 2604 OID 16828)
-- Name: layykien id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.layykien ALTER COLUMN id SET DEFAULT nextval('public.layykien_id_seq'::regclass);


--
-- TOC entry 4952 (class 2604 OID 16622)
-- Name: lichcongtac id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lichcongtac ALTER COLUMN id SET DEFAULT nextval('public.lichcongtac_id_seq'::regclass);


--
-- TOC entry 4977 (class 2604 OID 16894)
-- Name: lichsuhethong id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lichsuhethong ALTER COLUMN id SET DEFAULT nextval('public.lichsuhethong_id_seq'::regclass);


--
-- TOC entry 4945 (class 2604 OID 16542)
-- Name: nguoidung id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.nguoidung ALTER COLUMN id SET DEFAULT nextval('public.nguoidung_id_seq'::regclass);


--
-- TOC entry 4951 (class 2604 OID 16600)
-- Name: pheduyet id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pheduyet ALTER COLUMN id SET DEFAULT nextval('public.pheduyet_id_seq'::regclass);


--
-- TOC entry 4958 (class 2604 OID 16688)
-- Name: tailieugiangday id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tailieugiangday ALTER COLUMN id SET DEFAULT nextval('public.tailieugiangday_id_seq'::regclass);


--
-- TOC entry 4976 (class 2604 OID 16875)
-- Name: tepdinhkem id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tepdinhkem ALTER COLUMN id SET DEFAULT nextval('public.tepdinhkem_id_seq'::regclass);


--
-- TOC entry 4970 (class 2604 OID 16799)
-- Name: traloikhaosat id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.traloikhaosat ALTER COLUMN id SET DEFAULT nextval('public.traloikhaosat_id_seq'::regclass);


--
-- TOC entry 4974 (class 2604 OID 16850)
-- Name: traloiykien id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.traloiykien ALTER COLUMN id SET DEFAULT nextval('public.traloiykien_id_seq'::regclass);


--
-- TOC entry 4947 (class 2604 OID 16571)
-- Name: vanban id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.vanban ALTER COLUMN id SET DEFAULT nextval('public.vanban_id_seq'::regclass);


--
-- TOC entry 5238 (class 0 OID 16708)
-- Dependencies: 238
-- Data for Name: baocao; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.baocao (id, bophanid, tieude, noidung, tepdinhkem, ngaygui, trangthai) FROM stdin;
\.


--
-- TOC entry 5222 (class 0 OID 16523)
-- Dependencies: 222
-- Data for Name: bophan; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.bophan (id, tenbophan, loaibophan, bophanchaid) FROM stdin;
\.


--
-- TOC entry 5244 (class 0 OID 16777)
-- Dependencies: 244
-- Data for Name: cauhoikhaosat; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.cauhoikhaosat (id, khaosatid, loaicauhoi, noidung, luachon) FROM stdin;
\.


--
-- TOC entry 5232 (class 0 OID 16638)
-- Dependencies: 232
-- Data for Name: congviec; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.congviec (id, tieude, nguoithuchienid, nguontao, hanhoanthanh, trangthai, mucdouutien) FROM stdin;
\.


--
-- TOC entry 5240 (class 0 OID 16732)
-- Dependencies: 240
-- Data for Name: denghi; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.denghi (id, nguoiguiid, loaidenghi, noidung, trangthai, ngaygui) FROM stdin;
\.


--
-- TOC entry 5234 (class 0 OID 16661)
-- Dependencies: 234
-- Data for Name: hosogiangday; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.hosogiangday (id, giangvienid, tenhoso, loaihoso, trangthai, tepdinhkem, ngaygui) FROM stdin;
\.


--
-- TOC entry 5242 (class 0 OID 16755)
-- Dependencies: 242
-- Data for Name: khaosat; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.khaosat (id, tieude, mota, nguoitaoid, trangthai, ngaytao) FROM stdin;
\.


--
-- TOC entry 5248 (class 0 OID 16825)
-- Dependencies: 248
-- Data for Name: layykien; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.layykien (id, tieude, noidung, nguoitaoid, trangthai, ngaytao) FROM stdin;
\.


--
-- TOC entry 5230 (class 0 OID 16619)
-- Dependencies: 230
-- Data for Name: lichcongtac; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.lichcongtac (id, phamvi, nguoisohuuid, tieude, thoigianbatdau, thoigianketthuc) FROM stdin;
\.


--
-- TOC entry 5254 (class 0 OID 16891)
-- Dependencies: 254
-- Data for Name: lichsuhethong; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.lichsuhethong (id, nguoidungid, hanhdong, doituong, madoituong, noidung, thoigian) FROM stdin;
\.


--
-- TOC entry 5224 (class 0 OID 16539)
-- Dependencies: 224
-- Data for Name: nguoidung; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.nguoidung (id, tendangnhap, matkhaumahoa, hoten, vaitro, bophanid, trangthai) FROM stdin;
1	admin	$2a$06$/GgiGSc5c19It6FVyobaTeBOmaf1/jwmNDzdDui/MvcPtxmqhewYa	Administrator	truongkhoa	\N	active
4	long@gv.hcmunre.edu.vn	$2a$06$/krrg6JAivI4ggaV6SGTUOaxs4YvwMi27YqhIIlWlxLPpsYLmeJIS	Nguyễn Văn Long	giangvien	\N	active
\.


--
-- TOC entry 5228 (class 0 OID 16597)
-- Dependencies: 228
-- Data for Name: pheduyet; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.pheduyet (id, loaithucthe, mathucthe, buoc, nguoipheduyetid, quyetdinh, ghichu, ngayduyet) FROM stdin;
\.


--
-- TOC entry 5236 (class 0 OID 16685)
-- Dependencies: 236
-- Data for Name: tailieugiangday; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tailieugiangday (id, tentailieu, loaitailieu, tinhtrang, tepdinhkem, nguoitaoid, ngaytao) FROM stdin;
\.


--
-- TOC entry 5252 (class 0 OID 16872)
-- Dependencies: 252
-- Data for Name: tepdinhkem; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tepdinhkem (id, loaidt, madt, duongdantep, tengoc, kichthuoc) FROM stdin;
\.


--
-- TOC entry 5246 (class 0 OID 16796)
-- Dependencies: 246
-- Data for Name: traloikhaosat; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.traloikhaosat (id, khaosatid, cauhoiid, nguoitraloiid, giatritraloi) FROM stdin;
\.


--
-- TOC entry 5250 (class 0 OID 16847)
-- Dependencies: 250
-- Data for Name: traloiykien; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.traloiykien (id, layykienid, nguoitraloiid, noidung, ngaygui) FROM stdin;
\.


--
-- TOC entry 5226 (class 0 OID 16568)
-- Dependencies: 226
-- Data for Name: vanban; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.vanban (id, tieude, loaivanban, noidung, tepdinhkem, nguoitaoid, trangthai, ngaytao) FROM stdin;
\.


--
-- TOC entry 5279 (class 0 OID 0)
-- Dependencies: 237
-- Name: baocao_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.baocao_id_seq', 1, false);


--
-- TOC entry 5280 (class 0 OID 0)
-- Dependencies: 221
-- Name: bophan_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.bophan_id_seq', 1, false);


--
-- TOC entry 5281 (class 0 OID 0)
-- Dependencies: 243
-- Name: cauhoikhaosat_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.cauhoikhaosat_id_seq', 1, false);


--
-- TOC entry 5282 (class 0 OID 0)
-- Dependencies: 231
-- Name: congviec_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.congviec_id_seq', 1, false);


--
-- TOC entry 5283 (class 0 OID 0)
-- Dependencies: 239
-- Name: denghi_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.denghi_id_seq', 1, false);


--
-- TOC entry 5284 (class 0 OID 0)
-- Dependencies: 233
-- Name: hosogiangday_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.hosogiangday_id_seq', 1, false);


--
-- TOC entry 5285 (class 0 OID 0)
-- Dependencies: 241
-- Name: khaosat_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.khaosat_id_seq', 1, false);


--
-- TOC entry 5286 (class 0 OID 0)
-- Dependencies: 247
-- Name: layykien_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.layykien_id_seq', 1, false);


--
-- TOC entry 5287 (class 0 OID 0)
-- Dependencies: 229
-- Name: lichcongtac_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.lichcongtac_id_seq', 1, false);


--
-- TOC entry 5288 (class 0 OID 0)
-- Dependencies: 253
-- Name: lichsuhethong_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.lichsuhethong_id_seq', 1, false);


--
-- TOC entry 5289 (class 0 OID 0)
-- Dependencies: 223
-- Name: nguoidung_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.nguoidung_id_seq', 4, true);


--
-- TOC entry 5290 (class 0 OID 0)
-- Dependencies: 227
-- Name: pheduyet_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.pheduyet_id_seq', 1, false);


--
-- TOC entry 5291 (class 0 OID 0)
-- Dependencies: 235
-- Name: tailieugiangday_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tailieugiangday_id_seq', 1, false);


--
-- TOC entry 5292 (class 0 OID 0)
-- Dependencies: 251
-- Name: tepdinhkem_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tepdinhkem_id_seq', 1, false);


--
-- TOC entry 5293 (class 0 OID 0)
-- Dependencies: 245
-- Name: traloikhaosat_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.traloikhaosat_id_seq', 1, false);


--
-- TOC entry 5294 (class 0 OID 0)
-- Dependencies: 249
-- Name: traloiykien_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.traloiykien_id_seq', 1, false);


--
-- TOC entry 5295 (class 0 OID 0)
-- Dependencies: 225
-- Name: vanban_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.vanban_id_seq', 1, false);


--
-- TOC entry 5028 (class 2606 OID 16722)
-- Name: baocao baocao_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.baocao
    ADD CONSTRAINT baocao_pkey PRIMARY KEY (id);


--
-- TOC entry 5004 (class 2606 OID 16531)
-- Name: bophan bophan_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bophan
    ADD CONSTRAINT bophan_pkey PRIMARY KEY (id);


--
-- TOC entry 5037 (class 2606 OID 16788)
-- Name: cauhoikhaosat cauhoikhaosat_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cauhoikhaosat
    ADD CONSTRAINT cauhoikhaosat_pkey PRIMARY KEY (id);


--
-- TOC entry 5020 (class 2606 OID 16649)
-- Name: congviec congviec_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.congviec
    ADD CONSTRAINT congviec_pkey PRIMARY KEY (id);


--
-- TOC entry 5032 (class 2606 OID 16746)
-- Name: denghi denghi_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.denghi
    ADD CONSTRAINT denghi_pkey PRIMARY KEY (id);


--
-- TOC entry 5024 (class 2606 OID 16676)
-- Name: hosogiangday hosogiangday_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.hosogiangday
    ADD CONSTRAINT hosogiangday_pkey PRIMARY KEY (id);


--
-- TOC entry 5035 (class 2606 OID 16769)
-- Name: khaosat khaosat_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.khaosat
    ADD CONSTRAINT khaosat_pkey PRIMARY KEY (id);


--
-- TOC entry 5041 (class 2606 OID 16839)
-- Name: layykien layykien_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.layykien
    ADD CONSTRAINT layykien_pkey PRIMARY KEY (id);


--
-- TOC entry 5018 (class 2606 OID 16629)
-- Name: lichcongtac lichcongtac_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lichcongtac
    ADD CONSTRAINT lichcongtac_pkey PRIMARY KEY (id);


--
-- TOC entry 5047 (class 2606 OID 16904)
-- Name: lichsuhethong lichsuhethong_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lichsuhethong
    ADD CONSTRAINT lichsuhethong_pkey PRIMARY KEY (id);


--
-- TOC entry 5006 (class 2606 OID 16555)
-- Name: nguoidung nguoidung_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.nguoidung
    ADD CONSTRAINT nguoidung_pkey PRIMARY KEY (id);


--
-- TOC entry 5008 (class 2606 OID 16557)
-- Name: nguoidung nguoidung_tendangnhap_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.nguoidung
    ADD CONSTRAINT nguoidung_tendangnhap_key UNIQUE (tendangnhap);


--
-- TOC entry 5016 (class 2606 OID 16609)
-- Name: pheduyet pheduyet_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pheduyet
    ADD CONSTRAINT pheduyet_pkey PRIMARY KEY (id);


--
-- TOC entry 5026 (class 2606 OID 16699)
-- Name: tailieugiangday tailieugiangday_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tailieugiangday
    ADD CONSTRAINT tailieugiangday_pkey PRIMARY KEY (id);


--
-- TOC entry 5045 (class 2606 OID 16885)
-- Name: tepdinhkem tepdinhkem_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tepdinhkem
    ADD CONSTRAINT tepdinhkem_pkey PRIMARY KEY (id);


--
-- TOC entry 5039 (class 2606 OID 16808)
-- Name: traloikhaosat traloikhaosat_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.traloikhaosat
    ADD CONSTRAINT traloikhaosat_pkey PRIMARY KEY (id);


--
-- TOC entry 5043 (class 2606 OID 16860)
-- Name: traloiykien traloiykien_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.traloiykien
    ADD CONSTRAINT traloiykien_pkey PRIMARY KEY (id);


--
-- TOC entry 5014 (class 2606 OID 16584)
-- Name: vanban vanban_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.vanban
    ADD CONSTRAINT vanban_pkey PRIMARY KEY (id);


--
-- TOC entry 5009 (class 1259 OID 16595)
-- Name: ginvanbantimkiem; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ginvanbantimkiem ON public.vanban USING gin (timkiem);


--
-- TOC entry 5029 (class 1259 OID 16729)
-- Name: idxbaocaobophan; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idxbaocaobophan ON public.baocao USING btree (bophanid);


--
-- TOC entry 5030 (class 1259 OID 16730)
-- Name: idxbaocaotrangthai; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idxbaocaotrangthai ON public.baocao USING btree (trangthai);


--
-- TOC entry 5021 (class 1259 OID 16658)
-- Name: idxcongviecnguoithuchien; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idxcongviecnguoithuchien ON public.congviec USING btree (nguoithuchienid);


--
-- TOC entry 5022 (class 1259 OID 16659)
-- Name: idxcongviectrangthai; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idxcongviectrangthai ON public.congviec USING btree (trangthai);


--
-- TOC entry 5033 (class 1259 OID 16753)
-- Name: idxdenghinguoigui; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idxdenghinguoigui ON public.denghi USING btree (nguoiguiid);


--
-- TOC entry 5010 (class 1259 OID 16594)
-- Name: idxvanbanloai; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idxvanbanloai ON public.vanban USING btree (loaivanban);


--
-- TOC entry 5011 (class 1259 OID 16592)
-- Name: idxvanbannguoitao; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idxvanbannguoitao ON public.vanban USING btree (nguoitaoid);


--
-- TOC entry 5012 (class 1259 OID 16593)
-- Name: idxvanbantrangthai; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idxvanbantrangthai ON public.vanban USING btree (trangthai);


--
-- TOC entry 5067 (class 2620 OID 16566)
-- Name: nguoidung before_delete_nguoidung_block; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER before_delete_nguoidung_block BEFORE DELETE ON public.nguoidung FOR EACH ROW EXECUTE FUNCTION public.trg_block_delete_user();


--
-- TOC entry 5069 (class 2620 OID 16889)
-- Name: tepdinhkem before_insupd_tepdinhkem_validate; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER before_insupd_tepdinhkem_validate BEFORE INSERT OR UPDATE ON public.tepdinhkem FOR EACH ROW EXECUTE FUNCTION public.trg_validate_tepdinhkem_ref();


--
-- TOC entry 5068 (class 2620 OID 16974)
-- Name: nguoidung trg_validate_email_domain; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_validate_email_domain BEFORE INSERT OR UPDATE ON public.nguoidung FOR EACH ROW EXECUTE FUNCTION public.fn_validate_email_domain();


--
-- TOC entry 5056 (class 2606 OID 16723)
-- Name: baocao baocao_bophanid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.baocao
    ADD CONSTRAINT baocao_bophanid_fkey FOREIGN KEY (bophanid) REFERENCES public.bophan(id);


--
-- TOC entry 5048 (class 2606 OID 16532)
-- Name: bophan bophan_bophanchaid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bophan
    ADD CONSTRAINT bophan_bophanchaid_fkey FOREIGN KEY (bophanchaid) REFERENCES public.bophan(id) ON DELETE SET NULL;


--
-- TOC entry 5059 (class 2606 OID 16789)
-- Name: cauhoikhaosat cauhoikhaosat_khaosatid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cauhoikhaosat
    ADD CONSTRAINT cauhoikhaosat_khaosatid_fkey FOREIGN KEY (khaosatid) REFERENCES public.khaosat(id) ON DELETE CASCADE;


--
-- TOC entry 5053 (class 2606 OID 16650)
-- Name: congviec congviec_nguoithuchienid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.congviec
    ADD CONSTRAINT congviec_nguoithuchienid_fkey FOREIGN KEY (nguoithuchienid) REFERENCES public.nguoidung(id);


--
-- TOC entry 5057 (class 2606 OID 16747)
-- Name: denghi denghi_nguoiguiid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.denghi
    ADD CONSTRAINT denghi_nguoiguiid_fkey FOREIGN KEY (nguoiguiid) REFERENCES public.nguoidung(id);


--
-- TOC entry 5054 (class 2606 OID 16677)
-- Name: hosogiangday hosogiangday_giangvienid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.hosogiangday
    ADD CONSTRAINT hosogiangday_giangvienid_fkey FOREIGN KEY (giangvienid) REFERENCES public.nguoidung(id);


--
-- TOC entry 5058 (class 2606 OID 16770)
-- Name: khaosat khaosat_nguoitaoid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.khaosat
    ADD CONSTRAINT khaosat_nguoitaoid_fkey FOREIGN KEY (nguoitaoid) REFERENCES public.nguoidung(id);


--
-- TOC entry 5063 (class 2606 OID 16840)
-- Name: layykien layykien_nguoitaoid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.layykien
    ADD CONSTRAINT layykien_nguoitaoid_fkey FOREIGN KEY (nguoitaoid) REFERENCES public.nguoidung(id);


--
-- TOC entry 5052 (class 2606 OID 16630)
-- Name: lichcongtac lichcongtac_nguoisohuuid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lichcongtac
    ADD CONSTRAINT lichcongtac_nguoisohuuid_fkey FOREIGN KEY (nguoisohuuid) REFERENCES public.nguoidung(id) ON DELETE SET NULL;


--
-- TOC entry 5066 (class 2606 OID 16905)
-- Name: lichsuhethong lichsuhethong_nguoidungid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lichsuhethong
    ADD CONSTRAINT lichsuhethong_nguoidungid_fkey FOREIGN KEY (nguoidungid) REFERENCES public.nguoidung(id);


--
-- TOC entry 5049 (class 2606 OID 16558)
-- Name: nguoidung nguoidung_bophanid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.nguoidung
    ADD CONSTRAINT nguoidung_bophanid_fkey FOREIGN KEY (bophanid) REFERENCES public.bophan(id) ON DELETE SET NULL;


--
-- TOC entry 5051 (class 2606 OID 16610)
-- Name: pheduyet pheduyet_nguoipheduyetid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pheduyet
    ADD CONSTRAINT pheduyet_nguoipheduyetid_fkey FOREIGN KEY (nguoipheduyetid) REFERENCES public.nguoidung(id);


--
-- TOC entry 5055 (class 2606 OID 16700)
-- Name: tailieugiangday tailieugiangday_nguoitaoid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tailieugiangday
    ADD CONSTRAINT tailieugiangday_nguoitaoid_fkey FOREIGN KEY (nguoitaoid) REFERENCES public.nguoidung(id);


--
-- TOC entry 5060 (class 2606 OID 16814)
-- Name: traloikhaosat traloikhaosat_cauhoiid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.traloikhaosat
    ADD CONSTRAINT traloikhaosat_cauhoiid_fkey FOREIGN KEY (cauhoiid) REFERENCES public.cauhoikhaosat(id) ON DELETE CASCADE;


--
-- TOC entry 5061 (class 2606 OID 16809)
-- Name: traloikhaosat traloikhaosat_khaosatid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.traloikhaosat
    ADD CONSTRAINT traloikhaosat_khaosatid_fkey FOREIGN KEY (khaosatid) REFERENCES public.khaosat(id) ON DELETE CASCADE;


--
-- TOC entry 5062 (class 2606 OID 16819)
-- Name: traloikhaosat traloikhaosat_nguoitraloiid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.traloikhaosat
    ADD CONSTRAINT traloikhaosat_nguoitraloiid_fkey FOREIGN KEY (nguoitraloiid) REFERENCES public.nguoidung(id);


--
-- TOC entry 5064 (class 2606 OID 16861)
-- Name: traloiykien traloiykien_layykienid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.traloiykien
    ADD CONSTRAINT traloiykien_layykienid_fkey FOREIGN KEY (layykienid) REFERENCES public.layykien(id) ON DELETE CASCADE;


--
-- TOC entry 5065 (class 2606 OID 16866)
-- Name: traloiykien traloiykien_nguoitraloiid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.traloiykien
    ADD CONSTRAINT traloiykien_nguoitraloiid_fkey FOREIGN KEY (nguoitraloiid) REFERENCES public.nguoidung(id);


--
-- TOC entry 5050 (class 2606 OID 16585)
-- Name: vanban vanban_nguoitaoid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.vanban
    ADD CONSTRAINT vanban_nguoitaoid_fkey FOREIGN KEY (nguoitaoid) REFERENCES public.nguoidung(id);


-- Completed on 2025-10-23 15:32:31

--
-- PostgreSQL database dump complete
--

\unrestrict gCg9nXMZ9ldwUyOuMWTFTNzm5bEvzxlvbCQMryNOnOizb80woGvgQaY6xT1v9op

