Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e33.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m5AM5cdA007497
	for <linux-mm@kvack.org>; Tue, 10 Jun 2008 18:05:38 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m5AM5coB174796
	for <linux-mm@kvack.org>; Tue, 10 Jun 2008 16:05:38 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m5AM5bNj015032
	for <linux-mm@kvack.org>; Tue, 10 Jun 2008 16:05:38 -0600
Subject: Re: [PATCH -mm 13/25] Noreclaim LRU Infrastructure
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <20080610143334.c53d7d8a.akpm@linux-foundation.org>
References: <20080606202838.390050172@redhat.com>
	 <20080606202859.291472052@redhat.com>
	 <20080606180506.081f686a.akpm@linux-foundation.org>
	 <20080608163413.08d46427@bree.surriel.com>
	 <20080608135704.a4b0dbe1.akpm@linux-foundation.org>
	 <20080608173244.0ac4ad9b@bree.surriel.com>
	 <20080608162208.a2683a6c.akpm@linux-foundation.org>
	 <20080608193420.2a9cc030@bree.surriel.com>
	 <20080608165434.67c87e5c.akpm@linux-foundation.org>
	 <Pine.LNX.4.64.0806101214190.17798@schroedinger.engr.sgi.com>
	 <20080610153702.4019e042@cuia.bos.redhat.com>
	 <20080610143334.c53d7d8a.akpm@linux-foundation.org>
Content-Type: text/plain
Date: Tue, 10 Jun 2008 15:05:35 -0700
Message-Id: <1213135535.7261.10.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, clameter@sgi.com, linux-kernel@vger.kernel.org, lee.schermerhorn@hp.com, kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org, eric.whitney@hp.com, Paul Mundt <lethal@linux-sh.org>, Andi Kleen <andi@firstfloor.org>, Ingo Molnar <mingo@elte.hu>, Andy Whitcroft <apw@shadowen.org>
List-ID: <linux-mm.kvack.org>

On Tue, 2008-06-10 at 14:33 -0700, Andrew Morton wrote:
> Maybe it's time to bite the bullet and kill i386 NUMA support.  afaik
> it's just NUMAQ and a 2-node NUMAish machine which IBM made (as400?)

Yeah, IBM sold a couple of these "interesting" 32-bit NUMA machines:

https://www.redbooks.ibm.com/Redbooks.nsf/RedbookAbstracts/tips0267.html?Open

I think those maxed out at 8 nodes, ever.  But, no distro ever turned
NUMA on for i386, so no one actually depends on it working.  We do have
a bunch of systems that we use for testing and so forth.  It'd be a
shame to make these suck *too* much.  The NUMA-Q is probably also so
intertwined with CONFIG_NUMA that we'd likely never get it running
again.

I'd rather just bloat page->flags on these platforms or move the
sparsemem/zone/node bits elsewhere than kill NUMA support.  

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
