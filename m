Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id DD8C56B037C
	for <linux-mm@kvack.org>; Tue,  8 Aug 2017 05:46:54 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id 24so28116288pfk.5
        for <linux-mm@kvack.org>; Tue, 08 Aug 2017 02:46:54 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id e7si655886plk.249.2017.08.08.02.46.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Aug 2017 02:46:53 -0700 (PDT)
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v789jR80143141
	for <linux-mm@kvack.org>; Tue, 8 Aug 2017 05:46:52 -0400
Received: from e23smtp06.au.ibm.com (e23smtp06.au.ibm.com [202.81.31.148])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2c7ak3h6c7-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 08 Aug 2017 05:46:52 -0400
Received: from localhost
	by e23smtp06.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Tue, 8 Aug 2017 19:46:49 +1000
Received: from d23av05.au.ibm.com (d23av05.au.ibm.com [9.190.234.119])
	by d23relay07.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v789kdea28639246
	for <linux-mm@kvack.org>; Tue, 8 Aug 2017 19:46:47 +1000
Received: from d23av05.au.ibm.com (localhost [127.0.0.1])
	by d23av05.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v789kEM9013565
	for <linux-mm@kvack.org>; Tue, 8 Aug 2017 19:46:15 +1000
Subject: Re: [RFC v5 01/11] mm: Dont assume page-table invariance during
 faults
References: <1497635555-25679-1-git-send-email-ldufour@linux.vnet.ibm.com>
 <1497635555-25679-2-git-send-email-ldufour@linux.vnet.ibm.com>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Tue, 8 Aug 2017 15:15:50 +0530
MIME-Version: 1.0
In-Reply-To: <1497635555-25679-2-git-send-email-ldufour@linux.vnet.ibm.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <57cbb4ca-7f04-ac50-3321-2c34ac08307b@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laurent Dufour <ldufour@linux.vnet.ibm.com>, paulmck@linux.vnet.ibm.com, peterz@infradead.org, akpm@linux-foundation.org, kirill@shutemov.name, ak@linux.intel.com, mhocko@kernel.org, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com, Tim Chen <tim.c.chen@linux.intel.com>

On 06/16/2017 11:22 PM, Laurent Dufour wrote:
> From: Peter Zijlstra <peterz@infradead.org>
> 
> One of the side effects of speculating on faults (without holding
> mmap_sem) is that we can race with free_pgtables() and therefore we
> cannot assume the page-tables will stick around.
> 
> Remove the relyance on the pte pointer.

Looking into other parts of the series, it seemed like now we have
sequence lock both at MM and VMA level but then after that we still
need to take page table lock before handling page faults (in turn
manipulating PTE which includes swap in paths as well). Is not that
true ?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
