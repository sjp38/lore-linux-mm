From: Thomas Schlichter <thomas.schlichter@web.de>
Subject: Re: 2.6.2-rc1-mm2
Date: Fri, 23 Jan 2004 14:30:30 +0100
References: <20040123013740.58a6c1f9.akpm@osdl.org>
In-Reply-To: <20040123013740.58a6c1f9.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: multipart/signed;
  protocol="application/pgp-signature";
  micalg=pgp-sha1;
  boundary="Boundary-02=_6HSEARO1wa1gnGq";
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Message-Id: <200401231430.35014.thomas.schlichter@web.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>, John Stultz <johnstul@us.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--Boundary-02=_6HSEARO1wa1gnGq
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Description: signed data
Content-Disposition: inline

Hi,

Am Freitag, 23. Januar 2004 10:37 schrieb Andrew Morton:
> +use-pmtmr-for-delay_pmtmr.patch
>
>  Fix a boot-time crash which occurs when testing the APIC timer when using
>  the ACPI PM timer.  This causes bogomips to be reported at 50% of what it
>  used to be.

I don't know which Oops this fixes, but with this patch my bogomips value i=
s=20
8.19 (!!!) instead of ~1300. With clock=3Dpit I get about 1300 bogomips, an=
d=20
with clock=3Dtsc I get about 2600 bogomips. The CPU is a 1300MHz AMD Duron.

Regards
   Thomas Schlichter

--Boundary-02=_6HSEARO1wa1gnGq
Content-Type: application/pgp-signature
Content-Description: signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.2 (GNU/Linux)

iD8DBQBAESH6YAiN+WRIZzQRAvqQAKDS2o70dvfTUBTODq6B/nkIRA7SOwCfSJKo
SYuxkwnuLAaN7rkVluFyBoo=
=NLHN
-----END PGP SIGNATURE-----

--Boundary-02=_6HSEARO1wa1gnGq--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
