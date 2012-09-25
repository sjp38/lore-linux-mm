Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id 0D7966B002B
	for <linux-mm@kvack.org>; Tue, 25 Sep 2012 17:48:40 -0400 (EDT)
Date: Wed, 26 Sep 2012 07:48:27 +1000
From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: mmotm 2012-09-20-17-25 uploaded (fs/bimfmt_elf on uml)
Message-Id: <20120926074827.32c7187adef6327c74c75564@canb.auug.org.au>
In-Reply-To: <alpine.DEB.2.00.1209251243320.31518@chino.kir.corp.google.com>
References: <20120921002638.7859F100047@wpzn3.hot.corp.google.com>
	<505C865D.5090802@xenotime.net>
	<20120922115606.5ca9f599cd88514ddda4831d@canb.auug.org.au>
	<alpine.DEB.2.00.1209251243320.31518@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Wed__26_Sep_2012_07_48_27_+1000_k8PpY51A+D9WqnR5"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Randy Dunlap <rdunlap@xenotime.net>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, Richard Weinberger <richard@nod.at>

--Signature=_Wed__26_Sep_2012_07_48_27_+1000_k8PpY51A+D9WqnR5
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi David,

On Tue, 25 Sep 2012 12:43:53 -0700 (PDT) David Rientjes <rientjes@google.co=
m> wrote:
>
> On Sat, 22 Sep 2012, Stephen Rothwell wrote:
>=20
> > > on uml for x86_64 defconfig:
> > >=20
> > > fs/binfmt_elf.c: In function 'fill_files_note':
> > > fs/binfmt_elf.c:1419:2: error: implicit declaration of function 'vmal=
loc'
> > > fs/binfmt_elf.c:1419:7: warning: assignment makes pointer from intege=
r without a cast
> > > fs/binfmt_elf.c:1437:5: error: implicit declaration of function 'vfre=
e'
> >=20
> > reported in linux-next (offending patch reverted for other
> > problems).
>=20
> This still happens on x86_64 for linux-next as of today's tree.

Are you sure?  next-20120925?

$ grep -n vmalloc fs/binfmt_elf.c
30:#include <linux/vmalloc.h>
1421:	data =3D vmalloc(size);

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Signature=_Wed__26_Sep_2012_07_48_27_+1000_k8PpY51A+D9WqnR5
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBCAAGBQJQYiarAAoJEECxmPOUX5FEAGcP/2gldFfvcS8osFzNRf+P3SW5
3yyN9+KAgpCwNFW1oHxFfhsvmhNrlRwzzCVVbFWcjqMjTNci28LvqmStQHeLnGJY
3A1iu3onLiJUBxxsXxZWBLf5nvFTajtJyeXX7I6gI5cKHcHls/aclrdvn2mxWliW
dvB34yZg0CCMCQLJKkUrYIAwtVTlGmZ3AynreAbbVWYywWtslILIDov5VQBKsCcE
3z9yec49sEzBYq16VGqfbDPqhqx9OFq8vXrw4PIlLt3AFwtNRl69RLRndKVC6jYh
LNOcQPfCL/yg55cBafn799eeiyFq5pvvYkcbT7q0qNBMaZku87sQNO7TIepWpirS
R7TtY+SCIm08zIE+FGhq8Wl4aHJGG2hMpMZuE6Qg9whn/LhBlK39qnpMocIsyU/s
v9RQXFEH5UybeDy2ukm8QUzgG21gMMFaLV7ctbVkLXoomUR6w968rTYW0gFpk+mh
C5shch4CBW3lnVtKf+gve2ZWl0TdmsiZR1oLqIzzYlZF5dybJDrjRD6kwrdbCAEH
qfcJCJFEgUMGEZj50jILD9dFHfZgOR3XAw3aAz+hWQxFRQ8ldGIJxl5AEzNy2/SH
2VmpzTMDPu4vouMnzjgAwGCBQGHXrbjQ2d3HcGz3D3jiPxhOddr2aaavuJ/Uznez
uRpN/ej1nOB4UGt6drjw
=gQpN
-----END PGP SIGNATURE-----

--Signature=_Wed__26_Sep_2012_07_48_27_+1000_k8PpY51A+D9WqnR5--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
