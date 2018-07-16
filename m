Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id B87DB6B026F
	for <linux-mm@kvack.org>; Mon, 16 Jul 2018 03:59:34 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id f9-v6so23706800pfn.22
        for <linux-mm@kvack.org>; Mon, 16 Jul 2018 00:59:34 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id m3-v6si27495365plb.27.2018.07.16.00.59.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Jul 2018 00:59:33 -0700 (PDT)
Date: Mon, 16 Jul 2018 10:59:29 +0300
From: Leon Romanovsky <leon@kernel.org>
Subject: Re: [RFC PATCH] mm, oom: distinguish blockable mode for mmu notifiers
Message-ID: <20180716075929.GF3152@mtr-leonro.mtl.com>
References: <20180622150242.16558-1-mhocko@kernel.org>
 <20180627074421.GF32348@dhcp22.suse.cz>
 <20180709122908.GJ22049@dhcp22.suse.cz>
 <20180710134040.GG3014@mtr-leonro.mtl.com>
 <20180710141410.GP14284@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="IpbVkmxF4tDyP/Kb"
Content-Disposition: inline
In-Reply-To: <20180710141410.GP14284@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: LKML <linux-kernel@vger.kernel.org>, "David (ChunMing) Zhou" <David1.Zhou@amd.com>, Paolo Bonzini <pbonzini@redhat.com>, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Alex Deucher <alexander.deucher@amd.com>, Christian =?iso-8859-1?Q?K=F6nig?= <christian.koenig@amd.com>, David Airlie <airlied@linux.ie>, Jani Nikula <jani.nikula@linux.intel.com>, Joonas Lahtinen <joonas.lahtinen@linux.intel.com>, Rodrigo Vivi <rodrigo.vivi@intel.com>, Doug Ledford <dledford@redhat.com>, Jason Gunthorpe <jgg@ziepe.ca>, Mike Marciniszyn <mike.marciniszyn@intel.com>, Dennis Dalessandro <dennis.dalessandro@intel.com>, Sudeep Dutt <sudeep.dutt@intel.com>, Ashutosh Dixit <ashutosh.dixit@intel.com>, Dimitri Sivanich <sivanich@sgi.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, kvm@vger.kernel.org, amd-gfx@lists.freedesktop.org, dri-devel@lists.freedesktop.org, intel-gfx@lists.freedesktop.org, linux-rdma@vger.kernel.org, xen-devel@lists.xenproject.org, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Felix Kuehling <felix.kuehling@amd.com>


--IpbVkmxF4tDyP/Kb
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Tue, Jul 10, 2018 at 04:14:10PM +0200, Michal Hocko wrote:
> On Tue 10-07-18 16:40:40, Leon Romanovsky wrote:
> > On Mon, Jul 09, 2018 at 02:29:08PM +0200, Michal Hocko wrote:
> > > On Wed 27-06-18 09:44:21, Michal Hocko wrote:
> > > > This is the v2 of RFC based on the feedback I've received so far. The
> > > > code even compiles as a bonus ;) I haven't runtime tested it yet, mostly
> > > > because I have no idea how.
> > > >
> > > > Any further feedback is highly appreciated of course.
> > >
> > > Any other feedback before I post this as non-RFC?
> >
> > From mlx5 perspective, who is primary user of umem_odp.c your change looks ok.
>
> Can I assume your Acked-by?
>
> Thanks for your review!

For mlx and umem_odp pieces,
Acked-by: Leon Romanovsky <leonro@mellanox.com>

Thanks

--IpbVkmxF4tDyP/Kb
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIcBAEBAgAGBQJbTFBhAAoJEORje4g2clinrPEQAM3K+7WNo+Ro9U49mpUc8xr/
MGGxTsfNW12jUSp6FCTQU6e53hUr+Xkr7HLA9V2PRM848OAOjQlBUKgCGQ4Mb1hQ
jaWFDf5PTXMiSwutJGhqJXuaYkFyLiR6oE0hdGoaPFRQ6TDkWeqXmP7MDOvJe9ml
Ea4dAgif8LEjYjGNOCUGJ6Ur89jJmf4D6EFcWhHyin7XejnD3z4vX0VcRbVwY8tl
H7w7S/TRXNE9gGUTid8i6eC81IG+p+xOaG0JhLcf95F0/sz7Y2gwWUzHWUScrn7A
m7mLXJf+hMGM6oVYxE224xTUbKkVXfYjYLzY9BZ7NB9ycKdi6aDL4diB2w+83acB
SplvTEfXKFVQtSKVyo24NoxEIscZyIHrJu0BaE8d002tvAcE2uiSmgUbQ/grXooe
8Fl8vyau1974/hx4bP6/Fclol25CUtqCatVw+x4vysEqferddvmFW0xOTzUorpTP
bI7zb9Ozs3icZ90Hhxk1jBe1Jmw8XIPGTCv06yDQOufFHxi2UnL2qKVxIrPLh/s5
xkJzguy/TxXk210mWnbWmpmytgKNsUQSMmYqyUEfxtzWlRHYWD3Z6KVUAsPsuy8J
b/fCbYfHzCTP2X4Vm4eoYTxI7YzByBnyIK/eAz1eKVlYbJb8yXx0bqzRbmn6gizc
jWDNXsZCJJ8q58BpwivZ
=YBIL
-----END PGP SIGNATURE-----

--IpbVkmxF4tDyP/Kb--
