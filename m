Date: Tue, 15 Jan 2008 11:06:31 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 4/5] memory_pressure_notify() caller
Message-Id: <20080115110631.4cab1e65.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080115100124.117B.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <20080115092828.116F.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	<20080115100124.117B.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Marcelo Tosatti <marcelo@kvack.org>, Daniel Spang <daniel.spang@gmail.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Tue, 15 Jan 2008 10:02:30 +0900
KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

> +
> +	notify_threshold = (zone->pages_high +
> +			    zone->lowmem_reserve[MAX_NR_ZONES-1]) * 2;
> +
Why MAX_NR_ZONES-1 ?


> +	if (unlikely((prev_free <= notify_threshold) &&
> +		     (zone_page_state(zone, NR_FREE_PAGES) > notify_threshold)))
> +		memory_pressure_notify(zone, 0);
>  }

How about this
==
if (unlikely(zone->mem_notify_status && ...) 


Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
