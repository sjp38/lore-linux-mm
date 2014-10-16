Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f47.google.com (mail-la0-f47.google.com [209.85.215.47])
	by kanga.kvack.org (Postfix) with ESMTP id 166B36B006E
	for <linux-mm@kvack.org>; Thu, 16 Oct 2014 11:11:27 -0400 (EDT)
Received: by mail-la0-f47.google.com with SMTP id pv20so3018917lab.20
        for <linux-mm@kvack.org>; Thu, 16 Oct 2014 08:11:27 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j15si35283239lbg.30.2014.10.16.08.11.25
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 16 Oct 2014 08:11:26 -0700 (PDT)
Message-ID: <543FE01A.5020205@suse.cz>
Date: Thu, 16 Oct 2014 17:11:22 +0200
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH 2/5] mm, compaction: simplify deferred compaction
References: <1412696019-21761-1-git-send-email-vbabka@suse.cz>	<1412696019-21761-3-git-send-email-vbabka@suse.cz> <20141015153212.7b9029c8bb8e9c1b8736181d@linux-foundation.org>
In-Reply-To: <20141015153212.7b9029c8bb8e9c1b8736181d@linux-foundation.org>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Nazarewicz <mina86@mina86.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>

On 10/16/2014 12:32 AM, Andrew Morton wrote:
> On Tue,  7 Oct 2014 17:33:36 +0200 Vlastimil Babka <vbabka@suse.cz> wrote:
>> @@ -105,8 +104,7 @@ static inline bool compaction_restarting(struct zone *zone, int order)
>>  static inline unsigned long try_to_compact_pages(struct zonelist *zonelist,
>>  			int order, gfp_t gfp_mask, nodemask_t *nodemask,
>>  			enum migrate_mode mode, int *contended,
>> -			int alloc_flags, int classzone_idx,
>> -			struct zone **candidate_zone)
>> +			int alloc_flags, int classzone_idx);
>>  {
>>  	return COMPACT_CONTINUE;
>>  }
> 
> --- a/include/linux/compaction.h~mm-compaction-simplify-deferred-compaction-fix
> +++ a/include/linux/compaction.h
> @@ -104,7 +104,7 @@ static inline bool compaction_restarting
>  static inline unsigned long try_to_compact_pages(struct zonelist *zonelist,
>  			int order, gfp_t gfp_mask, nodemask_t *nodemask,
>  			enum migrate_mode mode, int *contended,
> -			int alloc_flags, int classzone_idx);
> +			int alloc_flags, int classzone_idx)
>  {
>  	return COMPACT_CONTINUE;
>  }
> 
> It clearly wasn't tested with this config.  Please do so and let us
> know the result?

Sorry, forgot. Hopefully will get better next time, since I learned
about the undertaker/vampyr tool [1] today.

You patch does fix the compilation, thanks. Boot+stress-highalloc tests
are now running through the series but I don't expect any surprises -
the series is basically a no-op with CONFIG_COMPACTION disabled.

[1] http://lwn.net/Articles/616098/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
