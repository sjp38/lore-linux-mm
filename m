Date: Fri, 29 Feb 2008 11:47:14 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [patch 01/21] move isolate_lru_page() to vmscan.c
In-Reply-To: <20080228214141.296335a0@bree.surriel.com>
References: <20080229112120.66E1.KOSAKI.MOTOHIRO@jp.fujitsu.com> <20080228214141.296335a0@bree.surriel.com>
Message-Id: <20080229114638.66E4.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-kernel@vger.kernel.org, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, linux-mm@kvack.org, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

> If I understand you right, this is what the incremental patch looks like:
> 
> Index: linux-2.6.25-rc2-mm1/mm/migrate.c
> ===================================================================
> --- linux-2.6.25-rc2-mm1.orig/mm/migrate.c	2008-02-28 21:32:20.000000000 -0500
> +++ linux-2.6.25-rc2-mm1/mm/migrate.c	2008-02-28 21:32:14.000000000 -0500
> @@ -841,16 +841,10 @@ static int do_move_pages(struct mm_struc
>  			goto put_and_set;
>  
>  		err = isolate_lru_page(page);
> -		if (err) {
> -put_and_set:
> -			/*
> -			 * Either remove the duplicate refcount from
> -			 * isolate_lru_page() or drop the page ref if it was
> -			 * not isolated.
> -			 */
> -			put_page(page);
> -		} else
> +		if (!err)
>  			list_add_tail(&page->lru, &pagelist);
> +put_and_set:
> +		put_page(page);
>  set_status:
>  		pp->status = err;
>  	}
> 
> Is this OK for me to commit to my tree?
> (folding it into patch 01/21)

Yes. thanks.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
