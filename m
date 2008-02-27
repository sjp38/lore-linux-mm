Date: Wed, 27 Feb 2008 09:50:05 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH] page reclaim throttle take2
Message-Id: <20080227095005.4058e109.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1204060718.6242.333.camel@lappy>
References: <20080226104647.FF26.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	<1204060718.6242.333.camel@lappy>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Balbir Singh <balbir@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On Tue, 26 Feb 2008 22:18:38 +0100
Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:

> > +out:
> > +	atomic_dec(&zone->nr_reclaimers);
> > +	wake_up_all(&zone->reclaim_throttle_waitq);
> > +
> > +	return ret;
> > +}
> 
> Would it be possible - and worthwhile - to make this FIFO fair?
> 
I think it doesn't make sense for fairness.

IMHO, this functionality is an unfair one in nature. While someone is
reclaiming pages, other processes can get a newly reclaimed page without
calling try_to_free_page.

For high-priority processes, 

1. avoiding diving into try_to_free_pages if it's congested.
2. just waiting for that someone relcaim pages and grab it ASAP

maybe good for quick work. 

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
