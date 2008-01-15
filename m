Date: Tue, 15 Jan 2008 11:37:48 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 4/5] memory_pressure_notify() caller
In-Reply-To: <20080115110631.4cab1e65.kamezawa.hiroyu@jp.fujitsu.com>
References: <20080115100124.117B.KOSAKI.MOTOHIRO@jp.fujitsu.com> <20080115110631.4cab1e65.kamezawa.hiroyu@jp.fujitsu.com>
Message-Id: <20080115112114.118E.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Marcelo Tosatti <marcelo@kvack.org>, Daniel Spang <daniel.spang@gmail.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Hi KAME, 

> > +	notify_threshold = (zone->pages_high +
> > +			    zone->lowmem_reserve[MAX_NR_ZONES-1]) * 2;
> > +
> Why MAX_NR_ZONES-1 ?

this is intent to max lowmem_reserve.

in normal case, 
shrink_active_list isn't called when free_pages > pages_high.
but just after memory freed, it happened rarely.

I don't want incorrect notify at system enough free memory.

related discussion
  http://marc.info/?l=linux-mm&m=119878630211348&w=2


> > +	if (unlikely((prev_free <= notify_threshold) &&
> > +		     (zone_page_state(zone, NR_FREE_PAGES) > notify_threshold)))
> > +		memory_pressure_notify(zone, 0);
> >  }
> 
> How about this
> ==
> if (unlikely(zone->mem_notify_status && ...) 

Nice idea.
I will applied it at next post.

thank you!




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
