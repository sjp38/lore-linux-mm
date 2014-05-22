Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f44.google.com (mail-ee0-f44.google.com [74.125.83.44])
	by kanga.kvack.org (Postfix) with ESMTP id D5FE46B0036
	for <linux-mm@kvack.org>; Thu, 22 May 2014 14:45:09 -0400 (EDT)
Received: by mail-ee0-f44.google.com with SMTP id c41so2923924eek.31
        for <linux-mm@kvack.org>; Thu, 22 May 2014 11:45:09 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x47si2030717eey.141.2014.05.22.11.45.07
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 22 May 2014 11:45:08 -0700 (PDT)
Message-ID: <537E45B0.8040304@suse.cz>
Date: Thu, 22 May 2014 20:45:04 +0200
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH 09/19] mm: page_alloc: Use word-based accesses for get/set
 pageblock bitmaps
References: <1399974350-11089-1-git-send-email-mgorman@suse.de>	<1399974350-11089-10-git-send-email-mgorman@suse.de>	<537DC247.5020801@suse.cz> <20140522112357.4715059bb69273f40c3ec4f2@linux-foundation.org>
In-Reply-To: <20140522112357.4715059bb69273f40c3ec4f2@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Johannes Weiner <hannes@cmpxchg.org>, Jan Kara <jack@suse.cz>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave.hansen@intel.com>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>

On 22.5.2014 20:23, Andrew Morton wrote:
> On Thu, 22 May 2014 11:24:23 +0200 Vlastimil Babka <vbabka@suse.cz> wrote:
>
>>> In a test running dd onto tmpfs the overhead of the pageblock-related
>>> functions went from 1.27% in profiles to 0.5%.
>>>
>>> Signed-off-by: Mel Gorman <mgorman@suse.de>
>>> Acked-by: Vlastimil Babka <vbabka@suse.cz>
>> Hi, I've tested if this closes the race I've been previously trying to fix
>> with the series in http://marc.info/?l=linux-mm&m=139359694028925&w=2
>> And indeed with this patch I wasn't able to reproduce it in my stress test
>> (which adds lots of memory isolation calls) anymore. So thanks to Mel I can
>> dump my series in the trashcan :P
>>
>> Therefore I believe something like below should be added to the changelog,
>> and put to stable as well.
> OK, I made it so.

Thanks.

> Miraculously, the patch applies OK to 3.14.  And it compiles!

Great, shipping time!

Vlastimil

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
