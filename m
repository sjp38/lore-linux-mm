Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 617EF6B028C
	for <linux-mm@kvack.org>; Wed, 11 Jul 2018 08:08:50 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id y7-v6so14703909plt.17
        for <linux-mm@kvack.org>; Wed, 11 Jul 2018 05:08:50 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id w9-v6si1537651plp.395.2018.07.11.05.08.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Jul 2018 05:08:48 -0700 (PDT)
Date: Wed, 11 Jul 2018 15:08:45 +0300
From: Leon Romanovsky <leon@kernel.org>
Subject: Re: [RFC PATCH] mm, oom: distinguish blockable mode for mmu notifiers
Message-ID: <20180711120845.GA7750@mtr-leonro.mtl.com>
References: <20180622150242.16558-1-mhocko@kernel.org>
 <20180627074421.GF32348@dhcp22.suse.cz>
 <20180709122908.GJ22049@dhcp22.suse.cz>
 <20180710134040.GG3014@mtr-leonro.mtl.com>
 <20180710141410.GP14284@dhcp22.suse.cz>
 <20180710162020.GJ3014@mtr-leonro.mtl.com>
 <20180711090353.GD20050@dhcp22.suse.cz>
 <20180711101447.GU3014@mtr-leonro.mtl.com>
 <20180711111318.GL20050@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="SLDf9lqlvOQaIe6s"
Content-Disposition: inline
In-Reply-To: <20180711111318.GL20050@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: LKML <linux-kernel@vger.kernel.org>, "David (ChunMing) Zhou" <David1.Zhou@amd.com>, Paolo Bonzini <pbonzini@redhat.com>, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Alex Deucher <alexander.deucher@amd.com>, Christian =?iso-8859-1?Q?K=F6nig?= <christian.koenig@amd.com>, David Airlie <airlied@linux.ie>, Jani Nikula <jani.nikula@linux.intel.com>, Joonas Lahtinen <joonas.lahtinen@linux.intel.com>, Rodrigo Vivi <rodrigo.vivi@intel.com>, Doug Ledford <dledford@redhat.com>, Jason Gunthorpe <jgg@ziepe.ca>, Mike Marciniszyn <mike.marciniszyn@intel.com>, Dennis Dalessandro <dennis.dalessandro@intel.com>, Sudeep Dutt <sudeep.dutt@intel.com>, Ashutosh Dixit <ashutosh.dixit@intel.com>, Dimitri Sivanich <sivanich@sgi.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, kvm@vger.kernel.org, amd-gfx@lists.freedesktop.org, dri-devel@lists.freedesktop.org, intel-gfx@lists.freedesktop.org, linux-rdma@vger.kernel.org, xen-devel@lists.xenproject.org, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Felix Kuehling <felix.kuehling@amd.com>


--SLDf9lqlvOQaIe6s
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Wed, Jul 11, 2018 at 01:13:18PM +0200, Michal Hocko wrote:
> On Wed 11-07-18 13:14:47, Leon Romanovsky wrote:
> > On Wed, Jul 11, 2018 at 11:03:53AM +0200, Michal Hocko wrote:
> > > On Tue 10-07-18 19:20:20, Leon Romanovsky wrote:
> > > > On Tue, Jul 10, 2018 at 04:14:10PM +0200, Michal Hocko wrote:
> > > > > On Tue 10-07-18 16:40:40, Leon Romanovsky wrote:
> > > > > > On Mon, Jul 09, 2018 at 02:29:08PM +0200, Michal Hocko wrote:
> > > > > > > On Wed 27-06-18 09:44:21, Michal Hocko wrote:
> > > > > > > > This is the v2 of RFC based on the feedback I've received so far. The
> > > > > > > > code even compiles as a bonus ;) I haven't runtime tested it yet, mostly
> > > > > > > > because I have no idea how.
> > > > > > > >
> > > > > > > > Any further feedback is highly appreciated of course.
> > > > > > >
> > > > > > > Any other feedback before I post this as non-RFC?
> > > > > >
> > > > > > From mlx5 perspective, who is primary user of umem_odp.c your change looks ok.
> > > > >
> > > > > Can I assume your Acked-by?
> > > >
> > > > I didn't have a chance to test it because it applies on our rdma-next, but
> > > > fails to compile.
> > >
> > > What is the compilation problem? Is it caused by the patch or some other
> > > unrelated changed?
> >
> > Thanks for pushing me to take a look on it.
> > Your patch needs the following hunk to properly compile at least on my system.
>
> I suspect you were trying the original version. I've posted an updated
> patch here http://lkml.kernel.org/r/20180627074421.GF32348@dhcp22.suse.cz
> and all these issues should be fixed there. Including many other fixes.
>

Ohh, you used --reply-to, IMHO it is best way to make sure that the
patch will be lost :)

> Could you have a look at that one please?

I grabbed it, the results will be overnight only.

Thanks

> --
> Michal Hocko
> SUSE Labs

--SLDf9lqlvOQaIe6s
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIcBAEBAgAGBQJbRfNNAAoJEORje4g2clinlVwP+gOTolhbvb7Z7rdf1A/MW8q6
SOrUeHuzbfpi3QwcJOQv9305fjVWOQ8Sgqv9xbYw19ISxlIY+B/tm+XgbUEcMHMC
P0TYVuLz2SGJCRoovqICZ49NzestzlGyn3Nv5AGoKG2JAzWXphtHROIkGt3SNraX
O1B+izek2DrruThuLEtQbNHx+gI9QP7YZhdz7ClbNO2VwxIGQZcCvhjc2fG1v6ab
dkXKZ3QS05bm5rQO2+VFV3WhAFtkUwocqyjrGrbvn6IgDWYPmXmXhbjhSbLs4V+w
ggj4kwUQd0R/QQY126lOtkvZKQk/EZu+GmumNpLqeTY0AF+vX4SOMrsZreekaQIw
4ZzouQ0yFyBGIYO/i+zQaAyAgwJBf0b1nyWl+OZyY8E03e2COp0GF2sdiTMo5K+N
G9msVCQhavJsWawiL+1RyzgfLHipcnp4dYCFDqpqbZR/3Kx7ld1OBWT0JzbhuqZW
x4uelzSwBAzeZW2Hj2TYfMNuaRlHBiJi7Bqct8b2avsftTvGvUdQKbtxxxXzd1SI
J1OgzS/WFi/Ao+UW0yFVXWKtitaIMzCVhZroYZs4BUoKJq8fLjGSaXxEPfUfLQmT
SjbLYA8IVUQLJs3yx/2TJrRxu2ti8zUhnv+jJfcG0T7LT5CjL9Qe7Yx8lMy+u4eR
ngUiQqGK0WJWIaQq3r19
=g6/F
-----END PGP SIGNATURE-----

--SLDf9lqlvOQaIe6s--
