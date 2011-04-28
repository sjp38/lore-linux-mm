Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 06E0D90010B
	for <linux-mm@kvack.org>; Thu, 28 Apr 2011 12:03:06 -0400 (EDT)
Received: from d01relay03.pok.ibm.com (d01relay03.pok.ibm.com [9.56.227.235])
	by e6.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p3SFclEi001572
	for <linux-mm@kvack.org>; Thu, 28 Apr 2011 11:38:47 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay03.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p3SG315I099156
	for <linux-mm@kvack.org>; Thu, 28 Apr 2011 12:03:01 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p3SC2mqD018909
	for <linux-mm@kvack.org>; Thu, 28 Apr 2011 09:02:49 -0300
Subject: Re: [PATCH 2/3] make new alloc_pages_exact()
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <4DB88DAF.2010504@freescale.com>
References: <20110414200139.ABD98551@kernel>
	 <20110414200140.CDE09A20@kernel> <4DB88AF0.1050501@freescale.com>
	 <1303940249.9516.366.camel@nimitz>  <4DB88DAF.2010504@freescale.com>
Content-Type: text/plain; charset="ISO-8859-1"
Date: Thu, 28 Apr 2011 09:02:57 -0700
Message-ID: <1304006577.9516.2578.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Timur Tabi <timur@freescale.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andi Kleen <andi@firstfloor.org>, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, Michal Nazarewicz <mina86@mina86.com>, David Rientjes <rientjes@google.com>

On Wed, 2011-04-27 at 16:42 -0500, Timur Tabi wrote:
> Dave Hansen wrote:
> >> Is there an easy way to verify that alloc_pages_exact(5MB) really does allocate
> >> > only 5MB and not 8MB?
> 
> > I'm not sure why you're asking.  How do we know that the _normal_
> > allocator only gives us 4k when we ask for 4k?  Well, that's just how it
> > works.  If alloc_pages_exact() returns success, you know it's got the
> > amount of memory that you asked for, and only that plus a bit of masking
> > for page alignment.
> > 
> > Have you seen alloc_pages_exact() behaving in some other way?
> 
> I've never tested this part of alloc_pages_exact(), even when I wrote (the first
> version of) it.  I just took it on faith that it actually did what it was
> supposed to do.

I did actually go add a bunch of printks to it at one point.  It did
seem to be working just fine and freeing the right amount of memory.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
