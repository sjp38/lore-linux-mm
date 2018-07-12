Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 128BF6B0003
	for <linux-mm@kvack.org>; Thu, 12 Jul 2018 02:55:11 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id t78-v6so17778665pfa.8
        for <linux-mm@kvack.org>; Wed, 11 Jul 2018 23:55:11 -0700 (PDT)
Received: from ozlabs.org (ozlabs.org. [203.11.71.1])
        by mx.google.com with ESMTPS id x68-v6si21513742pfc.239.2018.07.11.23.55.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 11 Jul 2018 23:55:09 -0700 (PDT)
Date: Thu, 12 Jul 2018 16:55:05 +1000
From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: Boot failures with "mm/sparse: Remove
 CONFIG_SPARSEMEM_ALLOC_MEM_MAP_TOGETHER" on powerpc (was Re: mmotm
 2018-07-10-16-50 uploaded)
Message-ID: <20180712165505.0a0d4214@canb.auug.org.au>
In-Reply-To: <20180712094729.1112f290@canb.auug.org.au>
References: <20180710235044.vjlRV%akpm@linux-foundation.org>
	<87lgai9bt5.fsf@concordia.ellerman.id.au>
	<20180711133737.GA29573@techadventures.net>
	<CAGM2reYsSi5kDGtnTQASnp1v49T8Y+9o_pNxmSq-+m68QhF2Tg@mail.gmail.com>
	<20180711141344.10eb6d22b0ee1423cc94faf8@linux-foundation.org>
	<20180712094729.1112f290@canb.auug.org.au>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/9VtbG/=2abtdT+J+ZGKDtty"; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Pavel Tatashin <pasha.tatashin@oracle.com>, osalvador@techadventures.net, mpe@ellerman.id.au, broonie@kernel.org, mhocko@suse.cz, linux-next@vger.kernel.org, linux-fsdevel@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, mm-commits@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, bhe@redhat.com, aneesh.kumar@linux.ibm.com, khandual@linux.vnet.ibm.com

--Sig_/9VtbG/=2abtdT+J+ZGKDtty
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi all,

On Thu, 12 Jul 2018 09:47:29 +1000 Stephen Rothwell <sfr@canb.auug.org.au> =
wrote:
>
> On Wed, 11 Jul 2018 14:13:44 -0700 Andrew Morton <akpm@linux-foundation.o=
rg> wrote:
> >
> > OK, I shall drop
> > mm-sparse-remove-config_sparsemem_alloc_mem_map_together.patch for now.=
 =20
>=20
> I have dropped it from linux-next today (in case you don't get time).

I am certain I did drop it, but some how it is still in there :-(

I will drop it for tomorrow.
--=20
Cheers,
Stephen Rothwell

--Sig_/9VtbG/=2abtdT+J+ZGKDtty
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----

iQEzBAEBCAAdFiEENIC96giZ81tWdLgKAVBC80lX0GwFAltG+0kACgkQAVBC80lX
0GzE8gf/fUdfa84A9Rm5btRmAOAHWKjSdaNqQP89D2p0DFJHL8Urv9aFxTctkwNH
gTd98JpxjiIdHIFOt5Ct29OD6D1p/6Z2bLLu4o4R1DZOBITQ5ky+07oYXSEEv6zh
0TT0moiaKnXY38SmpYIvYj3QzIvZIRKaiSstkktY7Y8s6EUPOREV4sCOTK8d7NBY
nmFHt4w9pn+maq81lPha0n+PVGCdOTLPFGXYt/Q51xxDoV69XSpa+XagDgXKPURr
PQuisARvCX4Xv47262d2X8v9eS/Cqi2zGWYPx5i+rXW1lEopjEZ/Ry6iGtlux2EU
rMZVqBfDfp643ZRF02MXA16fIIFIJQ==
=FLOl
-----END PGP SIGNATURE-----

--Sig_/9VtbG/=2abtdT+J+ZGKDtty--
