Received: from d03relay05.boulder.ibm.com (d03relay05.boulder.ibm.com [9.17.195.107])
	by e36.co.us.ibm.com (8.13.1/8.13.1) with ESMTP id mA5MnuoQ021347
	for <linux-mm@kvack.org>; Wed, 5 Nov 2008 15:49:56 -0700
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay05.boulder.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id mA5MoHZV089360
	for <linux-mm@kvack.org>; Wed, 5 Nov 2008 15:50:18 -0700
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id mA5MoDfq006445
	for <linux-mm@kvack.org>; Wed, 5 Nov 2008 15:50:16 -0700
Date: Wed, 5 Nov 2008 14:50:06 -0800
From: Gary Hade <garyhade@us.ibm.com>
Subject: Re: [PATCH] [REPOST #2] mm: show node to memory section
	relationship with symlinks in sysfs
Message-ID: <20081105225006.GA14663@us.ibm.com>
References: <20081103234808.GA13716@us.ibm.com> <20081105123609.878085be.akpm@linux-foundation.org> <1225919024.11514.4.camel@nimitz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1225919024.11514.4.camel@nimitz>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Gary Hade <garyhade@us.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, y-goto@jp.fujitsu.com, pbadari@us.ibm.com, mel@csn.ul.ie, lcm@us.ibm.com, mingo@elte.hu, greg@kroah.com, nish.aravamudan@gmail.com
List-ID: <linux-mm.kvack.org>

On Wed, Nov 05, 2008 at 01:03:44PM -0800, Dave Hansen wrote:
> On Wed, 2008-11-05 at 12:36 -0800, Andrew Morton wrote:
> > Dumb question: why do this with a symlink forest instead of, say, cat
> > /proc/sys/vm/mem-sections?
> 
> The basic problem is that we on/offline memory based on sections and not
> nodes.  But, physically, people care about nodes.
> 
> So, the question we're answering is "to which sections does this node's
> memory belong?".  We could just put all this data in one big file and
> have:
> 
> $ cat /proc/sys/vm/mem-sections?
> node: section numbers
> 0: 1 2 3 4 5
> 1: 5 6 7 8
> 2: 99 100 101 102
> 
> But, we have the nodes in sysfs and we also have the sections in sysfs
> and I don't want Greg to be mean to me.  He's scary.  We could simply
> dump the section numbers in sysfs, but the first thing userspace is
> going to do is:
> 
> for section in /sys/devices/system/node/node1/memory*; do
> 	nr=$(cat $section)
> 	cat foo > /sys/devices/system/memory/memory$nr/bar
> done
> 
> Making the symlinks makes it harder for us to screw this process up,
> both in the kernel and in userspace.  Plus, symlinks are easy to code up
> in sysfs. 

The new symlinks to the mem sections directories from within
the node directories are also consistent with the presidence set
by symlinks to the CPU directories from these same locations.

Gary

-- 
Gary Hade
System x Enablement
IBM Linux Technology Center
503-578-4503  IBM T/L: 775-4503
garyhade@us.ibm.com
http://www.ibm.com/linux/ltc

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
