Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na6sys010bmx007.postini.com [74.125.246.107])
	by kanga.kvack.org (Postfix) with SMTP id 681E56B0032
	for <linux-mm@kvack.org>; Thu, 27 Jun 2013 19:57:25 -0400 (EDT)
Date: Fri, 28 Jun 2013 09:57:12 +1000
From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: mmotm 2013-06-27-16-36 uploaded
Message-Id: <20130628095712.120bec7036284584fd467ee2@canb.auug.org.au>
In-Reply-To: <20130627233733.BAEB131C3BE@corp2gmr1-1.hot.corp.google.com>
References: <20130627233733.BAEB131C3BE@corp2gmr1-1.hot.corp.google.com>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Fri__28_Jun_2013_09_57_12_+1000_2K.=.RcrtCBGukkj"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org

--Signature=_Fri__28_Jun_2013_09_57_12_+1000_2K.=.RcrtCBGukkj
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On Thu, 27 Jun 2013 16:37:33 -0700 akpm@linux-foundation.org wrote:
>
> The mm-of-the-moment snapshot 2013-06-27-16-36 has been uploaded to
>=20
>    http://www.ozlabs.org/~akpm/mmotm/
>=20
>   include-linux-smph-on_each_cpu-switch-back-to-a-macro.patch
>   arch-c6x-mm-include-asm-uaccessh-to-pass-compiling.patch
>   drivers-dma-pl330c-fix-locking-in-pl330_free_chan_resources.patch

Did you mean to drop these three patches from linux-next?

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Signature=_Fri__28_Jun_2013_09_57_12_+1000_2K.=.RcrtCBGukkj
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.20 (GNU/Linux)

iQIcBAEBCAAGBQJRzNFgAAoJEECxmPOUX5FEBBQP/1hZnBOg95lcex5YwznOZFui
T0kjzJ2afJGH2LvdBbUGMOljUrAcDQBK+XCkslrEZG53bSlC6H0klQnQJSzLlChO
mQ6OnfX0NQdVKtX4aYEmIB2YNL+oyeJgtIoxa4dKy2b/a/Zk87V85kEyJ0Og3tuJ
TAiqKypCuXjEkC1JokUmY9xgxhLk+jRyb8R0+Prd7ahddsgI27iJUUDw3T38DK8K
LH2/r/1H19l8mqYCsCo9ctG49NJxrPAZIFc+vh4nZ0ivRPqkB41FF1V9IzDB4RxM
/XjQcNoyThL19oHCbp8oordfJeT804RFMgdHRbqcZiwve93FPUfUrCWFbtoT1EO9
stJosQF/oi+doQCoHjnuBcs8SqbXsmDdLoleBagf9GsrX8BW2TB+E+49F/MWyIzI
ArZE69VWbXo19Wy4Bi/zEgeNZB6bJoNQuT9EeMg+x150V3v7DKjrOtAASGP/cZ/P
Y8tPrTmR/Mpr2km2F6WUdhcPLqxg0NAiUPIJ975ft62+aps43JQepuducPkP2tli
smITrYNFzS9UDPKKUQZTeuiuEeWQp/COsESNFnjUwmEWiDKUu3Cw7n/lgoTNA+76
a6zR58cAw56ParpxVwlQTe7z87VwOTV2dLQNc+ltbR+7nrbnAdc8xTdCS4cmA/Ug
1RslZOtVYmG7DF4eAOdw
=XgAV
-----END PGP SIGNATURE-----

--Signature=_Fri__28_Jun_2013_09_57_12_+1000_2K.=.RcrtCBGukkj--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
