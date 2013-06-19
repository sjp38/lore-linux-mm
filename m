Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id 6CF396B0033
	for <linux-mm@kvack.org>; Wed, 19 Jun 2013 03:10:47 -0400 (EDT)
Date: Wed, 19 Jun 2013 00:10:29 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm/vmscan.c: 'lru' may be used without initialized
 after the patch "3abf380..." in next-20130607 tree
Message-Id: <20130619001029.ee623fae.akpm@linux-foundation.org>
In-Reply-To: <51C155D1.3090304@asianux.com>
References: <51C155D1.3090304@asianux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chen Gang <gang.chen@asianux.com>
Cc: Mel Gorman <mgorman@suse.de>, hannes@cmpxchg.org, riel@redhat.com, mhocko@suse.cz, linux-mm@kvack.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Wed, 19 Jun 2013 14:55:13 +0800 Chen Gang <gang.chen@asianux.com> wrote:

> 
> 'lru' may be used without initialized, so need regressing part of the
> related patch.
> 
> The related patch:
>   "3abf380 mm: remove lru parameter from __lru_cache_add and lru_cache_add_lru"
>
> ...
>
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -595,6 +595,7 @@ redo:
>  		 * unevictable page on [in]active list.
>  		 * We know how to handle that.
>  		 */
> +		lru = !!TestClearPageActive(page) + page_lru_base_type(page);
>  		lru_cache_add(page);
>  	} else {
>  		/*

That looks right.  Why the heck didn't gcc-4.4.4 (at least) warn about it?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
