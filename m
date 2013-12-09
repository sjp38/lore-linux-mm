Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id 870CF6B0038
	for <linux-mm@kvack.org>; Mon,  9 Dec 2013 05:19:12 -0500 (EST)
Received: by mail-wi0-f174.google.com with SMTP id z2so3508722wiv.1
        for <linux-mm@kvack.org>; Mon, 09 Dec 2013 02:19:12 -0800 (PST)
Received: from multi.imgtec.com (multi.imgtec.com. [194.200.65.239])
        by mx.google.com with ESMTPS id d6si6373990wic.19.2013.12.09.02.19.11
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Dec 2013 02:19:11 -0800 (PST)
Message-ID: <52A5990E.2080808@imgtec.com>
Date: Mon, 9 Dec 2013 10:18:54 +0000
From: James Hogan <james.hogan@imgtec.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm/zswap.c: add BUG() for default case in zswap_writeback_entry()
References: <52A53024.9090701@gmail.com> <52A5935A.4040709@imgtec.com> <52A5973A.7020509@gmail.com>
In-Reply-To: <52A5973A.7020509@gmail.com>
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature";
	boundary="qAXefV6503UIGO1BfqDUiEx9ScgrRbLn9"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chen Gang <gang.chen.5i5j@gmail.com>
Cc: Seth Jennings <sjenning@linux.vnet.ibm.com>, linux-mm@kvack.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

--qAXefV6503UIGO1BfqDUiEx9ScgrRbLn9
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 09/12/13 10:11, Chen Gang wrote:
>> Since the metag compiler is stuck on an old version (gcc 4.2.4), which=

>> is wrong to warn in this case, and newer versions of gcc don't appear =
to
>> warn about it anyway (I just checked with gcc 4.7.2 x86_64), I have no=

>> objection to this warning remaining in the metag build.
>>
>=20
> Do you try "EXTRA_CFLAGS=3D-W" with gcc 4.7.2? I guess it will report t=
he
> warning too, I don't feel the compiler is smart enough (except it lets
> the long function zswap_get_swap_cache_page really inline)  :-)

EXTRA_CFLAGS=3D-W on gcc 4.7.2 gives me plenty of pointless unused
parameter warnings when compiling mm/zswap.o, but not the warning you're
trying to silence.

Cheers
James


--qAXefV6503UIGO1BfqDUiEx9ScgrRbLn9
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.13 (GNU/Linux)

iQIcBAEBAgAGBQJSpZkUAAoJEKHZs+irPybf0aIP/ioeotyiGtG5UOKC35190G+0
TcVc8InYNM/1U83mSUh8z3fqXbYw/S5xS12JoyFNyytKIH0lhzFBSLWjs7g6AVkg
l+GOPMVjsJbxQWHKgG3eBNPwCqpzmwUF4iuDg4LzxKTftUsMd2CJR2APopcapVLx
4CWmu957fnFSvU0eJ/TgizsBsuJI+jSz31yypb0jvXZEUK0iXe9hoTu4THJBhWm6
S8yx4gdnQHhaNdPC6JxceTGPUpknhwHBVCQQpIOOGNi91qgka4Oz2isY/2A1mYuI
xYq+fInM+ry8N+NKAP0PtwBNOwQ5GLNi5spJ+EGfbtSEvy/tYTsqol7Ws5Bpj8Tq
hQtSOGk8gJQSVqXv9PGoIGiCZ9mF5DdUXiX/LoUxfbaEsrvA57+0PL/C/H76+VXA
y4CG+j8uDQJYtpr4swpSbnJRwcNg0Zv3Ua+AXl1r4j8nFRJgXsso1qm+zC20ey9v
CFrXGWV/AWPLunUCqv8Pj5QgDDrlW6+ZtZn3d2A6hrJbPsHPMQbUzVoPiZQ1sKtt
NsKwZBGnrWaLzrhaPTrqFIPxWRuuRUakWRwioJkfxDqQEGoyr/PPkbSN7VNz8ErN
tIXZKzxWachqMGiCNuI8g3wSeweeCcUGzgVG2KK/MaAfRSMgMtiZxnfrB1esiTrv
IMk0e24wLORHDedE6jQd
=dEBm
-----END PGP SIGNATURE-----

--qAXefV6503UIGO1BfqDUiEx9ScgrRbLn9--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
