Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f181.google.com (mail-qc0-f181.google.com [209.85.216.181])
	by kanga.kvack.org (Postfix) with ESMTP id 9FF6D6B0032
	for <linux-mm@kvack.org>; Sat, 31 Jan 2015 05:18:11 -0500 (EST)
Received: by mail-qc0-f181.google.com with SMTP id l6so24113053qcy.12
        for <linux-mm@kvack.org>; Sat, 31 Jan 2015 02:18:11 -0800 (PST)
Received: from BLU004-OMC2S33.hotmail.com (blu004-omc2s33.hotmail.com. [65.55.111.108])
        by mx.google.com with ESMTPS id r2si16735940qcq.9.2015.01.31.02.18.10
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Sat, 31 Jan 2015 02:18:10 -0800 (PST)
Message-ID: <BLU436-SMTP107979843453A8D45167B5D833E0@phx.gbl>
Date: Sat, 31 Jan 2015 18:17:55 +0800
From: Zhang Yanfei <zhangyanfei.ok@hotmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 2/4] mm/compaction: stop the isolation when we isolate
 enough freepage
References: <1422621252-29859-1-git-send-email-iamjoonsoo.kim@lge.com> <1422621252-29859-3-git-send-email-iamjoonsoo.kim@lge.com> <BLU436-SMTP105DFBF63EAF672F3272FFA833E0@phx.gbl> <54CC92FD.5000601@suse.cz>
In-Reply-To: <54CC92FD.5000601@suse.cz>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <js1304@gmail.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

At 2015/1/31 16:31, Vlastimil Babka wrote:
> On 01/31/2015 08:49 AM, Zhang Yanfei wrote:
>> Hello,
>>
>> At 2015/1/30 20:34, Joonsoo Kim wrote:
>>
>> Reviewed-by: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
>>
>> IMHO, the patch making the free scanner move slower makes both scanners
>> meet further. Before this patch, if we isolate too many free pages and even 
>> after we release the unneeded free pages later the free scanner still already
>> be there and will be moved forward again next time -- the free scanner just
>> cannot be moved back to grab the free pages we released before no matter where
>> the free pages in, pcp or buddy. 
> 
> It can be actually moved back. If we are releasing free pages, it means the
> current compaction is terminating, and it will set zone->compact_cached_free_pfn
> back to the position of the released free page that was furthest back. The next
> compaction will start from the cached free pfn.

Yeah, you are right. I missed the release_freepages(). Thanks!

> 
> It is however possible that another compaction runs in parallel and has
> progressed further and overwrites the cached free pfn.
> 

Hmm, maybe.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
