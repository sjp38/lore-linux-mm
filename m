Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f70.google.com (mail-vk0-f70.google.com [209.85.213.70])
	by kanga.kvack.org (Postfix) with ESMTP id 737AB6B0033
	for <linux-mm@kvack.org>; Sat, 16 Dec 2017 02:19:27 -0500 (EST)
Received: by mail-vk0-f70.google.com with SMTP id z85so5347605vkd.22
        for <linux-mm@kvack.org>; Fri, 15 Dec 2017 23:19:27 -0800 (PST)
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id x29si3661425uai.170.2017.12.15.23.19.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Dec 2017 23:19:26 -0800 (PST)
Subject: Re: [PATCH] mm: Reduce memory bloat with THP
References: <1513301359-117568-1-git-send-email-nitin.m.gupta@oracle.com>
 <cb4f46ed-6ca9-4dd3-a21d-7a87ec348da1@linux.vnet.ibm.com>
From: Nitin Gupta <nitin.m.gupta@oracle.com>
Message-ID: <844d6e64-16b4-9f92-17d4-1e059448bda5@oracle.com>
Date: Fri, 15 Dec 2017 23:18:49 -0800
MIME-Version: 1.0
In-Reply-To: <cb4f46ed-6ca9-4dd3-a21d-7a87ec348da1@linux.vnet.ibm.com>
Content-Type: text/plain; charset=windows-1252
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>, linux-mm@kvack.org
Cc: steven.sistare@oracle.com, "Andrew Morton (commit_signer:14/26=54%,commit_signer:10/16=62%,commit_signer:24/26=92%,commit_signer:48/63=76%)" <akpm@linux-foundation.org>, "Ingo Molnar (commit_signer:6/26=23%,authored:4/26=15%,added_lines:17/189=9%,removed_lines:52/150=35%,authored:2/16=12%,added_lines:2/25=8%,authored:4/63=6%)" <mingo@kernel.org>, "Mel Gorman (commit_signer:5/26=19%,authored:2/26=8%)" <mgorman@suse.de>, "Nadav Amit (commit_signer:5/26=19%,authored:2/26=8%,added_lines:32/189=17%,removed_lines:13/150=9%)" <namit@vmware.com>, "Minchan Kim (commit_signer:4/26=15%,authored:3/26=12%,added_lines:14/189=7%,removed_lines:21/150=14%,removed_lines:2/40=5%,commit_signer:5/26=19%,authored:4/63=6%,added_lines:83/883=9%,removed_lines:34/354=10%)" <minchan@kernel.org>, "Kirill A. Shutemov (authored:3/26=12%,commit_signer:4/16=25%,authored:2/16=12%,commit_signer:12/63=19%,authored:8/63=13%,added_lines:214/883=24%,removed_lines:56/354=16%)" <kirill.shutemov@linux.intel.com>, "Peter Zijlstra (authored:2/26=8%,added_lines:72/189=38%,removed_lines:39/150=26%)" <peterz@infradead.org>, "Vegard Nossum (added_lines:21/189=11%)" <vegard.nossum@oracle.com>, "Levin, Alexander (Sasha Levin) (removed_lines:8/150=5%)" <alexander.levin@verizon.com>, "Michal Hocko (commit_signer:7/16=44%,authored:2/16=12%,added_lines:4/25=16%,removed_lines:4/40=10%,commit_signer:7/26=27%,commit_signer:15/63=24%,removed_lines:32/354=9%)" <mhocko@suse.com>, "David Rientjes (commit_signer:3/16=19%,authored:2/16=12%,added_lines:3/25=12%,removed_lines:5/40=12%,added_lines:42/189=22%,removed_lines:9/73=12%)" <rientjes@google.com>, "Vlastimil Babka (commit_signer:3/16=19%)" <vbabka@suse.cz>, "SeongJae Park (authored:1/16=6%,added_lines:3/25=12%)" <sj38.park@gmail.com>, "Shaohua Li (added_lines:3/25=12%,removed_lines:5/40=12%,authored:4/26=15%,removed_lines:11/73=15%)" <shli@fb.com>, "Aneesh Kumar K.V (removed_lines:19/40=48%)" <aneesh.kumar@linux.vnet.ibm.com>, "Andrea Arcangeli (commit_signer:5/26=19%,authored:2/26=8%,added_lines:42/189=22%,removed_lines:4/73=5%)" <aarcange@redhat.com>, "Mike Rapoport (commit_signer:5/26=19%,authored:3/26=12%,added_lines:24/189=13%,removed_lines:21/73=29%)" <rppt@linux.vnet.ibm.com>, "Rik van Riel (added_lines:13/189=7%)" <riel@redhat.com>, "Ross Zwisler (commit_signer:8/63=13%,authored:4/63=6%,added_lines:105/883=12%)" <ross.zwisler@linux.intel.com>, "Jan Kara (commit_signer:7/63=11%)" <jack@suse.cz>, "Dave Jiang (authored:5/63=8%)" <dave.jiang@intel.com>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3NlIChhZGRlZF9saW5lczoxMjgvODgzPTE0JSk=?= <jglisse@redhat.com>, "Matthew Wilcox (added_lines:81/883=9%)" <willy@linux.intel.com>, "Hugh Dickins (removed_lines:65/354=18%)" <hughd@google.com>, "Tobin C Harding (removed_lines:34/354=10%)" <me@tobin.cc>, open list <linux-kernel@vger.kernel.org>

On 12/14/17 9:55 PM, Anshuman Khandual wrote:
> On 12/15/2017 06:58 AM, Nitin Gupta wrote:
>> Currently, if the THP enabled policy is "always", or the mode
>> is "madvise" and a region is marked as MADV_HUGEPAGE, a hugepage
>> is allocated on a page fault if the pud or pmd is empty.  This
>> yields the best VA translation performance, but increases memory
>> consumption if some small page ranges within the huge page are
>> never accessed.
> 
> Right, thats as per design.
> 
>>
>> An alternate behavior for such page faults is to install a
>> hugepage only when a region is actually found to be (almost)
>> fully mapped and active.  This is a compromise between
> 
> That is the async method by analyzing page table segment for
> the process by khugepaged and evaluate if a huge page can be
> installed replacing the existing pages.
> 
>> translation performance and memory consumption.  Currently there
>> is no way for an application to choose this compromise for the
>> page fault conditions above.
> 
> Cant we mark the THP enablement mode as "madvise", then switch
> between MADV_HUGEPAGE/MADV_NOHUGEPAGE to implement this ?
> 

Asking applications to issue MADV_HUGEPAGE/NOHUGEPAGE would make THP
much less 'automatic'. With such a scheme applications would have to
track mapping and active status of each hugepage region and manually
issue MADV_HUGEPAGE again to let khugepaged back it with a hugepage.

Compare above with the approach used by this patch: MADV_DONTNEED is
taken as a hint that application still wants transparent hugepages but
wants to be more conservative with memory usage. khugepaged is still
free to collapse pages as it sees fit without explicit
HUGEPAGE/NOHUGEPAGE madvise hints.

>>
>> With this change, when an application issues MADV_DONTNEED on a
>> memory region, the region is marked as "space-efficient". For
> 
> Isn't it that MADV_DONTNEED should be used for a region where
> there are already pages faulted in and page table populated ?
> Are you suggesting that MADV_DONTNEED should be called upon
> a region just after creation to control it's fault behavior ?
> Thats not what MADV_DONTNEED was meant to be.
> 

No, I'm not suggesting MADV_DONTNEED be called on empty region. The
patch just uses these calls, whenever they are made, as a hint to be
more conservative with memory usage for that vma.

>> such regions, a hugepage is not immediately allocated on first
>> write.  Instead, it is left to the khugepaged thread to do
>> delayed hugepage promotion depending on whether the region is
>> actually mapped and active. When application issues
>> MADV_HUGEPAGE, the region is marked again as non-space-efficient
>> wherein hugepage is allocated on first touch
> 
> But MADV_HUGEPAGE/MADV_NOHUGEPAGE combination should do the trick
> as well.
> 

Thanks,
Nitin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
