Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f43.google.com (mail-wg0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id BB89C6B0075
	for <linux-mm@kvack.org>; Thu,  8 Jan 2015 03:47:34 -0500 (EST)
Received: by mail-wg0-f43.google.com with SMTP id k14so1325060wgh.2
        for <linux-mm@kvack.org>; Thu, 08 Jan 2015 00:47:34 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id dk6si10596092wjb.113.2015.01.08.00.47.33
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 08 Jan 2015 00:47:34 -0800 (PST)
Message-ID: <54AE4424.3070406@suse.cz>
Date: Thu, 08 Jan 2015 09:47:32 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH 2/3] mm/compaction: add more trace to understand compaction
 start/finish condition
References: <1417593127-6819-1-git-send-email-iamjoonsoo.kim@lge.com> <1417593127-6819-2-git-send-email-iamjoonsoo.kim@lge.com> <54ABC13C.4030403@suse.cz> <20150108082114.GD25453@js1304-P5Q-DELUXE>
In-Reply-To: <20150108082114.GD25453@js1304-P5Q-DELUXE>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 01/08/2015 09:21 AM, Joonsoo Kim wrote:
> 
> Okay. How about adding one more like below?
> 
> #define COMPACT_NO_SUITABLE_PAGE
> #define COMPACT_NOT_SUITABLE_ZONE

Yeah that would be less confusing.

> It will distiguish return value properly.
> 
>> >  	return COMPACT_CONTINUE;
>> >  }
>> >  
>> > +unsigned long compaction_suitable(struct zone *zone, int order,
>> > +					int alloc_flags, int classzone_idx)
>> > +{
>> > +	unsigned long ret;
>> > +
>> > +	ret = __compaction_suitable(zone, order, alloc_flags, classzone_idx);
>> > +	trace_mm_compaction_suitable(zone, order, alloc_flags,
>> > +						classzone_idx, ret);
>> > +	if (ret == COMPACT_NOT_SUITABLE)
>> > +		ret = COMPACT_SKIPPED;
>> 
>> I don't like this wrapping just for tracepints, but I don't know of a better way :/
> 
> Yes, I don't like it, too. :/
> 
> Thanks.
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
