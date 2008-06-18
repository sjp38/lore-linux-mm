Date: Wed, 18 Jun 2008 14:26:14 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] migration_entry_wait fix.
In-Reply-To: <20080618105435.de10d6bc.kamezawa.hiroyu@jp.fujitsu.com>
References: <20080618101349.db4d5205.kamezawa.hiroyu@jp.fujitsu.com> <20080618105435.de10d6bc.kamezawa.hiroyu@jp.fujitsu.com>
Message-Id: <20080618142517.37A6.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>, Nick Piggin <npiggin@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-testers@vger.kernel.org, "hugh@veritas.com" <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

> From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> ---
>  mm/migrate.c |    3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> Index: test-2.6.26-rc5-mm3/mm/migrate.c
> ===================================================================
> --- test-2.6.26-rc5-mm3.orig/mm/migrate.c
> +++ test-2.6.26-rc5-mm3/mm/migrate.c
> @@ -243,7 +243,8 @@ void migration_entry_wait(struct mm_stru
>  
>  	page = migration_entry_to_page(entry);
>  
> -	get_page(page);
> +	if (!page_cache_get_speculative(page))
> +		goto out;
>  	pte_unmap_unlock(ptep, ptl);
>  	wait_on_page_locked(page);
>  	put_page(page);

sorry, so late responce.

Acked-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
