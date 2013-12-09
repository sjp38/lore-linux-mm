Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id 40CA36B0088
	for <linux-mm@kvack.org>; Mon,  9 Dec 2013 06:41:14 -0500 (EST)
Received: by mail-wi0-f179.google.com with SMTP id z2so3551356wiv.0
        for <linux-mm@kvack.org>; Mon, 09 Dec 2013 03:41:13 -0800 (PST)
Received: from multi.imgtec.com (multi.imgtec.com. [194.200.65.239])
        by mx.google.com with ESMTPS id kx10si4334533wjb.51.2013.12.09.03.41.13
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Dec 2013 03:41:13 -0800 (PST)
Message-ID: <52A5AC11.8050802@imgtec.com>
Date: Mon, 9 Dec 2013 11:40:01 +0000
From: James Hogan <james.hogan@imgtec.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm/zswap.c: add BUG() for default case in zswap_writeback_entry()
References: <52A53024.9090701@gmail.com> <52A5935A.4040709@imgtec.com> <52A5973A.7020509@gmail.com> <52A5990E.2080808@imgtec.com> <52A5A7B5.2040904@gmail.com>
In-Reply-To: <52A5A7B5.2040904@gmail.com>
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature";
	boundary="fgxWaTIwlBRUUL7oxeBw70PfkIQJB051R"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chen Gang <gang.chen.5i5j@gmail.com>
Cc: Seth Jennings <sjenning@linux.vnet.ibm.com>, linux-mm@kvack.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

--fgxWaTIwlBRUUL7oxeBw70PfkIQJB051R
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 09/12/13 11:21, Chen Gang wrote:
> Oh, I tried gcc 4.6.3-2 rhel version, get the same result as yours (do
> not report warning), but for me, it is still a compiler's bug, it
> *should* report a warning for it, we can try below:

Not necessarily. You can't expect the compiler to detect and warn about
more complex bugs the programmer writes, so you have to draw the line
somewhere.

IMO missing some potential bugs is better than warning about code that
isn't buggy since that just makes people ignore the warnings or
carelessly try to silence them.

Cheers
James


--fgxWaTIwlBRUUL7oxeBw70PfkIQJB051R
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.13 (GNU/Linux)

iQIcBAEBAgAGBQJSpawYAAoJEKHZs+irPybfPOYP/jZo6ZOVy7+HFL0VH322lUmE
oTGu4uTF74wrxPgUFcjErgenr72+vQtJyoXGvPvEj/YihisJfJlGS5uC4yKEoDBp
N6f5hFqVjkUjb5wGavtAoetnItvJMDmR8SU9gQr7xNSH6e22k8BCfxlKg0B8ckjD
/DvjEVy14h3MWwR9GJrxIHgjJONc6VPHrm5F1l24ucCnPHEmiExJYYfsZP1fmJ4f
fQymG/ImLs0/tG6igcYOoDmNkqpAgikASzZfAkKoW4LDwAUSrvZoyTi1TJzAgRBv
ApT6fjLVooLXPh8u0r5+kXMyRKzRAQwwqCH/z/kUCNdESgB1Hh84RVgdqKYmk3zO
hKZtW8aedZxC3L5UXTKh4kvyW5kLeaF6REeYN01/gp5jh2fC5rGKq0eUGl2P6rib
IfrWnPM6QSz0yCTxL8yeoY6VO0UZP1t0chbG8tnCFSEjOE8qqIFLIlWIWA72TXO5
EUmMX0CYn5LMB1LlbPWCiFYap8Vo3q1x623z+ouQyiOcZ4IwvFpfBPgo0OD+icLP
Y0HTXzkwyUCFu6qQfjy2Q5esTJPqJzTMbkPu5uYBURBe60mKzWnjkNSUDrMkKEXc
klI6oArj4J0L1CG0hDE39+OVtuMcOwDLYlfZly4EiFWvHCAobh0zjNLl9uLIbn1O
dZKerMGqJPqco9m0fJTD
=Ub0h
-----END PGP SIGNATURE-----

--fgxWaTIwlBRUUL7oxeBw70PfkIQJB051R--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
