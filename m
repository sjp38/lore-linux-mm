Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f176.google.com (mail-we0-f176.google.com [74.125.82.176])
	by kanga.kvack.org (Postfix) with ESMTP id 5FFB36B0032
	for <linux-mm@kvack.org>; Mon,  5 Jan 2015 09:22:46 -0500 (EST)
Received: by mail-we0-f176.google.com with SMTP id w61so7969652wes.35
        for <linux-mm@kvack.org>; Mon, 05 Jan 2015 06:22:46 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id dd4si54700516wjc.65.2015.01.05.06.22.44
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 05 Jan 2015 06:22:45 -0800 (PST)
Message-ID: <54AA9E09.7040308@suse.cz>
Date: Mon, 05 Jan 2015 15:22:01 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH V3 0/4] Reducing parameters of alloc_pages* family of
 functions
References: <1418400805-4661-1-git-send-email-vbabka@suse.cz> <20141218132619.4e6b349d0aa1744c41f985c7@linux-foundation.org>
In-Reply-To: <20141218132619.4e6b349d0aa1744c41f985c7@linux-foundation.org>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>

On 12/18/2014 10:26 PM, Andrew Morton wrote:
> On Fri, 12 Dec 2014 17:13:21 +0100 Vlastimil Babka <vbabka@suse.cz> wrote:
> 
>> Vlastimil Babka (4):
>>   mm: set page->pfmemalloc in prep_new_page()
>>   mm, page_alloc: reduce number of alloc_pages* functions' parameters
>>   mm: reduce try_to_compact_pages parameters
>>   mm: microoptimize zonelist operations
> 
> That all looks pretty straightforward.  It would be nice to have a
> summary of the code-size and stack-usage changes for the whole
> patchset.

OK

> Can we move `struct alloc_context' into mm/internal.h?

Only if we moved also try_to_compact_pages() declaration from
include/linux/compaction.h to mm/internal.h. I guess it's not a bad idea, as
it's a MM-only function and mm/internal.h already contains compaction stuff.

> I pity the poor schmuck who has to maintain this patchset for 2 months.
> [2/4] already throws a large pile of rejects against page_alloc.c so
> can you please refresh/retest/resend?

Right :)

Vlastimil


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
