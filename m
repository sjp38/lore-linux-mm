Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 9DACE6B004A
	for <linux-mm@kvack.org>; Thu, 18 Nov 2010 01:09:56 -0500 (EST)
Date: Thu, 18 Nov 2010 12:48:50 +0800
From: Shaohui Zheng <shaohui.zheng@intel.com>
Subject: Re: [7/8,v3] NUMA Hotplug Emulator: extend memory probe interface
 to support NUMA
Message-ID: <20101118044850.GC2408@shaohui>
References: <20101117020759.016741414@intel.com>
 <20101117021000.916235444@intel.com>
 <1290019807.9173.3789.camel@nimitz>
 <alpine.DEB.2.00.1011171312590.10254@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1011171312590.10254@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Dave Hansen <dave@linux.vnet.ibm.com>, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, haicheng.li@linux.intel.com, lethal@linux-sh.org, ak@linux.intel.com, shaohui.zheng@linux.intel.com, Haicheng Li <haicheng.li@intel.com>, Wu Fengguang <fengguang.wu@intel.com>, Greg KH <greg@kroah.com>
List-ID: <linux-mm.kvack.org>

On Wed, Nov 17, 2010 at 01:18:50PM -0800, David Rientjes wrote:
> On Wed, 17 Nov 2010, Dave Hansen wrote:
> 
> > The other thing that Greg suggested was to use configfs.  Looking back
> > on it, that makes a lot of sense.  We can do better than these "probe"
> > files.
> > 
> > In your case, it might be useful to tell the kernel to be able to add
> > memory in a node and add the node all in one go.  That'll probably be
> > closer to what the hardware will do, and will exercise different code
> > paths that the separate "add node", "then add memory" steps that you're
> > using here.
> > 
> 
> That seems like a seperate issue of moving the memory hotplug interface 
> over to configfs and that seems like it will cause a lot of userspace 
> breakage.  The memory hotplug interface can already add memory to a node 
> without using the ACPI notifier, so what does it have to do with this 
> patchset?

Agree with you, I do not suggest to implement it in this patchset.

> 
> I think what this patchset really wants to do is map offline hot-added 
> memory to a different node id before it is onlined.  It needs no 
> additional command-line interface or kconfig options, users just need to 
> physically hot-add memory at runtime or use mem= when booting to reserve 
> present memory from being used.

I already send out the implementation in another email, you can help to do
a review.

> 
> Then, export the amount of memory that is actually physically present in 
> the e820 but was truncated by mem= and allow users to hot-add the memory 
> via the probe interface.  Add a writeable 'node' file to offlined memory 
> section directories and allow it to be changed prior to online.

for memory offlining, it is a known diffcult thing, and it is not supported 
well in current kernel, so I do not suggest to provide the offline interface
in the emulator, it just take more pains. We can consider to add it when
the memory offlining works well.

-- 
Thanks & Regards,
Shaohui

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
