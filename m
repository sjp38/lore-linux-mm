Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id 575D96B13F0
	for <linux-mm@kvack.org>; Fri, 10 Feb 2012 13:33:52 -0500 (EST)
Received: from canuck.infradead.org ([2001:4978:20e::1])
	by merlin.infradead.org with esmtps (Exim 4.76 #1 (Red Hat Linux))
	id 1RvvI7-0006nn-2w
	for linux-mm@kvack.org; Fri, 10 Feb 2012 18:33:51 +0000
Received: from 178-85-86-190.dynamic.upc.nl ([178.85.86.190] helo=dyad.programming.kicks-ass.net)
	by canuck.infradead.org with esmtpsa (Exim 4.76 #1 (Red Hat Linux))
	id 1RvvI6-0006Np-O3
	for linux-mm@kvack.org; Fri, 10 Feb 2012 18:33:50 +0000
Subject: Re: [v7 0/8] Reduce cross CPU IPI interference
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <4F2AAEB9.9070302@tilera.com>
References: <1327572121-13673-1-git-send-email-gilad@benyossef.com>
	 <1327591185.2446.102.camel@twins>
	 <CAOtvUMeAkPzcZtiPggacMQGa0EywTH5SzcXgWjMtssR6a5KFqA@mail.gmail.com>
	 <20120201170443.GE6731@somewhere.redhat.com>
	 <CAOtvUMc8L1nh2eGJez0x44UkfPCqd+xYQASsKOP76atopZi5mw@mail.gmail.com>
	 <4F2AAEB9.9070302@tilera.com>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 10 Feb 2012 19:33:36 +0100
Message-ID: <1328898816.25989.33.camel@laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chris Metcalf <cmetcalf@tilera.com>
Cc: Frederic Weisbecker <fweisbec@gmail.com>, Gilad Ben-Yossef <gilad@benyossef.com>, linux-kernel@vger.kernel.org, Christoph Lameter <cl@linux.com>, linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Sasha Levin <levinsasha928@gmail.com>, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Avi Kivity <avi@redhat.com>, Michal Nazarewicz <mina86@mina86.com>, Kosaki Motohiro <kosaki.motohiro@gmail.com>, Milton Miller <miltonm@bga.com>

On Thu, 2012-02-02 at 10:41 -0500, Chris Metcalf wrote:
> At Tilera we have been supporting a "dataplane" mode (aka Zero Overhead
> Linux - the marketing name).  This is configured on a per-cpu basis, and in
> addition to setting isolcpus for those nodes, also suppresses various
> things that might otherwise run (soft lockup detection, vmstat work,
> etc.).  

See that's wrong.. it starts being wrong by depending on cpuisol and
goes from there.

> The claim is that you need to specify these kinds of things
> per-core since it's not always possible for the kernel to know that you
> really don't want the scheduler or any other interrupt source to touch the
> core, as opposed to the case where you just happen to have a single process
> scheduled on the core and you don't mind occasional interrupts.

Right, so that claim is proven false I think.

>   But
> there's definitely appeal in having the kernel do it adaptively too,
> particularly if it can be made to work just as well as configuring it
> statically. 

I see no reason why it shouldn't work as well or even better.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
