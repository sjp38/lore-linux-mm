Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id D46D06B0071
	for <linux-mm@kvack.org>; Mon,  8 Dec 2014 04:16:36 -0500 (EST)
Received: by mail-wi0-f178.google.com with SMTP id em10so4113643wid.5
        for <linux-mm@kvack.org>; Mon, 08 Dec 2014 01:16:36 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q3si8933148wiy.51.2014.12.08.01.16.35
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 08 Dec 2014 01:16:35 -0800 (PST)
Message-ID: <54856C72.4040705@suse.cz>
Date: Mon, 08 Dec 2014 10:16:34 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH 0/4] enhance compaction success rate
References: <1418022980-4584-1-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1418022980-4584-1-git-send-email-iamjoonsoo.kim@lge.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 12/08/2014 08:16 AM, Joonsoo Kim wrote:
> This patchset aims at increase of compaction success rate. Changes are
> related to compaction finish condition and freepage isolation condition.
>
>  From these changes, I did stress highalloc test in mmtests with nonmovable
> order 7 allocation configuration, and success rate (%) at phase 1 are,
>
> Base	Patch-1	Patch-3	Patch-4
> 55.00	57.00	62.67	64.00
>
> And, compaction success rate (%) on same test are,
>
> Base	Patch-1	Patch-3	Patch-4
> 18.47	28.94	35.13	41.50

Did you test Patch-2 separately? Any difference to Patch 1?

> This patchset is based on my tracepoint update on compaction.
>
> https://lkml.org/lkml/2014/12/3/71
>
> Joonsoo Kim (4):
>    mm/compaction: fix wrong order check in compact_finished()
>    mm/page_alloc: expands broken freepage to proper buddy list when
>      steal
>    mm/compaction: enhance compaction finish condition
>    mm/compaction: stop the isolation when we isolate enough freepage
>
>   include/linux/mmzone.h      |    3 ++
>   include/trace/events/kmem.h |    7 +++--
>   mm/compaction.c             |   48 ++++++++++++++++++++++------
>   mm/internal.h               |    1 +
>   mm/page_alloc.c             |   73 +++++++++++++++++++++++++------------------
>   5 files changed, 89 insertions(+), 43 deletions(-)
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
