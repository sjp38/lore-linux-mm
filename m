Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3B22F6B0005
	for <linux-mm@kvack.org>; Wed, 21 Feb 2018 18:32:04 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id c37so2622156wra.5
        for <linux-mm@kvack.org>; Wed, 21 Feb 2018 15:32:04 -0800 (PST)
Received: from mout.gmx.net (mout.gmx.net. [212.227.15.19])
        by mx.google.com with ESMTPS id h184si40937wma.121.2018.02.21.15.32.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Feb 2018 15:32:03 -0800 (PST)
Date: Thu, 22 Feb 2018 00:31:58 +0100
From: Jonathan =?utf-8?Q?Neusch=C3=A4fer?= <j.neuschaefer@gmx.net>
Subject: Re: [PATCH 0/6] DISCONTIGMEM support for PPC32
Message-ID: <20180221233158.4rnxsyxffhevtj44@latitude>
References: <20180220161424.5421-1-j.neuschaefer@gmx.net>
 <193a407d-e6b8-9e29-af47-3d401b6414a0@c-s.fr>
 <20180221144240.pfu2run3pixt3pzo@latitude>
 <a36983ec-5e97-e968-8143-1b2615ea55f8@c-s.fr>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="3wousgr6cvagsioq"
Content-Disposition: inline
In-Reply-To: <a36983ec-5e97-e968-8143-1b2615ea55f8@c-s.fr>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christophe LEROY <christophe.leroy@c-s.fr>
Cc: Jonathan =?utf-8?Q?Neusch=C3=A4fer?= <j.neuschaefer@gmx.net>, linuxppc-dev@lists.ozlabs.org, Joel Stanley <joel@jms.id.au>, linux-kernel@vger.kernel.org, linux-mm@kvack.org


--3wousgr6cvagsioq
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Feb 21, 2018 at 04:02:25PM +0100, Christophe LEROY wrote:
[...]
> > > My question might me stupid, as I don't know PCC64 in deep, but when =
looking
> > > at page_is_ram() in arch/powerpc/mm/mem.c, I have the feeling the PPC=
64
> > > implements ram by blocks. Isn't it what you are trying to achieve ? W=
ouldn't
> > > it be feasible to map to what's done in PPC64 for PPC32 ?
> >=20
> > Using page_is_ram in __ioremap_caller and the same memblock-based
> > approach that's used on PPC64 on PPC32 *should* work, but I think due to
> > the following line in initmem_init, it won't:
> >=20
> > 	memblock_set_node(0, (phys_addr_t)ULLONG_MAX, &memblock.memory, 0);
>=20
> Can't we just fix that ?

Turns out I was completely wrong about this. memblock_set_node as called
above only assigns all memory to node 0 and merges *adjacent* memblocks.
It doesn't merge the memblocks on the Wii, which are far apart.

So now I actually have a working patchset (coming soon), that's a good
deal shorter than this patchset, and hopefully won't break
CONFIG_HIGHMEM in the same way.

Thanks for your input! :)


Jonathan Neusch=C3=A4fer

--3wousgr6cvagsioq
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAABAgAGBQJajgFjAAoJEAgwRJqO81/bDAUP+gPIvPGu0J/u2uqZfNr27T+4
sh45TNrfe52W5evpflDWMx4ZUq2v6Y/sug9fvebmiLJ5t3oMPzTWxNxIxB8q4Fn3
qI5QIyZGpsr+8z5TH2Ww4givs3W5c24Ze4ysbsqefJJZMJzkMM+Ao3cGcWD686/C
rTn6K27WxO80xhTlf/5jtdjf2vBQd0aUSN0BgtlsJElYuXXUN7qlsF4apLTcHsVi
itdOxGqajwn+vBlcp8e7i86DnOaWOX2u09TDGgUHL10hnLTzToWZjeI8UUBtdiOY
9WVT+69J1FnyLPjHnBl+ry3Z3BBJWIWYWKMtUdUSLT90V3VPWfFUnCobX1E+TQ+C
QmP6romqvvxBsJLQQ1MPxCRDOxFmMfNulWQNYwIM+6T4HBBMHQ5mi/7QYRBOxVef
NI/cuiXExZ6dE2gx48XfFDbferQ3ah9IUSeu3JUIkZ5457KPQVfc0a/t/AJcEmn4
WfWY+CPHs0RoD73KgqskxC/NR3BDHCPGPfMwMlkBuPjhREgLmYHwmCpDjgUXST+2
gagoCx4q0CYYC7VPgq/UDJBnaOyiK/znpr6EyJ0HBBeUd2HR/uVKeGD5GAiSV7hu
9BlVNc6XMUUp/q3H6TcJqI2UUt8LMvBhwQ1p9B7xCtJRxgiys3eCSrtIsgJA0d5w
+c2s4pf5ExFkCl1Mp04x
=GpyF
-----END PGP SIGNATURE-----

--3wousgr6cvagsioq--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
