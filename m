Date: Fri, 4 Jul 2008 15:16:56 -0400
From: Rik van Riel <riel@redhat.com>
Subject: Re: memcg: lru scan fix (Was: 2.6.26-rc8-mm1
Message-ID: <20080704151656.7745bfab@bree.surriel.com>
In-Reply-To: <20080704180226.46436432.kamezawa.hiroyu@jp.fujitsu.com>
References: <20080703020236.adaa51fa.akpm@linux-foundation.org>
	<20080704180226.46436432.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Fri, 4 Jul 2008 18:02:26 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> Index: test-2.6.26-rc8-mm1/mm/vmscan.c
> ===================================================================
> --- test-2.6.26-rc8-mm1.orig/mm/vmscan.c
> +++ test-2.6.26-rc8-mm1/mm/vmscan.c
> @@ -1501,6 +1501,8 @@ static unsigned long shrink_zone(int pri
>  	 */
>  	if (scan_global_lru(sc) && inactive_anon_is_low(zone))
>  		shrink_active_list(SWAP_CLUSTER_MAX, zone, sc, priority, 0);
> +	else if (!scan_global_lru(sc))
> +		shrink_active_list(SWAP_CLUSTER_MAX, zone, sc, priority, 0);

Makes sense.

Acked-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
