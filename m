Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id EFF046B0033
	for <linux-mm@kvack.org>; Thu,  5 Oct 2017 01:08:42 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id r202so8423994wmd.1
        for <linux-mm@kvack.org>; Wed, 04 Oct 2017 22:08:42 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id b12si1026235edm.95.2017.10.04.22.08.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Oct 2017 22:08:41 -0700 (PDT)
Received: from pps.filterd (m0098413.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v9554TIJ070553
	for <linux-mm@kvack.org>; Thu, 5 Oct 2017 01:08:39 -0400
Received: from e23smtp03.au.ibm.com (e23smtp03.au.ibm.com [202.81.31.145])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2dd94jduyu-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 05 Oct 2017 01:08:39 -0400
Received: from localhost
	by e23smtp03.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Thu, 5 Oct 2017 15:08:36 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay06.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v9558XNG30933202
	for <linux-mm@kvack.org>; Thu, 5 Oct 2017 16:08:33 +1100
Received: from d23av02.au.ibm.com (localhost [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v9558OJg017820
	for <linux-mm@kvack.org>; Thu, 5 Oct 2017 16:08:24 +1100
Subject: Re: [PATCH 2/2] mm: Consolidate page table accounting
References: <20171004163648.11234-1-kirill.shutemov@linux.intel.com>
 <20171004163648.11234-2-kirill.shutemov@linux.intel.com>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Thu, 5 Oct 2017 10:38:29 +0530
MIME-Version: 1.0
In-Reply-To: <20171004163648.11234-2-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <3aabab03-7f0a-e82e-a1c2-79120aed5ace@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, Michal Hocko <mhocko@kernel.org>

On 10/04/2017 10:06 PM, Kirill A. Shutemov wrote:
> This patch switches page table accounting to single counter from
> three -- nr_ptes, nr_pmds and nr_puds.
> 
> mm->pgtables_bytes is now used to account page table levels. We use
> bytes, because page table size for different levels of page table tree
> may be different.
> 
> The change has user-visible effect: we don't have VmPMD and VmPUD
> reported in /proc/[pid]/status. Not sure if anybody uses them.
> (As alternative, we can always report 0 kB for them.)
> 
> OOM-killer report is also slightly changed: we now report pgtables_bytes
> instead of nr_ptes, nr_pmd, nr_puds.

Could you please mention the motivation of doing this ? Why we are
consolidating the counters which also changes /proc/ interface as
well as OOM report ? What is the benefit ?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
