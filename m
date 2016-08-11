Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2E9F46B0005
	for <linux-mm@kvack.org>; Thu, 11 Aug 2016 08:33:39 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id o80so7511952wme.1
        for <linux-mm@kvack.org>; Thu, 11 Aug 2016 05:33:39 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 192si2765589wmm.95.2016.08.11.05.33.37
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 11 Aug 2016 05:33:37 -0700 (PDT)
Subject: Re: [PATCH 3/5] mm/page_owner: move page_owner specific function to
 page_owner.c
References: <1470809784-11516-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1470809784-11516-4-git-send-email-iamjoonsoo.kim@lge.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <ad4c6f77-ae7e-2dd6-a5da-7a9246eba304@suse.cz>
Date: Thu, 11 Aug 2016 14:33:33 +0200
MIME-Version: 1.0
In-Reply-To: <1470809784-11516-4-git-send-email-iamjoonsoo.kim@lge.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: js1304@gmail.com, Andrew Morton <akpm@linux-foundation.org>
Cc: Minchan Kim <minchan@kernel.org>, Michal Hocko <mhocko@kernel.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On 08/10/2016 08:16 AM, js1304@gmail.com wrote:
> +			page_mt = gfpflags_to_migratetype(page_ext->gfp_mask);
> +			if (pageblock_mt != page_mt) {
> +				count[pageblock_mt]++;
> +
> +				pfn = block_end_pfn;
> +				break;
> +			}

... is not the same as ...

> -			page_mt = gfpflags_to_migratetype(page_ext->gfp_mask);
> -			if (pageblock_mt != page_mt) {
> -				if (is_migrate_cma(pageblock_mt))
> -					count[MIGRATE_MOVABLE]++;
> -				else
> -					count[pageblock_mt]++;
> -
> -				pfn = block_end_pfn;
> -				break;
> -			}

Rebasing blunder?

Vlastimil

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
