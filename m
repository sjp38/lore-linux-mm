Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 5AB336B0055
	for <linux-mm@kvack.org>; Mon, 20 Jul 2009 10:31:00 -0400 (EDT)
Date: Mon, 20 Jul 2009 23:30:48 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 4/5] Use add_page_to_lru_list() helper function
In-Reply-To: <1248074911.15751.8023.camel@twins>
References: <20090720143352.747E.A69D9226@jp.fujitsu.com> <1248074911.15751.8023.camel@twins>
Message-Id: <20090720231618.AF69.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <peterz@infradead.org>
Cc: kosaki.motohiro@jp.fujitsu.com, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

> On Mon, 2009-07-20 at 14:37 +0900, KOSAKI Motohiro wrote:
> > > > @@ -1241,7 +1241,6 @@ static void move_active_pages_to_lru(str
> > > >  			spin_lock_irq(&zone->lru_lock);
> > > >  		}
> > > >  	}
> > > > -	__mod_zone_page_state(zone, NR_LRU_BASE + lru, pgmoved);
> > > >  	if (!is_active_lru(lru))
> > > >  		__count_vm_events(PGDEACTIVATE, pgmoved);
> > > >  }
> > > 
> > > This is a net loss, you introduce pgmoved calls to __inc_zone_state,
> > > instead of the one __mod_zone_page_state() call.
> > 
> > max pgmoved is 32. 32 times __inc_zone_state() make 0 or 1 time
> > atomic operation (not much than two).
> > I don't think it reduce performance.
> 
> its not just atomics, count calls and branches too. It simply adds a ton
> of code for no particular reason.

hm, I don't think it's tons penalty. I mean vmscan makes tons cache miss
and function calling penalty is hidden by it.
But, I agreed this patch doesn't have strong motivation. I can drop this.

Andrew, Can you please drop this patch?





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
