Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f177.google.com (mail-pf0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 1BEC66B0005
	for <linux-mm@kvack.org>; Thu, 21 Jan 2016 23:41:19 -0500 (EST)
Received: by mail-pf0-f177.google.com with SMTP id n128so35207482pfn.3
        for <linux-mm@kvack.org>; Thu, 21 Jan 2016 20:41:19 -0800 (PST)
Received: from e28smtp02.in.ibm.com (e28smtp02.in.ibm.com. [125.16.236.2])
        by mx.google.com with ESMTPS id gy5si6782613pac.83.2016.01.21.20.41.17
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 21 Jan 2016 20:41:18 -0800 (PST)
Received: from localhost
	by e28smtp02.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Fri, 22 Jan 2016 10:11:15 +0530
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay01.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u0M4fD7c44892252
	for <linux-mm@kvack.org>; Fri, 22 Jan 2016 10:11:14 +0530
Received: from d28av03.in.ibm.com (localhost [127.0.0.1])
	by d28av03.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u0M4fDqg026753
	for <linux-mm@kvack.org>; Fri, 22 Jan 2016 10:11:13 +0530
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [LSF/MM ATTEND] 2016: Requests to attend MM-summit
Date: Fri, 22 Jan 2016 10:11:12 +0530
Message-ID: <87k2n2usyf.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org


Hi,

I would like to attend LSF/MM this year (2016).

My main interest is in MM related topics although I am also interested
in the btrfs status discussion (particularly related to subpage size block
size topic), if we are having one. Most of my recent work in the kernel is
related to adding ppc64 support for different MM features. My current focus
is on adding Linux support for the new radix MMU model of Power9.

Topics of interest include:

* CMA allocator issues:
  (1) order zero allocation failures:
      We are observing order zero non-movable allocation failures in kernel
with CMA configured. We don't start a reclaim because our free memory check
does not consider free_cma. Hence the reclaim code assume we have enough fr=
ee
pages. Joonsoo Kim tried to fix this with his ZOME_CMA patches. I would
like to discuss the challenges in getting this merged upstream.
https://lkml.org/lkml/2015/2/12/95 (ZONE_CMA)

Others needed for the discussion:
Joonsoo Kim <iamjoonsoo.kim@lge.com>

  (2) CMA allocation failures due to pinned pages in the region:
      We allow only movable allocation from the CMA region to enable us
to migrate those pages later when we get a CMA allocation request. But
if we pin those movable pages, we will fail the migration which can result
in CMA allocation failure. One such report can be found here.
http://article.gmane.org/gmane.linux.kernel.mm/136738

Peter Zijlstra's VM_PINNED patch series should help in fixing the issue. I =
would
like to discuss what needs to be done to get this patch series merged upstr=
eam
https://lkml.org/lkml/2014/5/26/345 (VM_PINNED)

Others needed for the discussion:
Peter Zijlstra <peterz@infradead.org>

* Improvements to tlb flush
    Archiectures like ppc64 can do range based tlb flush and for that we ne=
ed
to know the page size used to map the virtual address range. I would like
to discuss changes to mmu gather and tlb flush api that will help in effici=
ent
implementation of tlb flush for ppc64.
   (1) MMU gather improvements
       https://github.com/kvaneesh/linux/commit/215b9c7c03bb8d742349e2aefaa=
dcf8cc0c04dd8
       https://github.com/kvaneesh/linux/commit/43bd9e91a841bbc9e3c6ee56a4d=
12ed00019718c
   (2) different APIs to flush hugepage tlb mappings.
       https://github.com/kvaneesh/linux/commit/b8a78933fea93cb0b2978868e59=
a0a4b12eb92eb
       https://github.com/kvaneesh/linux/commit/049d361a59a3342c2ce5a4feae6=
1dce4974af226

NOTE: I haven't posted these changes yet to the list because of dependent p=
atches getting reviewed. But should
have them available on the list before LSF/MM.

* HMM status (Heterogeneous Memory Management)

  I would like to discuss the roadblocks w.r.t merging HMM patchset upstrea=
m.
http://article.gmane.org/gmane.linux.kernel.mm/140229

Others needed for the discussion:
J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
