Received: from westrelay01.boulder.ibm.com (westrelay01.boulder.ibm.com [9.17.195.10])
	by e33.co.us.ibm.com (8.12.10/8.12.9) with ESMTP id j1IMKt0D576644
	for <linux-mm@kvack.org>; Fri, 18 Feb 2005 17:20:55 -0500
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by westrelay01.boulder.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id j1IMKtx6148834
	for <linux-mm@kvack.org>; Fri, 18 Feb 2005 15:20:55 -0700
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11/8.12.11) with ESMTP id j1IMKtB8012486
	for <linux-mm@kvack.org>; Fri, 18 Feb 2005 15:20:55 -0700
Subject: Re: [RFC][PATCH] Memory Hotplug
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <Pine.LNX.4.61.0502181650381.4052@chimarrao.boston.redhat.com>
References: <1108685033.6482.38.camel@localhost>
	 <1108685111.6482.40.camel@localhost>
	 <Pine.LNX.4.61.0502181650381.4052@chimarrao.boston.redhat.com>
Content-Type: text/plain
Date: Fri, 18 Feb 2005 14:20:46 -0800
Message-Id: <1108765246.6482.135.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, lhms <lhms-devel@lists.sourceforge.net>, linux-mm <linux-mm@kvack.org>, Andy Whitcroft <apw@shadowen.org>
List-ID: <linux-mm.kvack.org>

On Fri, 2005-02-18 at 16:52 -0500, Rik van Riel wrote:
> On Thu, 17 Feb 2005, Dave Hansen wrote:
> > The attached patch is a prototype implementation of memory hot-add.  It
> > allows you to boot your system, and add memory to it later.  Why would
> > you want to do this?
> 
> I want it so I can grow Xen guests after they have been booted
> up.  Being able to hot-add memory is essential for dynamically
> resizing the memory of various guest OSes, to readjust them for
> the workload.

That's the same thing we like about it on ppc64 partitions.

> Memory hot-remove isn't really needed with Xen, the balloon
> driver takes care of that.

You can free up individual pages back to the hypervisor, but you might
also want the opportunity to free up some unused mem_map if you shrink
the partition by a large amount.

> > I can post individual patches if anyone would like to comment on them.
> 
> I'm interested.  I want to get this stuff working with Xen ;)

You can either pull them from here:

	http://www.sr71.net/patches/2.6.11/2.6.11-rc3-mhp1/broken-out/

or grab the whole tarball:

http://www.sr71.net/patches/2.6.11/2.6.11-rc3-mhp1/broken-out-2.6.11-rc3-mhp1.tar.gz

Or, I could always post the whole bunch to lhms.  Nobody there should
mind too much. :)

The largest part of porting hot-add to a new architecture is usually the
sparsemem portion.  You'll pretty much have to #ifdef pfn_to_page() and
friends, declare a few macros, and then do a bit of debugging.  Here's
ppc64 as an example:

http://www.sr71.net/patches/2.6.11/2.6.11-rc3-mhp1/broken-out/B-sparse-170-sparsemem-ppc64.patch

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
