Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 991278E0001
	for <linux-mm@kvack.org>; Thu, 10 Jan 2019 17:54:48 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id x7so7040428pll.23
        for <linux-mm@kvack.org>; Thu, 10 Jan 2019 14:54:48 -0800 (PST)
Received: from ozlabs.org (ozlabs.org. [2401:3900:2:1::2])
        by mx.google.com with ESMTPS id v6si42585185pfv.181.2019.01.10.14.54.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 10 Jan 2019 14:54:46 -0800 (PST)
Date: Thu, 10 Jan 2019 15:11:09 +1100
From: David Gibson <david@gibson.dropbear.id.au>
Subject: Re: [PATCH V6 0/4] mm/kvm/vfio/ppc64: Migrate compound pages out of
 CMA region
Message-ID: <20190110041109.GG6682@umbus.fritz.box>
References: <20190108045110.28597-1-aneesh.kumar@linux.ibm.com>
 <20190108115620.6ec22e7d60b86d5f609d5a87@linux-foundation.org>
 <875zuyjk96.fsf@linux.ibm.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="0z5c7mBtSy1wdr4F"
Content-Disposition: inline
In-Reply-To: <875zuyjk96.fsf@linux.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, Alexey Kardashevskiy <aik@ozlabs.ru>, Andrea Arcangeli <aarcange@redhat.com>, mpe@ellerman.id.au, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org


--0z5c7mBtSy1wdr4F
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Jan 09, 2019 at 02:11:25PM +0530, Aneesh Kumar K.V wrote:
> Andrew Morton <akpm@linux-foundation.org> writes:
>=20
> > On Tue,  8 Jan 2019 10:21:06 +0530 "Aneesh Kumar K.V" <aneesh.kumar@lin=
ux.ibm.com> wrote:
> >
> >> ppc64 use CMA area for the allocation of guest page table (hash page t=
able). We won't
> >> be able to start guest if we fail to allocate hash page table. We have=
 observed
> >> hash table allocation failure because we failed to migrate pages out o=
f CMA region
> >> because they were pinned. This happen when we are using VFIO. VFIO on =
ppc64 pins
> >> the entire guest RAM. If the guest RAM pages get allocated out of CMA =
region, we
> >> won't be able to migrate those pages. The pages are also pinned for th=
e lifetime of the
> >> guest.
> >>=20
> >> Currently we support migration of non-compound pages. With THP and wit=
h the addition of
> >>  hugetlb migration we can end up allocating compound pages from CMA re=
gion. This
> >> patch series add support for migrating compound pages. The first path =
adds the helper
> >> get_user_pages_cma_migrate() which pin the page making sure we migrate=
 them out of
> >> CMA region before incrementing the reference count.=20
> >
> > Does this code do anything for architectures other than powerpc?  If
> > not, should we be adding the ifdefs to avoid burdening other
> > architectures with unused code?
>=20
> Any architecture enabling CMA may need this. I will move most of this bel=
ow
> CONFIG_CMA.

In theory it could affect any architecture using CMA.  I suspect it's
much less likely to bite in practice on architectures other than ppc.
IIUC the main use of CMA there is to allocate things like framebuffers
or other large contiguous blocks used for hardware devices.  That's
usually going to happen rarely and during boot up.  What makes ppc
different is that we need a substantial CMA allocation every time we
start a (POWER8) guest for the HPT.  It's the fact that running guests
on a system both means we need the CMA unfragment and (with vfio added
in) can cause CMA fragmentation which makes this particularly
problematic.

--=20
David Gibson			| I'll have my music baroque, and my code
david AT gibson.dropbear.id.au	| minimalist, thank you.  NOT _the_ _other_
				| _way_ _around_!
http://www.ozlabs.org/~dgibson

--0z5c7mBtSy1wdr4F
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEdfRlhq5hpmzETofcbDjKyiDZs5IFAlw2xdsACgkQbDjKyiDZ
s5J9sBAA5lc1/Su5Mk8Js41SPXyYqpqL564xEbq/qnGSLpg3S6KalgBl3t2cwN/0
mcd68QCi6vsD659ZwKtvraQDMA5Mk5mCMXaJo59WnN5eaio+gjQ6e5Ii8AjZjO/N
peQhvsmk1TAy5GIC+h+s8o3g8r2gr5N/XxYnLBSz5DZhGtLH1Kpge1e6Gpk0dhlM
CM59ss0KWfO912VtHicpWwsOt2ac2Nfk9HKBlPtboefLKjAf8lc/Yggaz7NWrm/Q
Of5QXd94PaoH41Fy/t89LMOt4NuqTywx6/H0fcVCrYOxtHi9AMZ4o0xnEe+d1NqE
1LWVs6UTDgtSNkwygki7d3p3nY5vdLOsR84iioKZN5Ssvlv99pEDyBu55fhNvEO6
l4Q5cJigSk2Wxonn26Ktf50Ye3UV1JDFzvv4JQx19EfzvOI8aZREQWAJPvS0/s6n
vb2NZg6MG8jLy7havZxqxGpTZEqWLt4u3ksDbAeOL2qNpYzrELIeNb+rKJOnF/BN
wFWZ22vtrlXxJFDyTlOWTKLtX95PhYeviuZAqTqc8nTRbpe963rDpztxGOOclBG1
nipPp01RnwPG2XaqTdYnANWVFG0EHjdO+qQ8Ea9J5QCOswHjP02kbdPjPG5fb2zC
/gdOd9+Co4t0tZjCreB96Bn/1GAzaj0TCyADV4hWEwlhUoKnBSI=
=f8fd
-----END PGP SIGNATURE-----

--0z5c7mBtSy1wdr4F--
