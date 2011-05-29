Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 5508C6B0012
	for <linux-mm@kvack.org>; Sun, 29 May 2011 04:16:28 -0400 (EDT)
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [202.81.31.246])
	by e23smtp09.au.ibm.com (8.14.4/8.13.1) with ESMTP id p4T8GOpV021970
	for <linux-mm@kvack.org>; Sun, 29 May 2011 18:16:24 +1000
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p4T8Ftoi1061102
	for <linux-mm@kvack.org>; Sun, 29 May 2011 18:15:55 +1000
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p4T8GOL4008732
	for <linux-mm@kvack.org>; Sun, 29 May 2011 18:16:24 +1000
Date: Sun, 29 May 2011 13:46:18 +0530
From: Ankita Garg <ankita@in.ibm.com>
Subject: Re: [PATCH 01/10] mm: Introduce the memory regions data structure
Message-ID: <20110529081618.GC8333@in.ibm.com>
Reply-To: Ankita Garg <ankita@in.ibm.com>
References: <1306499498-14263-1-git-send-email-ankita@in.ibm.com>
 <1306499498-14263-2-git-send-email-ankita@in.ibm.com>
 <1306510203.22505.69.camel@nimitz>
 <20110527182041.GM5654@dirshya.in.ibm.com>
 <1306531912.22505.84.camel@nimitz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1306531912.22505.84.camel@nimitz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: svaidy@linux.vnet.ibm.com, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-pm@lists.linux-foundation.org, thomas.abraham@linaro.org

Hi Dave,

On Fri, May 27, 2011 at 02:31:52PM -0700, Dave Hansen wrote:
> On Fri, 2011-05-27 at 23:50 +0530, Vaidyanathan Srinivasan wrote:
> > The overall idea is to have a VM data structure that can capture
> > various boundaries of memory, and enable the allocations and reclaim
> > logic to target certain areas based on the boundaries and properties
> > required. 
> 
> It's worth noting that we already do targeted reclaim on boundaries
> other than zones.  The lumpy reclaim and memory compaction logically do
> the same thing.  So, it's at least possible to do this without having
> the global LRU designed around the way you want to reclaim.
>

My understanding maybe incorrect, but doesn't both lumpy reclaim and
memory compaction still work under zone boundary ? While trying to free
up higher order pages, lumpy reclaim checks to ensure that pages that
are selected do not cross zone boundary. Further, compaction walks
through the pages in a zone and tries to re-arrange them.
 
> Also, if you get _too_ dependent on the global LRU, what are you going
> to do if our cgroup buddies manage to get cgroup'd pages off the global
> LRU?  
> 

-- 
Regards,
Ankita Garg (ankita@in.ibm.com)
Linux Technology Center
IBM India Systems & Technology Labs,
Bangalore, India

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
