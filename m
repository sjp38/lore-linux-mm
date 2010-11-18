Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 0F7626B004A
	for <linux-mm@kvack.org>; Thu, 18 Nov 2010 01:24:55 -0500 (EST)
Date: Thu, 18 Nov 2010 15:24:16 +0900
From: Paul Mundt <lethal@linux-sh.org>
Subject: Re: [7/8,v3] NUMA Hotplug Emulator: extend memory probe interface to support NUMA
Message-ID: <20101118062416.GC17539@linux-sh.org>
References: <20101117020759.016741414@intel.com> <20101117021000.916235444@intel.com> <1290019807.9173.3789.camel@nimitz> <alpine.DEB.2.00.1011171312590.10254@chino.kir.corp.google.com> <20101118044850.GC2408@shaohui>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101118044850.GC2408@shaohui>
Sender: owner-linux-mm@kvack.org
To: Shaohui Zheng <shaohui.zheng@intel.com>
Cc: David Rientjes <rientjes@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, haicheng.li@linux.intel.com, ak@linux.intel.com, shaohui.zheng@linux.intel.com, Haicheng Li <haicheng.li@intel.com>, Wu Fengguang <fengguang.wu@intel.com>, Greg KH <greg@kroah.com>
List-ID: <linux-mm.kvack.org>

On Thu, Nov 18, 2010 at 12:48:50PM +0800, Shaohui Zheng wrote:
> On Wed, Nov 17, 2010 at 01:18:50PM -0800, David Rientjes wrote:
> > Then, export the amount of memory that is actually physically present in 
> > the e820 but was truncated by mem= and allow users to hot-add the memory 
> > via the probe interface.  Add a writeable 'node' file to offlined memory 
> > section directories and allow it to be changed prior to online.
> 
> for memory offlining, it is a known diffcult thing, and it is not supported 
> well in current kernel, so I do not suggest to provide the offline interface
> in the emulator, it just take more pains. We can consider to add it when
> the memory offlining works well.
> 
This is all stuff that the memblock API can deal with, I'm not sure why
there seems to be an insistence on wedging all manner of unrelated bits
in to e820. Many platforms using memblock today already offline large
amounts of contiguous physical memory for use in drivers, if you were to
follow this scheme and simply layer a node creation shim on top of that
you would end up with something that is almost entirely generic.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
