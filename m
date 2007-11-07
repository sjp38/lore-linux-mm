Date: Wed, 7 Nov 2007 09:59:45 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC PATCH 0/10] split anon and file LRUs
Message-Id: <20071107095945.c9b870fc.akpm@linux-foundation.org>
In-Reply-To: <20071106215127.29e90ecd@bree.surriel.com>
References: <20071103184229.3f20e2f0@bree.surriel.com>
	<Pine.LNX.4.64.0711061808460.5249@schroedinger.engr.sgi.com>
	<20071106212305.6aa3a4fe@bree.surriel.com>
	<Pine.LNX.4.64.0711061834340.5424@schroedinger.engr.sgi.com>
	<20071106215127.29e90ecd@bree.surriel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: clameter@sgi.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> On Tue, 6 Nov 2007 21:51:27 -0500 Rik van Riel <riel@redhat.com> wrote:
> On Tue, 6 Nov 2007 18:40:46 -0800 (PST)
> Christoph Lameter <clameter@sgi.com> wrote:
> 
> > On Tue, 6 Nov 2007, Rik van Riel wrote:
> > 
> > > Also, a factor 16 increase in page size is not going to help
> > > if memory sizes also increase by a factor 16, since we already 
> > > have trouble with today's memory sizes.
> > 
> > Note that a factor 16 increase usually goes hand in hand with
> > more processors. The synchronization of multiple processors becomes a 
> > concern. If you have an 8p and each of them tries to get the zone locks 
> > for reclaim then we are already in trouble. And given the immaturity
> > of the handling of cacheline contention in current commodity hardware this 
> > is likely to result in livelocks and/or starvation on some level.
> 
> Which is why we need to greatly reduce the number of pages
> scanned to free a page.  In all workloads.

It strikes me that splitting one list into two lists will not provide
sufficient improvement in search efficiency to do that.  I mean, a naive
guess would be that it will, on average, halve the amount of work which
needs to be done.

But we need multiple-orders-of-magnitude improvements to address the
pathological worst-cases which you're looking at there.  Where is this
coming from?

Or is the problem which you're seeing due to scanning of mapped pages
at low "distress" levels?

Would be interested in seeing more details on all of this, please.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
