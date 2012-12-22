Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx151.postini.com [74.125.245.151])
	by kanga.kvack.org (Postfix) with SMTP id 2C6FC6B005A
	for <linux-mm@kvack.org>; Sat, 22 Dec 2012 08:09:45 -0500 (EST)
Date: Sat, 22 Dec 2012 15:10:23 +0200
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: 3.8-rc1 build failure with MIPS/SPARSEMEM
Message-ID: <20121222131022.GA16364@otc-wbsnb-06>
References: <20121222122757.GB6847@blackmetal.musicnaut.iki.fi>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="a8Wt8u1KmwUX3Y2C"
Content-Disposition: inline
In-Reply-To: <20121222122757.GB6847@blackmetal.musicnaut.iki.fi>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Aaro Koskinen <aaro.koskinen@iki.fi>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-mips@linux-mips.org


--a8Wt8u1KmwUX3Y2C
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Sat, Dec 22, 2012 at 02:27:57PM +0200, Aaro Koskinen wrote:
> Hi,
>=20
> It looks like commit 816422ad76474fed8052b6f7b905a054d082e59a
> (asm-generic, mm: pgtable: consolidate zero page helpers) broke
> MIPS/SPARSEMEM build in 3.8-rc1:

Could you try this:

http://permalink.gmane.org/gmane.linux.kernel/1410981

?
--=20
 Kirill A. Shutemov

--a8Wt8u1KmwUX3Y2C
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBAgAGBQJQ1bE+AAoJEAd+omnVudOMApcP/1uIiUWCXP8Lym3KcmCKmK1j
pqU/ALq5X8t6SAcZTOMF7xroFabeSGZ5mXTWFJ26fgMY95LkddsFzcvO1zgl5BFp
OBkT4shs/M/cDvEcetOO0lBExAkKngOXQGd8ZATMIlXaIyZ03dJ3m/A0chsfRdwE
COPgc5ixTTwGEhAcMy1r6MBokO+pFc8ODlUGWNHOvgsW4/YKwjgzGZ1rT6vtv0rN
ah7cWeJ5PTD1HupHZSOh1P91pGwQbV1TWML+hEEJlbeLxFW47yx9vNkdjwoi1kvm
PSjHZOs1SeMQxpGP9icE/ZH1tnCeQoyIk8SD90xusV+5YRktPw8BTpdErLT7z03P
ebAKfQgixSMhEawHSe9wW6DMSRt5+IFTZlz0lYrHSfSVb2k0SbyN2oFepmih0q98
tBI8I63QpqlVlYrAFktURnNg794sWXNtsxJ4yaXBwrw5CfxFM3YalPHJOmPgB/QX
MiMBKkMVmFh+2P+Imf3w/oMqDJcg5vNjjoGG75LoIn1LnZELmc1IDoe+igof1Uac
sr7SkycpcSBshtggTvxvxO5EEgmZqNck+t4ixwQKbYOnge7SBNPzqZaa9XePeiyU
574fk+hUnQSjk1WpWzaKPmvuLnNibF6WMSBYMjbeg0sbdNLOpf0ZTp1bH5WLbmfO
nVYpX2z0UbR/s6MCw/vD
=FFgu
-----END PGP SIGNATURE-----

--a8Wt8u1KmwUX3Y2C--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
