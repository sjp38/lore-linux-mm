Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7DB056B0038
	for <linux-mm@kvack.org>; Wed,  7 Sep 2016 01:12:18 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id 29so3065545lfv.2
        for <linux-mm@kvack.org>; Tue, 06 Sep 2016 22:12:18 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id x13si2237555wmf.38.2016.09.06.22.12.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Sep 2016 22:12:16 -0700 (PDT)
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u8757tnb135022
	for <linux-mm@kvack.org>; Wed, 7 Sep 2016 01:12:15 -0400
Received: from e28smtp07.in.ibm.com (e28smtp07.in.ibm.com [125.16.236.7])
	by mx0b-001b2d01.pphosted.com with ESMTP id 25a31b48au-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 07 Sep 2016 01:12:15 -0400
Received: from localhost
	by e28smtp07.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Wed, 7 Sep 2016 10:42:11 +0530
Received: from d28relay10.in.ibm.com (d28relay10.in.ibm.com [9.184.220.161])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id 58BBFE005A
	for <linux-mm@kvack.org>; Wed,  7 Sep 2016 10:41:16 +0530 (IST)
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay10.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u875C3hs25886946
	for <linux-mm@kvack.org>; Wed, 7 Sep 2016 10:42:03 +0530
Received: from d28av02.in.ibm.com (localhost [127.0.0.1])
	by d28av02.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u875C58p022497
	for <linux-mm@kvack.org>; Wed, 7 Sep 2016 10:42:05 +0530
Date: Wed, 07 Sep 2016 10:42:01 +0530
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 5/5] mm: cleanup pfn_t usage in track_pfn_insert()
References: <147318056046.30325.5100892122988191500.stgit@dwillia2-desk3.amr.corp.intel.com> <147318058712.30325.12749411762275637099.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <147318058712.30325.12749411762275637099.stgit@dwillia2-desk3.amr.corp.intel.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Message-Id: <57CFA1A1.7060704@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>, linux-nvdimm@lists.01.org
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org

On 09/06/2016 10:19 PM, Dan Williams wrote:
> Now that track_pfn_insert() is no longer used in the DAX path, it no
> longer needs to comprehend pfn_t values.
> 
> Signed-off-by: Dan Williams <dan.j.williams@intel.com>
> ---
>  arch/x86/mm/pat.c             |    4 ++--
>  include/asm-generic/pgtable.h |    4 ++--
>  mm/memory.c                   |    2 +-
>  3 files changed, 5 insertions(+), 5 deletions(-)

A small nit. Should not the arch/x86/mm/pat.c changes be separated out
into a different patch ? Kind of faced little bit problem separating out
generic core mm changes to that of arch specific mm changes when going
through the commits in retrospect.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
