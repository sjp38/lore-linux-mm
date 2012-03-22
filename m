Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx207.postini.com [74.125.245.207])
	by kanga.kvack.org (Postfix) with SMTP id A769E6B0044
	for <linux-mm@kvack.org>; Thu, 22 Mar 2012 12:15:09 -0400 (EDT)
Date: Thu, 22 Mar 2012 11:15:07 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: object allocation benchmark
In-Reply-To: <4F6B3591.10003@parallels.com>
Message-ID: <alpine.DEB.2.00.1203221113530.25011@router.home>
References: <4F6743C2.3090906@parallels.com> <alpine.DEB.2.00.1203191028160.19189@router.home> <4F6B3591.10003@parallels.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Pekka Enberg <penberg@kernel.org>, Suleiman Souhlal <suleiman@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On Thu, 22 Mar 2012, Glauber Costa wrote:

> On 03/19/2012 07:28 PM, Christoph Lameter wrote:
> > On Mon, 19 Mar 2012, Glauber Costa wrote:
> >
> > > I was wondering: Which benchmark would be considered the canonical one to
> > > demonstrate the speed of the slub/slab after changes? In particular, I
> > > have
> > > the kmem-memcg in mind
> >
> > I have some in kernel benchmarking tools for page allocator and slab
> > allocators. But they are not really clean patches.
> >
> >
> I'd given it a try.
>
> So in general, Suleiman patches perform fine against bare slab, the
> differences being in the order of ~ 1%. There are some spikes a little bit
> above that, that would deserve more analysis.
>
> However, reason I decided to report early, is this test:
> "1 alloc N free test". It is quite erratic. memcg+kmem sometimes performs 15 %
> worse, sometimes 30 % better... Always right after a cold boot.
>
> I was wondering if you usually see such behavior for this test, and has some
> tips on the setup in case I'm doing anything wrong ?

Well some of these tests are sensitive to memory fragmentation in the page
allocator and slab allocator. One approach is to do these tests
immediately after boot with minimal user space bringup.

The other is to run a stress tests for an predefined period to get memory
into a sufficiently fragmented state and then run the test.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
