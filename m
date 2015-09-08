Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id 139DB6B025A
	for <linux-mm@kvack.org>; Tue,  8 Sep 2015 12:30:06 -0400 (EDT)
Received: by wicfx3 with SMTP id fx3so121543179wic.0
        for <linux-mm@kvack.org>; Tue, 08 Sep 2015 09:30:05 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e8si6819612wjx.133.2015.09.08.09.30.04
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 08 Sep 2015 09:30:05 -0700 (PDT)
Subject: Re: [PATCH v2 1/9] mm/compaction: skip useless pfn when updating
 cached pfn
References: <1440382773-16070-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1440382773-16070-2-git-send-email-iamjoonsoo.kim@lge.com>
 <55DADEC0.5030800@suse.cz> <20150907053528.GB21207@js1304-P5Q-DELUXE>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <55EF0D0B.9050409@suse.cz>
Date: Tue, 8 Sep 2015 18:30:03 +0200
MIME-Version: 1.0
In-Reply-To: <20150907053528.GB21207@js1304-P5Q-DELUXE>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan@kernel.org>

On 09/07/2015 07:35 AM, Joonsoo Kim wrote:
> On Mon, Aug 24, 2015 at 11:07:12AM +0200, Vlastimil Babka wrote:
>> On 08/24/2015 04:19 AM, Joonsoo Kim wrote:
>> 
>> In isolate_freepages_block() this means we actually go logically
>> *back* one pageblock, as the direction is opposite? I know it's not
>> an issue after the redesign patch so you wouldn't notice it when
>> testing the whole series. But there's a non-zero chance that the
>> smaller fixes are merged first and the redesign later...
> 
> Hello, Vlastimil.
> Sorry for long delay. I was on vacation. :)
> I will fix it next time.
> 
> Btw, if possible, could you review the patchset in detail? or do you

I'll try soon...

> have another plan on compaction improvement? Please let me know your
> position to determine future plan of this patchset.
> 
> Thanks.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
