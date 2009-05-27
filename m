Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id CBB7E6B0055
	for <linux-mm@kvack.org>; Wed, 27 May 2009 12:39:53 -0400 (EDT)
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e32.co.us.ibm.com (8.13.1/8.13.1) with ESMTP id n4RGavmq028911
	for <linux-mm@kvack.org>; Wed, 27 May 2009 10:36:57 -0600
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n4RGeTMZ148614
	for <linux-mm@kvack.org>; Wed, 27 May 2009 10:40:29 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n4RGeSLW032459
	for <linux-mm@kvack.org>; Wed, 27 May 2009 10:40:29 -0600
Date: Wed, 27 May 2009 17:40:25 +0100
From: Eric B Munson <ebmunson@us.ibm.com>
Subject: Re: [PATCH 2/2] mm: Account for MAP_SHARED mappings using
	VM_MAYSHARE and not VM_SHARED in hugetlbfs
Message-ID: <20090527164025.GC5145@us.ibm.com>
References: <1243422749-6256-1-git-send-email-mel@csn.ul.ie> <1243422749-6256-3-git-send-email-mel@csn.ul.ie>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="GZVR6ND4mMseVXL/"
Content-Disposition: inline
In-Reply-To: <1243422749-6256-3-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, stable@kernel.org, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, starlight@binnacle.cx, Adam Litke <agl@us.ibm.com>, Andy Whitcroft <apw@canonical.com>, wli@movementarian.org
List-ID: <linux-mm.kvack.org>


--GZVR6ND4mMseVXL/
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, 27 May 2009, Mel Gorman wrote:

> hugetlbfs reserves huge pages but does not fault them at mmap() time to e=
nsure
> that future faults succeed. The reservation behaviour differs depending on
> whether the mapping was mapped MAP_SHARED or MAP_PRIVATE. For MAP_SHARED
> mappings, hugepages are reserved when mmap() is first called and are trac=
ked
> based on information associated with the inode. Other processes mapping
> MAP_SHARED use the same reservation. MAP_PRIVATE track the reservations
> based on the VMA created as part of the mmap() operation. Each process
> mapping MAP_PRIVATE must make its own reservation.
>=20
> hugetlbfs currently checks if a VMA is MAP_SHARED with the VM_SHARED flag=
 and
> not VM_MAYSHARE.  For file-backed mappings, such as hugetlbfs, VM_SHARED =
is
> set only if the mapping is MAP_SHARED and the file was opened read-write.=
 If a
> shared memory mapping was mapped shared-read-write for populating of data=
 and
> mapped shared-read-only by other processes, then hugetlbfs would account =
for
> the mapping as if it was MAP_PRIVATE.  This causes processes to fail to m=
ap
> the file MAP_SHARED even though it should succeed as the reservation is t=
here.
>=20
> This patch alters mm/hugetlb.c and replaces VM_SHARED with VM_MAYSHARE wh=
en
> the intent of the code was to check whether the VMA was mapped MAP_SHARED
> or MAP_PRIVATE.
>=20
> Signed-off-by: Mel Gorman <mel@csn.ul.ie>

I tested this patch on both x86_64 and ppc64 using 2.6.30-rc7 with the libh=
ugetlbfs
test suite and everything looks good.

Acked-by: Eric B Munson <ebmunson@us.ibm.com>
Tested-by: Eric B Munson <ebmunson@us.ibm.com>

--GZVR6ND4mMseVXL/
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAkodbPkACgkQsnv9E83jkzp8WgCg1pjmpoxQXXZgnPwTlFDRtYNK
cw8AoIzWvhKvPJVOnTwkUzwhiCdpgSTc
=w+yF
-----END PGP SIGNATURE-----

--GZVR6ND4mMseVXL/--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
