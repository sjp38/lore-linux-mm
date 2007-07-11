Date: Wed, 11 Jul 2007 09:55:39 +0100
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: -mm merge plans -- anti-fragmentation
Message-ID: <20070711085539.GA18038@infradead.org>
References: <20070710102043.GA20303@skynet.ie> <200707100929.46153.dave.mccracken@oracle.com> <20070710152355.GI8779@wotan.suse.de> <200707101211.46003.dave.mccracken@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200707101211.46003.dave.mccracken@oracle.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave McCracken <dave.mccracken@oracle.com>
Cc: Nick Piggin <npiggin@suse.de>, Mel Gorman <mel@skynet.ie>, Andrew Morton <akpm@linux-foundation.org>, kenchen@google.com, jschopp@austin.ibm.com, apw@shadowen.org, kamezawa.hiroyu@jp.fujitsu.com, a.p.zijlstra@chello.nl, y-goto@jp.fujitsu.com, clameter@sgi.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, Jul 10, 2007 at 12:11:45PM -0500, Dave McCracken wrote:
> Ok, maybe disaster is too strong a word.  But any kind of order>0 allocation 
> still has to be approached with fear and caution, with a well tested fallback 
> in the case of the inevitable failures.  How many driver writers would have 
> benefited from using order>0 pages, but turned aside to other less optimal 
> solutions due to their unreliability?  We don't know, and probably never 
> will.  Those people have moved on and won't revisit that design decision.

If you look at almost any other OS they use high-order pages quite a lot.
At least Solaris, IRIX and UnixWare do.

Also not that once we have a high-order pagecache it gives a nice way
to simply reclaim a high-order page directly :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
