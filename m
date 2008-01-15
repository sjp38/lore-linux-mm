Date: Tue, 15 Jan 2008 12:08:52 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 4/5] memory_pressure_notify() caller
In-Reply-To: <20080115120012.0fcdd0f8.kamezawa.hiroyu@jp.fujitsu.com>
References: <20080115112114.118E.KOSAKI.MOTOHIRO@jp.fujitsu.com> <20080115120012.0fcdd0f8.kamezawa.hiroyu@jp.fujitsu.com>
Message-Id: <20080115120110.1194.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Marcelo Tosatti <marcelo@kvack.org>, Daniel Spang <daniel.spang@gmail.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Hi Kame,

> > > > +	notify_threshold = (zone->pages_high +
> > > > +			    zone->lowmem_reserve[MAX_NR_ZONES-1]) * 2;
> > > > +
> > > Why MAX_NR_ZONES-1 ?
> > 
> > this is intent to max lowmem_reserve.
> > 
> Ah, my point is.. how about this ?
> ==
> if (page_zoneid(page) != ZONE_DMA)
> 	notify_threshold = zone->pages_high +
>                    	zone->lowmem_reserve[page_zoneid(page) - 1] * 2;

your point out is very good point.

but judged by zone size is more better, may be.
on some 64bit system, ZONE_DMA is 4GB.
small memory system can't ignore it. 

fortunately, zone size check can at free_area_init_core().


- kosaki



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
