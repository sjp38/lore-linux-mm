Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx181.postini.com [74.125.245.181])
	by kanga.kvack.org (Postfix) with SMTP id 9EA126B0031
	for <linux-mm@kvack.org>; Wed,  5 Jun 2013 16:24:56 -0400 (EDT)
Message-ID: <51AF9E91.8090307@redhat.com>
Date: Wed, 05 Jun 2013 16:24:49 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 6/7] mm: compaction: export compact_zone_order()
References: <1370445037-24144-1-git-send-email-aarcange@redhat.com> <1370445037-24144-7-git-send-email-aarcange@redhat.com>
In-Reply-To: <1370445037-24144-7-git-send-email-aarcange@redhat.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Richard Davies <richard@arachsys.com>, Shaohua Li <shli@kernel.org>, Rafael Aquini <aquini@redhat.com>

On 06/05/2013 11:10 AM, Andrea Arcangeli wrote:
> Needed by zone_reclaim_mode compaction-awareness.

> @@ -79,6 +82,12 @@ static inline unsigned long try_to_compact_pages(struct zonelist *zonelist,
>   	return COMPACT_CONTINUE;
>   }
>
> +static inline unsigned long compact_zone_order(struct zone *zone,
> +					       int order, gfp_t gfp_mask,
> +					       bool sync, bool *contended)
> +{
> +}

An unsigned long function should probably return something.


-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
