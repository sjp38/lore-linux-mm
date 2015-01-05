Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f175.google.com (mail-lb0-f175.google.com [209.85.217.175])
	by kanga.kvack.org (Postfix) with ESMTP id D92746B0032
	for <linux-mm@kvack.org>; Mon,  5 Jan 2015 11:01:17 -0500 (EST)
Received: by mail-lb0-f175.google.com with SMTP id z11so9877508lbi.6
        for <linux-mm@kvack.org>; Mon, 05 Jan 2015 08:01:17 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g1si62498258lag.18.2015.01.05.08.01.16
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 05 Jan 2015 08:01:16 -0800 (PST)
Message-ID: <54AAB548.3050807@suse.cz>
Date: Mon, 05 Jan 2015 17:01:12 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH V3 0/4] Reducing parameters of alloc_pages* family of
 functions
References: <1418400805-4661-1-git-send-email-vbabka@suse.cz> <20141218132619.4e6b349d0aa1744c41f985c7@linux-foundation.org> <54AA9E09.7040308@suse.cz>
In-Reply-To: <54AA9E09.7040308@suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>

On 01/05/2015 03:22 PM, Vlastimil Babka wrote:
> On 12/18/2014 10:26 PM, Andrew Morton wrote:
>> On Fri, 12 Dec 2014 17:13:21 +0100 Vlastimil Babka <vbabka@suse.cz> wrote:
>> 
>>> Vlastimil Babka (4):
>>>   mm: set page->pfmemalloc in prep_new_page()
>>>   mm, page_alloc: reduce number of alloc_pages* functions' parameters
>>>   mm: reduce try_to_compact_pages parameters
>>>   mm: microoptimize zonelist operations
>> 
>> That all looks pretty straightforward.  It would be nice to have a
>> summary of the code-size and stack-usage changes for the whole
>> patchset.
> 
> OK
> 
>> Can we move `struct alloc_context' into mm/internal.h?
> 
> Only if we moved also try_to_compact_pages() declaration from
> include/linux/compaction.h to mm/internal.h. I guess it's not a bad idea, as
> it's a MM-only function and mm/internal.h already contains compaction stuff.

Hm, nope. The !CONFIG_COMPACTION variant of try_to_compact_pages() is static
inline that returns COMPACT_CONTINUE, which is defined in compaction.h.
Another solution is to add a "forward" declaration (not actually followed later
by a full definition) of struct alloc_context into compaction.h. Seems to work
here, but I'm not sure if such thing is allowed?

>> I pity the poor schmuck who has to maintain this patchset for 2 months.
>> [2/4] already throws a large pile of rejects against page_alloc.c so
>> can you please refresh/retest/resend?
> 
> Right :)
> 
> Vlastimil
> 
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
