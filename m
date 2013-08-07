Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx200.postini.com [74.125.245.200])
	by kanga.kvack.org (Postfix) with SMTP id EC0246B0095
	for <linux-mm@kvack.org>; Wed,  7 Aug 2013 11:48:47 -0400 (EDT)
Date: Wed, 7 Aug 2013 16:48:43 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 7/9] mm: zone_reclaim: compaction: export
 compact_zone_order()
Message-ID: <20130807154843.GU2296@suse.de>
References: <1375459596-30061-1-git-send-email-aarcange@redhat.com>
 <1375459596-30061-8-git-send-email-aarcange@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1375459596-30061-8-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Richard Davies <richard@arachsys.com>, Shaohua Li <shli@kernel.org>, Rafael Aquini <aquini@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Hush Bensen <hush.bensen@gmail.com>

On Fri, Aug 02, 2013 at 06:06:34PM +0200, Andrea Arcangeli wrote:
> Needed by zone_reclaim_mode compaction-awareness.
> 
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>

> @@ -79,6 +82,13 @@ static inline unsigned long try_to_compact_pages(struct zonelist *zonelist,
>  	return COMPACT_CONTINUE;
>  }
>  
> +static inline unsigned long compact_zone_order(struct zone *zone,
> +					       int order, gfp_t gfp_mask,
> +					       bool sync, bool *contended)
> +{
> +	return COMPACT_CONTINUE;
> +}
> +

COMPACT_SKIPPED to indicate that compaction did not even start and there
is no point rechecking watermarks or trying to allocate?

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
