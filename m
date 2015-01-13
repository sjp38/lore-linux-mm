Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com [209.85.212.170])
	by kanga.kvack.org (Postfix) with ESMTP id 118166B006C
	for <linux-mm@kvack.org>; Tue, 13 Jan 2015 03:35:29 -0500 (EST)
Received: by mail-wi0-f170.google.com with SMTP id bs8so18593846wib.1
        for <linux-mm@kvack.org>; Tue, 13 Jan 2015 00:35:28 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f2si18873139wiz.9.2015.01.13.00.35.28
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 13 Jan 2015 00:35:28 -0800 (PST)
Message-ID: <54B4D8CE.3070503@suse.cz>
Date: Tue, 13 Jan 2015 09:35:26 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH v2 5/5] mm/compaction: add tracepoint to observe behaviour
 of compaction defer
References: <1421050875-26332-1-git-send-email-iamjoonsoo.kim@lge.com> <1421050875-26332-5-git-send-email-iamjoonsoo.kim@lge.com> <54B3F7E3.4000803@suse.cz> <20150113071839.GB29898@js1304-P5Q-DELUXE>
In-Reply-To: <20150113071839.GB29898@js1304-P5Q-DELUXE>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 01/13/2015 08:18 AM, Joonsoo Kim wrote:
> On Mon, Jan 12, 2015 at 05:35:47PM +0100, Vlastimil Babka wrote:
>> Hm what if we avoided dirtying the cache line in the non-deferred case? Would be
>> simpler, too?
>> 
>> if (zone->compact_considered + 1 >= defer_limit)
>>      return false;
>> 
>> zone->compact_considered++;
>> 
>> trace_mm_compaction_defer_compaction(zone, order);
>> 
>> return true;
> 
> Okay. I will include this minor optimization in next version of this
> patch.

Hm, on second thought, the "+ 1" part would break compaction_restarting() and
it's ugly anyway. Removing "+ 1" would increase the number of
compaction_deferred() attempts until success by one. Which should be negligible,
but maybe not good to hide it in a tracepoint patch. Sorry for the noise.

> Thanks.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
