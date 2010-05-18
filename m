Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 0AB6B6B01D0
	for <linux-mm@kvack.org>; Tue, 18 May 2010 01:49:16 -0400 (EDT)
Date: Tue, 18 May 2010 13:41:21 +0800
From: Shaohui Zheng <shaohui.zheng@intel.com>
Subject: Re: [RFC, 6/7] NUMA hotplug emulator
Message-ID: <20100518054121.GA25298@shaohui>
References: <20100513120016.GG2169@shaohui>
 <20100513165603.GC25212@suse.de>
 <1273773737.13285.7771.camel@nimitz>
 <20100513181539.GA26597@suse.de>
 <1273776578.13285.7820.camel@nimitz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1273776578.13285.7820.camel@nimitz>
Sender: owner-linux-mm@kvack.org
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: Greg KH <gregkh@suse.de>, akpm@linux-foundation.org, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Andi Kleen <ak@linux.intel.com>, Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>, Wu Fengguang <fengguang.wu@intel.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux-kernel@vger.kernel.org, haicheng.li@linux.intel.com, shaohui.zheng@linux.intel.com
List-ID: <linux-mm.kvack.org>

On Thu, May 13, 2010 at 11:49:38AM -0700, Dave Hansen wrote:
> On Thu, 2010-05-13 at 11:15 -0700, Greg KH wrote:
> > >       echo "physical_address=0x40000000 numa_node=3" > memory/probe
> > > 
> > > I'd *GREATLY* prefer that over this new syntax.  The existing mechanism
> > > is obtuse enough, and the ',3' makes it more so.
> > > 
> > > We should have the code around to parse arguments like that, too, since
> > > we use it for the boot command-line.
> > 
> > If you are going to be doing something like this, please use configfs,
> > that is what it is designed for, not sysfs.
> 
> That's probably a really good point, especially since configfs didn't
> even exist when we made this 'probe' file thingy.  It never was a great
> fit for sysfs anyway.
> 
> -- Dave

the configfs was introduced in 2005, you can refer to http://lwn.net/Articles/148973/.

I enabled the configfs, and I see that the configfs is not so popular as we expected,
I mount configfs to /sys/kernel/config, I get an empty directory. It means that nobody is 
using this file system, it is an interesting thing, is it means that configfs is deprecated?
If so, it might not be nessarry to develop a configfs interface for hotplug.

Dave & Greg,
	Can you provide an exmample to use configfs as interface in Linux kernel, I want to get
a live demo, thanks.

-- 
Thanks & Regards,
Shaohui

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
