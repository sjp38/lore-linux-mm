Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx207.postini.com [74.125.245.207])
	by kanga.kvack.org (Postfix) with SMTP id 3DD3D6B0069
	for <linux-mm@kvack.org>; Thu,  5 Jan 2012 17:06:51 -0500 (EST)
Date: Thu, 5 Jan 2012 14:06:45 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v5 7/8] mm: Only IPI CPUs to drain local pages if they
 exist
Message-Id: <20120105140645.42498cdd.akpm@linux-foundation.org>
In-Reply-To: <20120105161739.GD27881@csn.ul.ie>
References: <1325499859-2262-1-git-send-email-gilad@benyossef.com>
	<1325499859-2262-8-git-send-email-gilad@benyossef.com>
	<4F033EC9.4050909@gmail.com>
	<20120105142017.GA27881@csn.ul.ie>
	<20120105144011.GU11810@n2100.arm.linux.org.uk>
	<20120105161739.GD27881@csn.ul.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: Russell King - ARM Linux <linux@arm.linux.org.uk>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Gilad Ben-Yossef <gilad@benyossef.com>, linux-kernel@vger.kernel.org, Chris Metcalf <cmetcalf@tilera.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Frederic Weisbecker <fweisbec@gmail.com>, linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Sasha Levin <levinsasha928@gmail.com>, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, Avi Kivity <avi@redhat.com>

On Thu, 5 Jan 2012 16:17:39 +0000
Mel Gorman <mel@csn.ul.ie> wrote:

> mm: page allocator: Guard against CPUs going offline while draining per-cpu page lists
> 
> While running a CPU hotplug stress test under memory pressure, I
> saw cases where under enough stress the machine would halt although
> it required a machine with 8 cores and plenty memory. I think the
> problems may be related.

When we first implemented them, the percpu pages in the page allocator
were of really really marginal benefit.  I didn't merge the patches at
all for several cycles, and it was eventually a 49/51 decision.

So I suggest that our approach to solving this particular problem
should be to nuke the whole thing, then see if that caused any
observeable problems.  If it did, can we solve those problems by means
other than bringing the dang things back?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
