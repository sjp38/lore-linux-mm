Date: Mon, 12 Sep 2005 21:21:08 -0400
From: Martin Hicks <mort@sgi.com>
Subject: Re: [PATCH] shrink_list skip anon pages if not may_swap
Message-ID: <20050913012108.GY13449@localhost>
References: <1126546191.5182.29.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1126546191.5182.29.camel@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <lee.schermerhorn@hp.com>
Cc: linux-mm <linux-mm@kvack.org>, Martin Hicks <mort@sgi.com>, lhms-devel <lhms-devel@lists.sourceforge.net>
List-ID: <linux-mm.kvack.org>

On Mon, Sep 12, 2005 at 01:29:51PM -0400, Lee Schermerhorn wrote:
> 
> Cc to lhms-devel because memory hotplug page migration also uses
> shrink_list.
> 
> Signed-off-by:  Lee Schermerhorn <lee.schermerhorn@hp.com>

Acked-by: Martin Hicks <mort@sgi.com>


Lee already e-mail me privately about this issue.  Nice catch indeed.

thanks
mh

> ============================================================
> --- shrink_list-skip-anon-pages-if-not-may_swap/mm/vmscan.c~original	2005-08-28 19:41:01.000000000 -0400
> +++ shrink_list-skip-anon-pages-if-not-may_swap/mm/vmscan.c	2005-09-12 10:17:01.000000000 -0400
> @@ -417,7 +417,9 @@ static int shrink_list(struct list_head 
>  		 * Anonymous process memory has backing store?
>  		 * Try to allocate it some swap space here.
>  		 */
> -		if (PageAnon(page) && !PageSwapCache(page) && sc->may_swap) {
> +		if (PageAnon(page) && !PageSwapCache(page)) {
> +			if (!sc->may_swap)
> +				goto keep_locked;
>  			if (!add_to_swap(page))
>  				goto activate_locked;
>  		}
> 
> 

-- 
Martin Hicks   ||   Silicon Graphics Inc.   ||   mort@sgi.com
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
