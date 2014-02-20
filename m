Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id CE2F56B0068
	for <linux-mm@kvack.org>; Thu, 20 Feb 2014 01:35:06 -0500 (EST)
Received: by mail-pd0-f177.google.com with SMTP id x10so1410550pdj.22
        for <linux-mm@kvack.org>; Wed, 19 Feb 2014 22:35:06 -0800 (PST)
Received: from ozlabs.org (ozlabs.org. [203.10.76.45])
        by mx.google.com with ESMTPS id xe9si2138421pab.141.2014.02.19.22.35.04
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Feb 2014 22:35:05 -0800 (PST)
Date: Thu, 20 Feb 2014 17:34:56 +1100
From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: mmotm 2014-02-19-16-07 uploaded (sound/soc/intel/sst-dsp.c)
Message-Id: <20140220173456.8bf55b0ebf366ecad2e83047@canb.auug.org.au>
In-Reply-To: <53059590.7040506@infradead.org>
References: <20140220000827.17F275A42DC@corp2gmr1-2.hot.corp.google.com>
	<53059590.7040506@infradead.org>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Thu__20_Feb_2014_17_34_56_+1100_DW+3i974rqAJl6/W"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Randy Dunlap <rdunlap@infradead.org>
Cc: akpm@linux-foundation.org, mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, Liam Girdwood <lgirdwood@gmail.com>

--Signature=_Thu__20_Feb_2014_17_34_56_+1100_DW+3i974rqAJl6/W
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Randy,

On Wed, 19 Feb 2014 21:41:36 -0800 Randy Dunlap <rdunlap@infradead.org> wro=
te:
>
> on i386:
> (from linux-next)
>=20
>   CC      sound/soc/intel/sst-dsp.o
> sound/soc/intel/sst-dsp.c: In function 'sst_dsp_outbox_write':
> sound/soc/intel/sst-dsp.c:218:2: error: implicit declaration of function =
'memcpy_toio' [-Werror=3Dimplicit-function-declaration]
> sound/soc/intel/sst-dsp.c: In function 'sst_dsp_outbox_read':
> sound/soc/intel/sst-dsp.c:231:2: error: implicit declaration of function =
'memcpy_fromio' [-Werror=3Dimplicit-function-declaration]
> cc1: some warnings being treated as errors
> make[4]: *** [sound/soc/intel/sst-dsp.o] Error 1

Which linux-next?  How did you generate that error?  I think I have that
driver disabled in linux-next ever since it was introduced due to getting
this error in one of my builds.

... thinks ...

I get it - the linux-next patch in Andrew's patch queue is based on the
part of linux-next *before* the commit that reverted the commit that
allowed that file to build.  :-(  Today, that will not happen.  I'll see
if I can come up with a more permanent solution to that problem.

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Signature=_Thu__20_Feb_2014_17_34_56_+1100_DW+3i974rqAJl6/W
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAEBCAAGBQJTBaIUAAoJEMDTa8Ir7ZwVfdoP/3eNhuccH6YTpbLNsHL7o/AS
xxuNW/WXQ1s+9GwSvcrWu3WyKwVseAzmtagpZyNyZw2t9GFqFIK0Kd415PYWwqCz
DwGvhBaDpn2iF4sZMSiTQg+k+R/bDe0OJp3PR+HzfmhwXO/etrm5F7Z5iHyPDCDR
4RqI4pnrEAqhQ6DComWLaVBhia2bE44kG97ULU8/TyDH/cAOMamwVKS00iREE0C4
g3XjVI27Yz4O/TOV1KSz7TDspHEp2bd+g3hOJb2yAHdawHaLwwtnAlUHiGN2nU+O
viCnD/cjqSmleNSNwUAt3gry/ltZYMCXseptNKr0Lh+sTZeVgkU26wEnWqPGMtYi
vch7GGAIxrInKP5MooZcYP/QHMaTwUsn0Et73Oqk552wpHkhplZoqDTwbzjgg6AB
9EP0mZm6hjXgF0UdZSfFIyRC3JJPLrN3UTZuyXwhsq0vKsSPHD89fwiG4OwUJ1jQ
XfxxprkSNOXBgjvxb+vKJyUjClxYMh/x9A7p9lUQLMGm+VcUMFRJRqZbK1574+vi
ztdU9qaMU75VzAEMrgKVkxH/3PAC39AwjEUzcCyiMZGdc3fIVAyDXFW6KH5Bu2qP
qycR4jXg396HCRR9ZZhiw/3QYnyvbdyKSfUCH3Jja1p+c3sWYxuwyHP/ZXih+Nd6
AOu9Sjv+b1+SBBEsw1vH
=zpG2
-----END PGP SIGNATURE-----

--Signature=_Thu__20_Feb_2014_17_34_56_+1100_DW+3i974rqAJl6/W--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
