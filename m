Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx179.postini.com [74.125.245.179])
	by kanga.kvack.org (Postfix) with SMTP id D04096B005D
	for <linux-mm@kvack.org>; Wed, 11 Jul 2012 03:48:58 -0400 (EDT)
Message-ID: <1341993193.2963.132.camel@sauron>
Subject: Re: mmotm 2012-07-10-16-59 uploaded
From: Artem Bityutskiy <dedekind1@gmail.com>
Reply-To: dedekind1@gmail.com
Date: Wed, 11 Jul 2012 10:53:13 +0300
In-Reply-To: <20120711004430.0d14f0b6.akpm@linux-foundation.org>
References: <20120711000148.BAD1E5C0050@hpza9.eem.corp.google.com>
	 <1341988680.2963.128.camel@sauron>
	 <20120711004430.0d14f0b6.akpm@linux-foundation.org>
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature";
	boundary="=-TKtQ4fCInahKiz/mbV1T"
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org


--=-TKtQ4fCInahKiz/mbV1T
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2012-07-11 at 00:44 -0700, Andrew Morton wrote:
> On Wed, 11 Jul 2012 09:38:00 +0300 Artem Bityutskiy <dedekind1@gmail.com>=
 wrote:
>=20
> > Andrew, thanks for picking my changes!
> >=20
> > On Tue, 2012-07-10 at 17:01 -0700, akpm@linux-foundation.org wrote:
> > > * hfs-get-rid-of-hfs_sync_super-checkpatch-fixes.patch
> >=20
> > > * hfsplus-get-rid-of-write_super-checkpatch-fixes.patch
> >=20
> > I sent updated versions which would fix checkpatch.pl complaints. I
> > guess you did not notice them or was unable to pick because I think I
> > PGP-signed them?
>=20
> I looked at them, but they're identical to what I now have, so nothing
> needed doing.

Strange, I thought they had the white-spaces issue solved. I'll resend
the entire series. Thanks!

--=20
Best Regards,
Artem Bityutskiy

--=-TKtQ4fCInahKiz/mbV1T
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAABAgAGBQJP/TDpAAoJECmIfjd9wqK0Op8P/14ZezDA/Ag/M2iBmGNIU08J
2rwtfpPR3QGtB1VPTmvBnfvGKYMcUgQWWyodwoujQmTA0VH/eWFcsh9P4R4KGxAq
OXhFYW+Jllc5YOZKDwvGHlXp2h1yEpIonQDkGXTPuqR9Lnkgtu+GnBMIeMPC8KCr
izLtyTiSDz4pzB7FRsMavxyWRgjMmTN0wZkNZBw0kn1BdqBVsORKi9KSitLpJu+7
VtnjVJzGf0lD5oDjs4csZmMhTi0fSPAcwaAsQj0SnpRqj84S6ixgXnwm8rdcwhl5
4/DBB2K8W+IlvRMLIJOCLXuSA+51CLELzsnGkj/Jpv6T63m4FYvf/gWzXNxxTisH
4UE5gzVRI5J5IuhclMsE0ZJlKhVYw//EF3+chVsB7eVvoYMBB7VpiXTTQ09Yvzu3
28ZarIOzU5qVAN6IXiRGDG3E6+YkgOS4/G+Ypus4lT4aCUxX35s4+VEBypyrNPlw
paHRQ2/Bx0DUty12qnqnNRQMzlwVVbMsUg6JxuTK9nlIwZt1jrsuCCfDPs+ltZfx
RM2hmwi3p+3KkRLStxnhScFTx3COpmmYODtXquCTwEnBSZrA0qswn7hqxvwRvPEW
Wtnbe2GCAf6JG+nO52F73euL2CE6zeWNXMqMne5THV47G7fNtQ7FRsqIxarXkf7K
lDt23SR4cTmPVLUYNAvn
=fSvh
-----END PGP SIGNATURE-----

--=-TKtQ4fCInahKiz/mbV1T--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
