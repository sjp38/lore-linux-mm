Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 617056B0006
	for <linux-mm@kvack.org>; Tue, 15 May 2018 01:19:35 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id l85-v6so12168217pfb.18
        for <linux-mm@kvack.org>; Mon, 14 May 2018 22:19:35 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id i3-v6si10988011pld.189.2018.05.14.22.19.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 May 2018 22:19:33 -0700 (PDT)
From: "Huang\, Ying" <ying.huang@intel.com>
Subject: Re: [PATCH -mm] mm, hugetlb: Pass fault address to no page handler
References: <20180515005756.28942-1-ying.huang@intel.com>
	<2f97bdea-d873-19d7-ff55-9a625bdfdd67@oracle.com>
Date: Tue, 15 May 2018 13:19:29 +0800
In-Reply-To: <2f97bdea-d873-19d7-ff55-9a625bdfdd67@oracle.com> (Mike Kravetz's
	message of "Mon, 14 May 2018 20:25:23 -0700")
Message-ID: <87d0xxzeam.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andi Kleen <andi.kleen@intel.com>, Jan Kara <jack@suse.cz>, Michal Hocko <mhocko@suse.com>, Matthew Wilcox <mawilcox@microsoft.com>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Shaohua Li <shli@fb.com>, Christopher Lameter <cl@linux.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Punit Agrawal <punit.agrawal@arm.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>

Mike Kravetz <mike.kravetz@oracle.com> writes:

> On 05/14/2018 05:57 PM, Huang, Ying wrote:
>> From: Huang Ying <ying.huang@intel.com>
>> 
>> This is to take better advantage of huge page clearing
>> optimization (c79b57e462b5d, "mm: hugetlb: clear target sub-page last
>> when clearing huge page").  Which will clear to access sub-page last
>> to avoid the cache lines of to access sub-page to be evicted when
>> clearing other sub-pages.  This needs to get the address of the
>> sub-page to access, that is, the fault address inside of the huge
>> page.  So the hugetlb no page fault handler is changed to pass that
>> information.  This will benefit workloads which don't access the begin
>> of the huge page after page fault.
>> 
>> With this patch, the throughput increases ~28.1% in vm-scalability
>> anon-w-seq test case with 88 processes on a 2 socket Xeon E5 2699 v4
>> system (44 cores, 88 threads).  The test case creates 88 processes,
>> each process mmap a big anonymous memory area and writes to it from
>> the end to the begin.  For each process, other processes could be seen
>> as other workload which generates heavy cache pressure.  At the same
>> time, the cache miss rate reduced from ~36.3% to ~25.6%, the
>> IPC (instruction per cycle) increased from 0.3 to 0.37, and the time
>> spent in user space is reduced ~19.3%
>
> Since this patch only addresses hugetlbfs huge pages, I would suggest
> making that more explicit in the commit message.

Sure.  Will revise it!

> Other than that, the changes look fine to me.
>
>> Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
>
> Reviewed-by: Mike Kravetz <mike.kravetz@oracle.com>

Thanks!

Best Regards,
Huang, Ying
