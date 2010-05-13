Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 1DE686B01EE
	for <linux-mm@kvack.org>; Thu, 13 May 2010 14:45:23 -0400 (EDT)
Date: Thu, 13 May 2010 11:15:39 -0700
From: Greg KH <gregkh@suse.de>
Subject: Re: [RFC, 6/7] NUMA hotplug emulator
Message-ID: <20100513181539.GA26597@suse.de>
References: <20100513120016.GG2169@shaohui>
 <20100513165603.GC25212@suse.de>
 <1273773737.13285.7771.camel@nimitz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1273773737.13285.7771.camel@nimitz>
Sender: owner-linux-mm@kvack.org
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Andi Kleen <ak@linux.intel.com>, Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>, Wu Fengguang <fengguang.wu@intel.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux-kernel@vger.kernel.org, haicheng.li@linux.intel.com, shaohui.zheng@linux.intel.com
List-ID: <linux-mm.kvack.org>

On Thu, May 13, 2010 at 11:02:17AM -0700, Dave Hansen wrote:
> On Thu, 2010-05-13 at 09:56 -0700, Greg KH wrote:
> > On Thu, May 13, 2010 at 08:00:16PM +0800, Shaohui Zheng wrote:
> > > hotplug emulator:extend memory probe interface to support NUMA
> > > 
> > > Extend memory probe interface to support an extra paramter nid,
> > > the reserved memory can be added into this node if node exists.
> > > 
> > > Add a memory section(128M) to node 3(boots with mem=1024m)
> > > 
> > >       echo 0x40000000,3 > memory/probe
> 
> I dunno.  If we're going to put multiple values into the file now and
> add to the ABI, can we be more explicit about it?
> 
> 	echo "physical_address=0x40000000 numa_node=3" > memory/probe
> 
> I'd *GREATLY* prefer that over this new syntax.  The existing mechanism
> is obtuse enough, and the ',3' makes it more so.
> 
> We should have the code around to parse arguments like that, too, since
> we use it for the boot command-line.

If you are going to be doing something like this, please use configfs,
that is what it is designed for, not sysfs.

thanks,

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
