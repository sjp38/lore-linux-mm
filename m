Date: Wed, 16 May 2007 09:27:32 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 2/8] Print out statistics in relation to fragmentation
 avoidance to /proc/fragavoidance
Message-Id: <20070516092732.9f0221ba.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <Pine.LNX.4.64.0705152020140.12851@skynet.skynet.ie>
References: <20070515150311.16348.56826.sendpatchset@skynet.skynet.ie>
	<20070515150351.16348.14242.sendpatchset@skynet.skynet.ie>
	<Pine.LNX.4.64.0705151122110.31972@schroedinger.engr.sgi.com>
	<Pine.LNX.4.64.0705152020140.12851@skynet.skynet.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: clameter@sgi.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 15 May 2007 20:23:21 +0100 (IST)
Mel Gorman <mel@csn.ul.ie> wrote:

> On Tue, 15 May 2007, Christoph Lameter wrote:
> 
> > On Tue, 15 May 2007, Mel Gorman wrote:
> >
> >>
> >> This patch provides fragmentation avoidance statistics via
> >> /proc/fragavoidance. The information is collected only on request so there
> >
> > The name is probably a bit strange.
> >
> > /proc/pagetypeinfo or so?
> >
> 
> /proc/mobilityinfo ?
> 
I vote pagetypeinfo or pagegroupinfo :)

-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
