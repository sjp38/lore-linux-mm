Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id ACD276B0038
	for <linux-mm@kvack.org>; Mon, 23 Mar 2015 21:24:52 -0400 (EDT)
Received: by padcy3 with SMTP id cy3so208788326pad.3
        for <linux-mm@kvack.org>; Mon, 23 Mar 2015 18:24:52 -0700 (PDT)
Received: from lgemrelse7q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id hp5si2893361pbb.179.2015.03.23.18.24.50
        for <linux-mm@kvack.org>;
        Mon, 23 Mar 2015 18:24:51 -0700 (PDT)
Message-ID: <5510BCAC.5010101@lge.com>
Date: Tue, 24 Mar 2015 10:23:56 +0900
From: Gioh Kim <gioh.kim@lge.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm/compaction: reset compaction scanner positions
References: <1426939106-30347-1-git-send-email-gioh.kim@lge.com> <alpine.DEB.2.10.1503231613320.24576@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.10.1503231613320.24576@chino.kir.corp.google.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: akpm@linux-foundation.org, vbabka@suse.cz, iamjoonsoo.kim@lge.com, mgorman@suse.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, gunho.lee@lge.com, Gioh Kim <gioh.kim@lge.c>



2015-03-24 i??i ? 8:16i?? David Rientjes i?'(e??) i?' e,?:
> On Sat, 21 Mar 2015, Gioh Kim wrote:
>
>> When the compaction is activated via /proc/sys/vm/compact_memory
>> it would better scan the whole zone.
>> And some platform, for instance ARM, has the start_pfn of a zone is zero.
>> Therefore the first try to compaction via /proc doesn't work.
>> It needs to force to reset compaction scanner position at first.
>>
>> Signed-off-by: Gioh Kim <gioh.kim@lge.c>
>
> That shouldn't be a valid email address.

It's my fault. I'm going to send patch again.

>
>> Acked-by: Vlastimil Babka <vbabka@suse.cz>
>
> Acked-by: David Rientjes <rientjes@google.com>
>
> I was thinking that maybe this would be better handled as part of the
> comapct_zone() logic, i.e. set cc->free_pfn and cc->migrate_pfn based on a
> helper function that understands cc->order == -1 should compact the entire
> zone.  However, after scanning the entire zone as a result of this write,
> the existing cached pfns probably don't matter anymore.  So this seems
> fine.
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
