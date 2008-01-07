Date: Mon, 7 Jan 2008 18:23:02 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [patch 06/19] split LRU lists into anon & file sets
Message-Id: <20080107182302.a6f268fc.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080102224154.205031565@redhat.com>
References: <20080102224144.885671949@redhat.com>
	<20080102224154.205031565@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: riel@redhat.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, lee.schermerhorn@hp.com, Lee Schermerhorn <Lee.Schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

On Wed, 02 Jan 2008 17:41:50 -0500
linux-kernel@vger.kernel.org wrote:


>  static void shrink_active_list(unsigned long nr_pages, struct zone *zone,
> -				struct scan_control *sc, int priority)
> +				struct scan_control *sc, int priority, int file)
>  {
>  	unsigned long pgmoved;
>  	int pgdeactivate = 0;
> @@ -1128,64 +1026,65 @@ static void shrink_active_list(unsigned 
>  	struct list_head list[NR_LRU_LISTS];
>  	struct page *page;
>  	struct pagevec pvec;
> -	int reclaim_mapped = 0;
> -	enum lru_list l;
> +	enum lru_list lru;
<snip>

> +	/*
> +	 * For sorting active vs inactive pages, we'll use the 'anon'
> +	 * elements of the local list[] array and sort out the file vs
> +	 * anon pages below.
> +	 */

This is not easy to read.... (this definition affects later patches...)

How about adding some new enum (only) for this function ?
like
 LRU_STAY_ACTIVE = 0,
 LRU_MOVE_INACTIVE = 1,

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
