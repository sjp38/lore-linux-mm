Date: Tue, 1 Jul 2008 09:38:40 -0400
From: Rik van Riel <riel@redhat.com>
Subject: Re: [resend][PATCH -mm] split_lru: fix pagevec_move_tail() doesn't
 treat unevictable page
Message-ID: <20080701093840.07b48ced@bree.surriel.com>
In-Reply-To: <20080701172223.3801.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <20080701155749.37F8.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	<20080701172223.3801.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Andrew Morton <akpm@linux-foundation.org>, MinChan Kim <minchan.kim@gmail.com>
List-ID: <linux-mm.kvack.org>

On Tue, 01 Jul 2008 17:26:51 +0900
KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

Acked-by: Rik van Riel <riel@redhat.com>

Good catch!
 
> @@ -116,7 +116,7 @@ static void pagevec_move_tail(struct pag
>  			zone = pagezone;
>  			spin_lock(&zone->lru_lock);
>  		}
> -		if (PageLRU(page) && !PageActive(page)) {
> +		if (PageLRU(page) && !PageActive(page) && !PageUnevictable(page)) {
>  			int lru = page_is_file_cache(page);
>  			list_move_tail(&page->lru, &zone->lru[lru].list);
>  			pgmoved++;

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
