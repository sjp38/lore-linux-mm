Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 83FBC6B02FA
	for <linux-mm@kvack.org>; Tue, 29 Aug 2017 03:14:03 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id n37so3568369wrf.8
        for <linux-mm@kvack.org>; Tue, 29 Aug 2017 00:14:03 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 59si498363wrs.496.2017.08.29.00.14.02
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 29 Aug 2017 00:14:02 -0700 (PDT)
Subject: Re: [PATCH 1/2] mm/slub: wake up kswapd for initial high order
 allocation
References: <1503882675-17910-1-git-send-email-iamjoonsoo.kim@lge.com>
 <f1423efc-3c60-c03e-0d81-f2e8fcccbcd6@suse.cz>
 <20170829002222.GA14489@js1304-P5Q-DELUXE>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <ca4c2666-ed3c-8810-1b16-2a8176a0cae1@suse.cz>
Date: Tue, 29 Aug 2017 09:14:00 +0200
MIME-Version: 1.0
In-Reply-To: <20170829002222.GA14489@js1304-P5Q-DELUXE>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mgorman@techsingularity.net>

On 08/29/2017 02:22 AM, Joonsoo Kim wrote:
> On Mon, Aug 28, 2017 at 12:04:41PM +0200, Vlastimil Babka wrote:
>>
>> Hm, so this seems to revert Mel's 444eb2a449ef ("mm: thp: set THP defrag
>> by default to madvise and add a stall-free defrag option") wrt the slub
>> allocate_slab() part. AFAICS the intention in Mel's patch was that he
>> removed a special case in __alloc_page_slowpath() where including
>> __GFP_THISNODE and lacking ~__GFP_DIRECT_RECLAIM effectively means also
>> lacking __GFP_KSWAPD_RECLAIM. The commit log claims that slab/slub might
>> change behavior so he moved the removal of __GFP_KSWAPD_RECLAIM to them.
>>
>> But AFAICS, only slab uses __GFP_THISNODE, while slub doesn't. So your
>> patch would indeed revert an unintentional change of Mel's commit. Is it
>> right or do I miss something?
> 
> I didn't look at that patch. What I tried here is just restoring first
> intention of this code. I now realize that Mel did it for specific
> purpose. Thanks for notifying it.
> 
> Anyway, your analysis looks correct and this change doesn't hurt Mel's
> intention and restores original behaviour of the code. I will add your
> analysis on the commit description and resubmit it. Is it okay to you?

Yeah, no problem.

> Thanks.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
