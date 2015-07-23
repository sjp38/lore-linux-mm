Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f174.google.com (mail-qk0-f174.google.com [209.85.220.174])
	by kanga.kvack.org (Postfix) with ESMTP id 7217D6B0260
	for <linux-mm@kvack.org>; Thu, 23 Jul 2015 11:17:11 -0400 (EDT)
Received: by qkfc129 with SMTP id c129so132498608qkf.1
        for <linux-mm@kvack.org>; Thu, 23 Jul 2015 08:17:11 -0700 (PDT)
Received: from prod-mail-xrelay06.akamai.com (prod-mail-xrelay06.akamai.com. [96.6.114.98])
        by mx.google.com with ESMTP id i35si6185647qkh.110.2015.07.23.08.17.10
        for <linux-mm@kvack.org>;
        Thu, 23 Jul 2015 08:17:10 -0700 (PDT)
Date: Thu, 23 Jul 2015 11:17:07 -0400
From: Eric B Munson <emunson@akamai.com>
Subject: Re: [PATCH v4 00/10] hugetlbfs: add fallocate support
Message-ID: <20150723151707.GB7795@akamai.com>
References: <1437502184-14269-1-git-send-email-mike.kravetz@oracle.com>
 <20150722150647.2597c7e5be9ee1eecc438b6f@linux-foundation.org>
 <1437603594.3298.5.camel@stgolabs.net>
 <20150722153023.e8f15eb4e490f79cc029c8cd@linux-foundation.org>
 <55B024C6.8010504@oracle.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="/NkBOFFp2J2Af1nK"
Content-Disposition: inline
In-Reply-To: <55B024C6.8010504@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Davidlohr Bueso <dave@stgolabs.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, Dave Hansen <dave.hansen@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, David Rientjes <rientjes@google.com>, Hugh Dickins <hughd@google.com>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, Christoph Hellwig <hch@infradead.org>, Michal Hocko <mhocko@suse.cz>, emunson@mgebm.net


--/NkBOFFp2J2Af1nK
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, 22 Jul 2015, Mike Kravetz wrote:

> On 07/22/2015 03:30 PM, Andrew Morton wrote:
> >On Wed, 22 Jul 2015 15:19:54 -0700 Davidlohr Bueso <dave@stgolabs.net> w=
rote:
> >
> >>>
> >>>I didn't know that libhugetlbfs has tests.  I wonder if that makes
> >>>tools/testing/selftests/vm's hugetlbfstest harmful?
> >>
> >>Why harmful? Redundant, maybe(?).
> >
> >The presence of the in-kernel tests will cause people to add stuff to
> >them when it would be better if they were to apply that effort to
> >making libhugetlbfs better.  Or vice versa.
> >
> >Mike's work is an example.  Someone later makes a change to hugetlbfs, r=
uns
> >the kernel selftest and says "yay, everything works", unaware that they
> >just broke fallocate support.
> >
> >>Does anyone even use selftests for
> >>hugetlbfs regression testing? Lets see, we also have these:
> >>
> >>- hugepage-{mmap,shm}.c
> >>- map_hugetlb.c
> >>
> >>There's probably a lot of room for improvement here.
> >
> >selftests is a pretty scrappy place.  It's partly a dumping ground for
> >things so useful test code doesn't just get lost and bitrotted.  Partly
> >a framework so people who add features can easily test them. Partly to
> >provide tools to architecture maintainers when they wire up new
> >syscalls and the like.
> >
> >Unless there's some good reason to retain the hugetlb part of
> >selftests, I'm thinking we should just remove it to avoid
> >distracting/misleading people.  Or possibly move the libhugetlbfs test
> >code into the kernel tree and maintain it there.
>=20
> Adding Eric as he is the libhugetlbfs maintainer.
>=20
> I think removing the hugetlb selftests in the kernel and pointing
> people to libhugetlbfs is the way to go.  From a very quick scan
> of the selftests, I would guess libhugetlbfs covers everything
> in those tests.
>=20
> I'm willing to verify the testing provided by selftests is included
> in libhugetlbfs, and remove selftests if that is the direction we
> want to take.

I would rather see the test suite stay in the library, there are a
number of tests that rely on infrastructure in the library that is not
available in selftests.

I am happy to help with any tests that need to be added/modified in the
library to cover.


--/NkBOFFp2J2Af1nK
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJVsQVzAAoJELbVsDOpoOa9q6gQAM04eghe+So2A2cHKyvgwkoq
4QEfEDp4rnkdPQs6xCJnZpasrquzGoHmO55R+6UpFyZP5ZTVftS17VZIX/vKRnyz
ciD5dCz2pmw0GbV2r58e+qlO2E4aaxKrRzTpckCVLAuPCpPHMUDR9COAfAiQn2Ck
924sgswiADjaCjnWZaGAWcMc/ZEMbUqjIZM4NX89Vj40LMkTUV4YQ5FJ46fE785P
LGJC5YTIWXhyxFnc77NAlxTUnE34W0cyou90QLqnW5eXdIcr7q6BIdj7YWp73TnM
Yk+QMSSKb70BqFfbgyCkUURIRRIHhaQe1AXISsS2Nf6NgUtUzfO8LNjccjXprPpw
OtI7sC6OFCQZgl4zNMl6o+mHbjRG2MD9OIBMpEw284F9XWUwITcKTVKOWaIFwtGD
xCT+CTYdWygBUOr5eTLtXmESgYSE7DeCNMFmM2o+qfc4uhNeB9guhCHjb87BcKJC
nYADXBLk8NGN4YqTuvIUgay8u9edthoDy/G2h5+byMDdyYD32txrsNRzKdgbUQbB
knbwTN5mtoadgk1/Hb7hDFVre0LEM3+R5H8IasjNvg+Oeq9ysRhOUKow4QSru6xm
t/gFRYAYGpLMBBS6XAISxmRPHidzuNOghqrKRFnOjqzrS150AvvqfFm0Ut3hVp/g
78AgZtnPGAKGc+FAfDVQ
=zoaN
-----END PGP SIGNATURE-----

--/NkBOFFp2J2Af1nK--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
