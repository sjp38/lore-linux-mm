Date: Mon, 14 Apr 2008 17:20:49 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH][-mm][1/2] core of page reclaim throttle
In-Reply-To: <1208028623.6230.67.camel@lappy>
References: <20080330171224.89D8.KOSAKI.MOTOHIRO@jp.fujitsu.com> <1208028623.6230.67.camel@lappy>
Message-Id: <20080414171500.474D.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Nick Piggin <nickpiggin@yahoo.com.au>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

> > Index: b/include/linux/mmzone.h
> > ===================================================================
> > --- a/include/linux/mmzone.h	2008-03-27 13:35:03.000000000 +0900
> > +++ b/include/linux/mmzone.h	2008-03-27 15:55:50.000000000 +0900
> > @@ -335,6 +335,8 @@ struct zone {
> >  	unsigned long		spanned_pages;	/* total size, including holes */
> >  	unsigned long		present_pages;	/* amount of memory (excluding holes) */
> >  
> > +	atomic_t		nr_reclaimers;
> > +	wait_queue_head_t	reclaim_throttle_waitq;
> >  	/*
> >  	 * rarely used fields:
> 
> I'm thinking this ought to be a plist based wait_queue to avoid priority
> inversions - but I don't think we have such a creature. 

agreed pi problem exist.
but that is not important in reclaim because it is already large un-deterministic.
and I hope step by step development.

I'll drop pi feature in this version and stack to future development list :)

Thanks


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
