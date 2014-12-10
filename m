Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id E972F6B0032
	for <linux-mm@kvack.org>; Wed, 10 Dec 2014 04:55:04 -0500 (EST)
Received: by mail-wi0-f171.google.com with SMTP id bs8so10601052wib.4
        for <linux-mm@kvack.org>; Wed, 10 Dec 2014 01:55:04 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id hu8si19525685wib.9.2014.12.10.01.55.03
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 10 Dec 2014 01:55:03 -0800 (PST)
Message-ID: <54881876.70309@suse.cz>
Date: Wed, 10 Dec 2014 10:55:02 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH 2/4] mm/page_alloc: expands broken freepage to proper
 buddy list when steal
References: <1418022980-4584-1-git-send-email-iamjoonsoo.kim@lge.com> <1418022980-4584-3-git-send-email-iamjoonsoo.kim@lge.com> <54856F88.8090300@suse.cz> <20141210063840.GC13371@js1304-P5Q-DELUXE>
In-Reply-To: <20141210063840.GC13371@js1304-P5Q-DELUXE>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 12/10/2014 07:38 AM, Joonsoo Kim wrote:
> On Mon, Dec 08, 2014 at 10:29:44AM +0100, Vlastimil Babka wrote:
>> On 12/08/2014 08:16 AM, Joonsoo Kim wrote:
>>> There is odd behaviour when we steal freepages from other migratetype
>>> buddy list. In try_to_steal_freepages(), we move all freepages in
>>> the pageblock that founded freepage is belong to to the request
>>> migratetype in order to mitigate fragmentation. If the number of moved
>>> pages are enough to change pageblock migratetype, there is no problem. If
>>> not enough, we don't change pageblock migratetype and add broken freepages
>>> to the original migratetype buddy list rather than request migratetype
>>> one. For me, this is odd, because we already moved all freepages in this
>>> pageblock to the request migratetype. This patch fixes this situation to
>>> add broken freepages to the request migratetype buddy list in this case.
>>
>> I'd rather split the fix from the refactoring. And maybe my
>> description is longer, but easier to understand? (I guess somebody
>> else should judge this)
>
> Your patch is much better to understand than mine. :)
> No need to judge from somebody else.
> After your patch is merged, I will resubmit these on top of it.

Thanks. I'm doing another evaluation focusing on number of unmovable 
pageblocks as Mel suggested and then resubmit with tracepoint fixed.

Vlastimil

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
