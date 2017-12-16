Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 21C576B0033
	for <linux-mm@kvack.org>; Sat, 16 Dec 2017 02:27:28 -0500 (EST)
Received: by mail-qk0-f197.google.com with SMTP id z136so7293340qka.13
        for <linux-mm@kvack.org>; Fri, 15 Dec 2017 23:27:28 -0800 (PST)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id w22si8615450qtb.404.2017.12.15.23.27.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Dec 2017 23:27:27 -0800 (PST)
Subject: Re: [PATCH] mm: Reduce memory bloat with THP
References: <1513301359-117568-1-git-send-email-nitin.m.gupta@oracle.com>
 <20171215100151.b7j66q7sg2wsrex3@node.shutemov.name>
From: Nitin Gupta <nitin.m.gupta@oracle.com>
Message-ID: <efad97ec-b28d-ef84-75ee-02ac0d3378f1@oracle.com>
Date: Fri, 15 Dec 2017 23:21:46 -0800
MIME-Version: 1.0
In-Reply-To: <20171215100151.b7j66q7sg2wsrex3@node.shutemov.name>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: linux-mm@kvack.org, steven.sistare@oracle.com, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Mel Gorman <mgorman@suse.de>, Nadav Amit <namit@vmware.com>, Minchan Kim <minchan@kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Vegard Nossum <vegard.nossum@oracle.com>, "Levin, Alexander (Sasha Levin)" <alexander.levin@verizon.com>, Michal Hocko <mhocko@suse.com>, David Rientjes <rientjes@google.com>, Vlastimil Babka <vbabka@suse.cz>, SeongJae Park <sj38.park@gmail.com>, Shaohua Li <shli@fb.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Jan Kara <jack@suse.cz>, Dave Jiang <dave.jiang@intel.com>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Matthew Wilcox <willy@linux.intel.com>, Hugh Dickins <hughd@google.com>, Tobin C Harding <me@tobin.cc>, open list <linux-kernel@vger.kernel.org>

On 12/15/17 2:01 AM, Kirill A. Shutemov wrote:
> On Thu, Dec 14, 2017 at 05:28:52PM -0800, Nitin Gupta wrote:
>> diff --git a/mm/madvise.c b/mm/madvise.c
>> index 751e97a..b2ec07b 100644
>> --- a/mm/madvise.c
>> +++ b/mm/madvise.c
>> @@ -508,6 +508,7 @@ static long madvise_dontneed_single_vma(struct vm_area_struct *vma,
>>  					unsigned long start, unsigned long end)
>>  {
>>  	zap_page_range(vma, start, end - start);
>> +	vma->space_efficient = true;
>>  	return 0;
>>  }
>>  
> 
> And this modifies vma without down_write(mmap_sem).
> 

I thought this function was always called with mmmap_sem write locked.
I will check again.

- Nitin


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
