Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id 62C196B0038
	for <linux-mm@kvack.org>; Fri, 26 Jun 2015 07:22:11 -0400 (EDT)
Received: by wicnd19 with SMTP id nd19so42477650wic.1
        for <linux-mm@kvack.org>; Fri, 26 Jun 2015 04:22:11 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e1si57978049wjp.38.2015.06.26.04.22.09
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 26 Jun 2015 04:22:09 -0700 (PDT)
Message-ID: <558D35DF.8080008@suse.cz>
Date: Fri, 26 Jun 2015 13:22:07 +0200
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 00/10] redesign compaction algorithm
References: <1435193121-25880-1-git-send-email-iamjoonsoo.kim@lge.com>	<20150625110314.GJ11809@suse.de>	<CAAmzW4OnE7A6sxEDFRcp9jbuxkYkJvJw_PH1TBFtS0nZOmrVGg@mail.gmail.com>	<20150625172550.GA26927@suse.de>	<CAAmzW4PMWOaAa0bd7xVr5Jz=xVgqMw8G=UFOwhUGuyLL9EFbHA@mail.gmail.com>	<558C4EF0.2010603@suse.cz> <CAAmzW4P0H2dxVa9zMBkKEyX-R3at-xo-pBLMS07j=svQzYwvBQ@mail.gmail.com>
In-Reply-To: <CAAmzW4P0H2dxVa9zMBkKEyX-R3at-xo-pBLMS07j=svQzYwvBQ@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>
Cc: Mel Gorman <mgorman@suse.de>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan@kernel.org>

On 06/26/2015 04:14 AM, Joonsoo Kim wrote:
> 2015-06-26 3:56 GMT+09:00 Vlastimil Babka <vbabka@suse.cz>:
>>> on non-movable would be maintained so fallback doesn't happen.
>>
>> There's nothing that guarantees that the migration scanner will be emptying
>> unmovable pageblock, or am I missing something?
>
> As replied to Mel's comment, as number of unmovable pageblocks, which is
> filled by movable pages due to this compaction change increases,
> possible candidate reclaimable/migratable pages from them also increase.
> So, at some time, amount of used page by free scanner and amount of
> migrated page by migration scanner would be balanced.
>
>> Worse, those pageblocks would be
>> marked to skip by the free scanner if it isolated free pages from them, so
>> migration scanner would skip them.
>
> Yes, but, next iteration will move out movable pages from that pageblock
> and freed pages will be used for further unmovable allocation.
> So, in the long term, this doesn't make much more fragmentation.

Theoretically, maybe. I guess there's not much point discussing it 
further, until there's data from experiments evaluating the long-term 
fragmentation (think of e.g. the number of mixed pageblocks you already 
checked in different experiments).

> Thanks.
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
