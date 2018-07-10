Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id D0F866B0007
	for <linux-mm@kvack.org>; Tue, 10 Jul 2018 09:40:45 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id w11-v6so7919930pfk.14
        for <linux-mm@kvack.org>; Tue, 10 Jul 2018 06:40:45 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id p2-v6si15452001pgk.690.2018.07.10.06.40.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Jul 2018 06:40:44 -0700 (PDT)
Date: Tue, 10 Jul 2018 16:40:40 +0300
From: Leon Romanovsky <leon@kernel.org>
Subject: Re: [RFC PATCH] mm, oom: distinguish blockable mode for mmu notifiers
Message-ID: <20180710134040.GG3014@mtr-leonro.mtl.com>
References: <20180622150242.16558-1-mhocko@kernel.org>
 <20180627074421.GF32348@dhcp22.suse.cz>
 <20180709122908.GJ22049@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="xugVLPVe/nLWwmIL"
Content-Disposition: inline
In-Reply-To: <20180709122908.GJ22049@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: LKML <linux-kernel@vger.kernel.org>, "David (ChunMing) Zhou" <David1.Zhou@amd.com>, Paolo Bonzini <pbonzini@redhat.com>, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Alex Deucher <alexander.deucher@amd.com>, Christian =?iso-8859-1?Q?K=F6nig?= <christian.koenig@amd.com>, David Airlie <airlied@linux.ie>, Jani Nikula <jani.nikula@linux.intel.com>, Joonas Lahtinen <joonas.lahtinen@linux.intel.com>, Rodrigo Vivi <rodrigo.vivi@intel.com>, Doug Ledford <dledford@redhat.com>, Jason Gunthorpe <jgg@ziepe.ca>, Mike Marciniszyn <mike.marciniszyn@intel.com>, Dennis Dalessandro <dennis.dalessandro@intel.com>, Sudeep Dutt <sudeep.dutt@intel.com>, Ashutosh Dixit <ashutosh.dixit@intel.com>, Dimitri Sivanich <sivanich@sgi.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, kvm@vger.kernel.org, amd-gfx@lists.freedesktop.org, dri-devel@lists.freedesktop.org, intel-gfx@lists.freedesktop.org, linux-rdma@vger.kernel.org, xen-devel@lists.xenproject.org, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Felix Kuehling <felix.kuehling@amd.com>


--xugVLPVe/nLWwmIL
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Jul 09, 2018 at 02:29:08PM +0200, Michal Hocko wrote:
> On Wed 27-06-18 09:44:21, Michal Hocko wrote:
> > This is the v2 of RFC based on the feedback I've received so far. The
> > code even compiles as a bonus ;) I haven't runtime tested it yet, mostly
> > because I have no idea how.
> >
> > Any further feedback is highly appreciated of course.
>
> Any other feedback before I post this as non-RFC?

=46rom mlx5 perspective, who is primary user of umem_odp.c your change look=
s ok.

Thanks

--xugVLPVe/nLWwmIL
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIcBAEBAgAGBQJbRLdYAAoJEORje4g2clinszcP/i1ZoA12tkJ+VFRkYqorF+9B
+Z2snjMkSjj9Nz8XeYAzlg1RSNNeiTtFsN7UKrr6X484ccyy7oT//Nj5gGcxyEo3
qzAxMgRyD+xTbV97YJEVXpo7T6euNyH2ajtBDVwHQo14A6ZK2SIETUh9ssJhCumQ
9rv/UBFiJ/PjODzYNulmHvhILOt5QQc0UxoC1ApoGddv5bj5eaQeQ1xIBigZ1lZp
HCr53Z4NZ2WXiwMpHomBcD+Z2ZD2lRPUVWKsUYn8mU7iLzYGWOE3h8Ca0lEK74On
MAxdJT2ywBGWQ7XaIDEmWPs2xsV18qDKaUj6T/b0V6LD8T6DNrwyrjCUOZg8K08I
SdoWhHm1JADzOzPDDh2aHBpkPC9oIlWYGnFgGra87G+wXmwvegYIi3wady1d7VzI
RHSDQzcRiZqhGivXZPCqffXicAC3/PTWaLB2v1sm9LK+s8DoUcxW67RPDQmvB2Jj
cgqDTLvw+ikvXAhHhI4wfqE3ITAg6sOgQIxo+395/30Y1/sHprvEQDcc1jVm5avw
ueFriLICm7Kb0pYY/fUH6JxxbqIGEFW8oLC0hqalbMsIKLabWTHbEWmbCLkKj1c0
z0B2Vo0GLbEKRBwtbelQP9KQcPCG4x0OKMnZQ8jfiDsWPmTXYOu7108rKOf98a6N
gnaRbmsYcsnBMQtUAzSx
=Dfrg
-----END PGP SIGNATURE-----

--xugVLPVe/nLWwmIL--
