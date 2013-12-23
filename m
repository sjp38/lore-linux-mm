Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id B0C506B0035
	for <linux-mm@kvack.org>; Mon, 23 Dec 2013 05:05:33 -0500 (EST)
Received: by mail-pd0-f169.google.com with SMTP id v10so4973592pde.14
        for <linux-mm@kvack.org>; Mon, 23 Dec 2013 02:05:33 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id za5si12082849pbc.249.2013.12.23.02.05.31
        for <linux-mm@kvack.org>;
        Mon, 23 Dec 2013 02:05:32 -0800 (PST)
Date: Mon, 23 Dec 2013 04:46:59 -0500
From: "Chen, Gong" <gong.chen@linux.intel.com>
Subject: Re: [PATCH] mm/memory-failure.c: send action optional signal to an
 arbitrary thread
Message-ID: <20131223094659.GC17713@gchen.bj.intel.com>
References: <20131212222527.GD8605@mcs.anl.gov>
 <1386964742-df8sz3d6-mutt-n-horiguchi@ah.jp.nec.com>
 <20131213230004.GD7793@mcs.anl.gov>
 <20131218064515.GC20765@two.firstfloor.org>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="7gGkHNMELEOhSGF6"
Content-Disposition: inline
In-Reply-To: <20131218064515.GC20765@two.firstfloor.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: Kamil Iskra <iskra@mcs.anl.gov>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-mm@kvack.org


--7gGkHNMELEOhSGF6
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Dec 18, 2013 at 07:45:15AM +0100, Andi Kleen wrote:
> Date: Wed, 18 Dec 2013 07:45:15 +0100
> From: Andi Kleen <andi@firstfloor.org>
> To: Kamil Iskra <iskra@mcs.anl.gov>
> Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-mm@kvack.org, Andi
>  Kleen <andi@firstfloor.org>
> Subject: Re: [PATCH] mm/memory-failure.c: send action optional signal to =
an
>  arbitrary thread
> User-Agent: Mutt/1.5.20 (2009-06-14)
>=20
> > I'm not sure if I understand.  "letting the main thread create a dedica=
ted
> > thread for error handling" is exactly what I was trying to do -- the
> > problem is that SIGBUS(BUS_MCEERR_AO) signals are never sent to that
> > thread, which is contrary to common expectations. =20
>=20
Please add this section in your patch commit.

>=20
> Yes handling AO errors like this was the intended way=20
>=20
> I thought I had tested it at some point and intentionally changed the=20
> signal checking for this case (because normally SIGBUS cannot be
> blocked). Anyways if it doesn't work it's definitely a bug.
>=20
> If you fix it please make sure to add the test case to mce-test.
>=20

Yes, I think you can update your test case and add it in mce-test.
If you can't find latest mce-test git tree, here it is:
git://git.kernel.org/pub/scm/linux/kernel/git/gong.chen/mce-test.git

--7gGkHNMELEOhSGF6
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.15 (GNU/Linux)

iQIcBAEBAgAGBQJSuAaTAAoJEI01n1+kOSLHhXAP/1lmF8xCnMzBSjskz29i/clS
4lBJLjgwI3krkybYyo/ht/YTB7b4YnfiwIhDOrjljLx7AAPwxAuuD3ym5RuLlrPp
Kl+slCNVhGQFDRUorVw6xK/I96Yz0Hx4tRmrjoA6jWZKea2eCZ6wAXqptw3OL5cV
7to+X85GZjY9o1+kL6560gpva/tlBvBX+TVMdI2eYWQg5dOhzstbwBQWaDFln3Kb
dp/kKrguqkHcsAJJ/GZZOabcyafwxiyvFAZ23FRx3MWv7muMb1dpYY4067w4lLA1
1SVAqxFtWpwYISnVnKJtG8tT6ieD9Tbbimr9FOpEkvASNiRSxA9ZNEQMKfSQW8fK
SSizBhCjciwoileGlDpZVQYWuV4bdZaGdzp+IrmXgtIO46mxGm7sb+3ciGc+gSdF
Pg2Fa9KdvoDHD6z14ur+aOSMXgsWqMLp753Nz+cubu2TVdy+4RMopzT+CroYpUAk
AhZHC0hZadNZwXLE/BeFvgqMacEk2jjK2jH7QzhKMgO2q7ueaY6U3yaIl2jPSG2/
l4/6GoZ3n8U1sa9Az9uATUci3SnuGFZT5lSx4LQlYc8Nlh190iBWOVo1p+ECWpcP
O2Hi5CbZIib96GQyymoyAa4zWnf50bBuO4jFfay0uhSxcZ67owG6SHAFZ02FTkfF
+KikFn8LaRl06PozcfFh
=qUNh
-----END PGP SIGNATURE-----

--7gGkHNMELEOhSGF6--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
