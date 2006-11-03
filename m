Date: Fri, 3 Nov 2006 13:50:13 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: Page allocator: Single Zone optimizations
Message-Id: <20061103135013.6bdc6240.akpm@osdl.org>
In-Reply-To: <Pine.LNX.4.64.0611031329480.16397@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0610271225320.9346@schroedinger.engr.sgi.com>
	<Pine.LNX.4.64.0610281805280.14100@schroedinger.engr.sgi.com>
	<4544914F.3000502@yahoo.com.au>
	<20061101182605.GC27386@skynet.ie>
	<20061101123451.3fd6cfa4.akpm@osdl.org>
	<Pine.LNX.4.64.0611012155340.29614@skynet.skynet.ie>
	<454A2CE5.6080003@shadowen.org>
	<Pine.LNX.4.64.0611021004270.8098@schroedinger.engr.sgi.com>
	<Pine.LNX.4.64.0611022053490.27544@skynet.skynet.ie>
	<Pine.LNX.4.64.0611021345140.9877@schroedinger.engr.sgi.com>
	<Pine.LNX.4.64.0611022153491.27544@skynet.skynet.ie>
	<Pine.LNX.4.64.0611021442210.10447@schroedinger.engr.sgi.com>
	<Pine.LNX.4.64.0611030900480.9787@skynet.skynet.ie>
	<Pine.LNX.4.64.0611030952530.14741@schroedinger.engr.sgi.com>
	<Pine.LNX.4.64.0611031825420.25219@skynet.skynet.ie>
	<Pine.LNX.4.64.0611031124340.15242@schroedinger.engr.sgi.com>
	<Pine.LNX.4.64.0611032101190.25219@skynet.skynet.ie>
	<Pine.LNX.4.64.0611031329480.16397@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Andy Whitcroft <apw@shadowen.org>, Nick Piggin <nickpiggin@yahoo.com.au>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Linux Memory Management List <linux-mm@kvack.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

On Fri, 3 Nov 2006 13:42:16 -0800 (PST)
Christoph Lameter <clameter@sgi.com> wrote:

> Kernel pages are buffered already in the slab 
> allocator

But why?  I've been intermittently campaigning to stop doing that for about
five years now.  Having private lists of free pages in the slab allocator
is duplicative of the page allocator's lists and worsens performance.

In fact I thought we'd stopped doing this ages ago.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
