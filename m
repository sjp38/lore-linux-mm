Date: Tue, 19 Feb 2008 08:31:24 -0500
From: Rik van Riel <riel@redhat.com>
Subject: Re: [RFC][PATCH] the proposal of improve page reclaim by throttle
Message-ID: <20080219083124.2daf94e9@bree.surriel.com>
In-Reply-To: <200802191735.00222.nickpiggin@yahoo.com.au>
References: <20080219134715.7E90.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	<200802191735.00222.nickpiggin@yahoo.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 19 Feb 2008 17:34:59 +1100
Nick Piggin <nickpiggin@yahoo.com.au> wrote:

> On Tuesday 19 February 2008 16:44, KOSAKI Motohiro wrote:
> > background
> > ========================================
> > current VM implementation doesn't has limit of # of parallel reclaim.
> > when heavy workload, it bring to 2 bad things
> >   - heavy lock contention
> >   - unnecessary swap out

> I think it should maybe be a per-zone thing...
> 
> What happens if you make it a per-zone mutex, and allow just a single
> process to reclaim pages from a given zone at a time? I guess that is
> going to slow down throughput a little bit in some cases though...

I agree, doing things per zone will probably work better, because
that way one process can do page reclaim on every NUMA node at
the same time.

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
