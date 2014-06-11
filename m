Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f44.google.com (mail-pb0-f44.google.com [209.85.160.44])
	by kanga.kvack.org (Postfix) with ESMTP id C862A6B0144
	for <linux-mm@kvack.org>; Tue, 10 Jun 2014 23:38:21 -0400 (EDT)
Received: by mail-pb0-f44.google.com with SMTP id rq2so6955521pbb.17
        for <linux-mm@kvack.org>; Tue, 10 Jun 2014 20:38:21 -0700 (PDT)
Received: from heian.cn.fujitsu.com ([59.151.112.132])
        by mx.google.com with ESMTP id hi6si5059232pac.69.2014.06.10.20.38.19
        for <linux-mm@kvack.org>;
        Tue, 10 Jun 2014 20:38:20 -0700 (PDT)
Message-ID: <5397CF36.1040103@cn.fujitsu.com>
Date: Wed, 11 Jun 2014 11:38:30 +0800
From: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 07/10] mm: rename allocflags_to_migratetype for clarity
References: <1402305982-6928-1-git-send-email-vbabka@suse.cz> <1402305982-6928-7-git-send-email-vbabka@suse.cz> <20140611024109.GG15630@bbox>
In-Reply-To: <20140611024109.GG15630@bbox>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, Mel Gorman <mgorman@suse.de>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Nazarewicz <mina86@mina86.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>

On 06/11/2014 10:41 AM, Minchan Kim wrote:
> On Mon, Jun 09, 2014 at 11:26:19AM +0200, Vlastimil Babka wrote:
>> From: David Rientjes <rientjes@google.com>
>>
>> The page allocator has gfp flags (like __GFP_WAIT) and alloc flags (like
>> ALLOC_CPUSET) that have separate semantics.
>>
>> The function allocflags_to_migratetype() actually takes gfp flags, not alloc
>> flags, and returns a migratetype.  Rename it to gfpflags_to_migratetype().
>>
>> Signed-off-by: David Rientjes <rientjes@google.com>
>> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
> 
> I was one of person who got confused sometime.

Some names in MM really make people confused. But sometimes thinking
an appropriate name is also a hard thing. Like I once wanted to change
the name of function nr_free_zone_pages() and also nr_free_buffer_pages().
But it is hard to name them, so at last Andrew suggested to add the
detailed function description to make it clear only.

Reviewed-by: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>

> 
> Acked-by: Minchan Kim <minchan@kernel.org>
> 


-- 
Thanks.
Zhang Yanfei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
