Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 636096B0003
	for <linux-mm@kvack.org>; Sun, 28 Jan 2018 07:52:11 -0500 (EST)
Received: by mail-qt0-f200.google.com with SMTP id z15so733602qti.16
        for <linux-mm@kvack.org>; Sun, 28 Jan 2018 04:52:11 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id l12si6790146qtk.31.2018.01.28.04.52.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 28 Jan 2018 04:52:10 -0800 (PST)
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w0SCmab4015304
	for <linux-mm@kvack.org>; Sun, 28 Jan 2018 07:52:10 -0500
Received: from e06smtp12.uk.ibm.com (e06smtp12.uk.ibm.com [195.75.94.108])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2fs7mt2a43-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Sun, 28 Jan 2018 07:52:09 -0500
Received: from localhost
	by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Sun, 28 Jan 2018 12:52:08 -0000
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Subject: [LSF/MM ATTEND] Requests to attend MM Summit 2018
Date: Sun, 28 Jan 2018 18:22:01 +0530
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Message-Id: <3cf31aa1-6886-a01c-57ff-143c165a74e3@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "lsf-pc@lists.linux-foundation.org" <lsf-pc@lists.linux-foundation.org>, linux-mm@kvack.org
Cc: Mike Kravetz <mike.kravetz@oracle.com>, Laura Abbott <labbott@redhat.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, John Hubbard <jhubbard@nvidia.com>, Jerome Glisse <jglisse@redhat.com>, Michal Hocko <mhocko@kernel.org>

Hello,

Apart from the "Rethinking NUMA" topic which I have proposed, I would
like to attend 2018 LSFMM to discuss following different topics.

A. HMM: (Jerome Glisse, John Hubbard, Michal Hocko)

I am interested in discussing future plans for HMM (including HMM CDM)
including improvement to mmu_notifier framework carrying more context
into it's callback etc.

B. HugeTLB: (Mike Kravetz, Michal Hocko)

I am interested in discussing about anything related to HugeTLB page
migration, SW/HW poisoning of HugeTLB pages including how to handle
memory failures in a smaller section of the HugeTLB page. I am also
interested in anything related to runtime gigantic HugeTLB pages
allocation and it's migration/poisoning etc.

C. CMA (Mike Kravetz, Laura Abbott, Joonsoo Kim)

1. Supporting hotplug memory as a CMA region

There are situations where a platform identified specific PFN range
can only be used for some low level debug/tracing purpose. The same
PFN range must be shared between multiple guests on a need basis,
hence its logical to expect the range to be hot add/removable in
each guest. But once available and online in the guest, it would
require a sort of guarantee of a large order allocation (almost the
entire range) into the memory to use it for aforesaid purpose.
Plugging the memory as ZONE_MOVABLE with MIGRATE_CMA makes sense in
this scenario but its not supported at the moment.

This basically extends the idea of relaxing CMA reservation and
declaration restrictions as pointed by Mike Kravetz.

2. Adding NUMA

Adding NUMA tracking information to individual CMA areas and use it
for alloc_cma() interface. In POWER8 KVM implementation, guest HPT
(Hash Page Table) is allocated from a predefined CMA region. NUMA
aligned allocation for HPT for any given guest VM can help improve
performance.

3. Reducing CMA allocation failures

CMA allocation failures are primarily because of not being unable to
isolate or migrate the given PFN range (Inside alloc_contig_range).
Is there a way to reduce the failure chances ?

D. MAP_CONTIG (Mike Kravetz, Laura Abbott, Michal Hocko)

I understand that a recent RFC from Mike Kravetz got debated but without
any conclusion about the viability to add MAP_CONTIG option for the user
space to request large contiguous physical memory. I will be really
interested to discuss any future plans on how kernel can help user space
with large physical contiguous memory if need arises.

(MAP_CONTIG RFC https://lkml.org/lkml/2017/10/3/992)

- Anshuman

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
