Date: Wed, 27 Feb 2008 13:26:47 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [RFC][PATCH] page reclaim throttle take2
In-Reply-To: <1204060718.6242.333.camel@lappy>
References: <20080226104647.FF26.KOSAKI.MOTOHIRO@jp.fujitsu.com> <1204060718.6242.333.camel@lappy>
Message-Id: <20080227131939.4244.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

Hi Peter,

> > +
> > +	atomic_t		nr_reclaimers;
> > +	wait_queue_head_t	reclaim_throttle_waitq;
> >  	/*
> >  	 * rarely used fields:
> >  	 */
> 
> Small nit, that extra blank line seems at the wrong end of the text
> block :-)

Agghhh, sorry ;-)
I'll fix at next post.

> > +out:
> > +	atomic_dec(&zone->nr_reclaimers);
> > +	wake_up_all(&zone->reclaim_throttle_waitq);
> > +
> > +	return ret;
> > +}
> 
> Would it be possible - and worthwhile - to make this FIFO fair?

Hmmm
may be, we don't need perfectly fair.
because try_to_free_page() is unfair mechanism.

but I will test use wake_up() instead wake_up_all().
it makes so so fair order if no performance regression happend.

Thanks very useful comment.


- kosaki



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
