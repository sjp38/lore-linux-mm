Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 32DD36B0087
	for <linux-mm@kvack.org>; Thu, 18 Nov 2010 16:31:54 -0500 (EST)
Received: from hpaq5.eem.corp.google.com (hpaq5.eem.corp.google.com [172.25.149.5])
	by smtp-out.google.com with ESMTP id oAILVofX008702
	for <linux-mm@kvack.org>; Thu, 18 Nov 2010 13:31:50 -0800
Received: from gyh20 (gyh20.prod.google.com [10.243.50.212])
	by hpaq5.eem.corp.google.com with ESMTP id oAILVB9a030591
	for <linux-mm@kvack.org>; Thu, 18 Nov 2010 13:31:49 -0800
Received: by gyh20 with SMTP id 20so2397718gyh.3
        for <linux-mm@kvack.org>; Thu, 18 Nov 2010 13:31:49 -0800 (PST)
Date: Thu, 18 Nov 2010 13:31:45 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [7/8,v3] NUMA Hotplug Emulator: extend memory probe interface
 to support NUMA
In-Reply-To: <20101118044850.GC2408@shaohui>
Message-ID: <alpine.DEB.2.00.1011181328540.26680@chino.kir.corp.google.com>
References: <20101117020759.016741414@intel.com> <20101117021000.916235444@intel.com> <1290019807.9173.3789.camel@nimitz> <alpine.DEB.2.00.1011171312590.10254@chino.kir.corp.google.com> <20101118044850.GC2408@shaohui>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Shaohui Zheng <shaohui.zheng@intel.com>
Cc: Dave Hansen <dave@linux.vnet.ibm.com>, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, haicheng.li@linux.intel.com, lethal@linux-sh.org, ak@linux.intel.com, shaohui.zheng@linux.intel.com, Haicheng Li <haicheng.li@intel.com>, Wu Fengguang <fengguang.wu@intel.com>, Greg KH <greg@kroah.com>
List-ID: <linux-mm.kvack.org>

On Thu, 18 Nov 2010, Shaohui Zheng wrote:

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

You're referring to the inability to remove memory sections for 
CONFIG_SPARSEMEM_VMEMMAP?  You should still able to test the offlining 
with other memory models of emulated nodes by using the generic support 
already implemented for CONFIG_MEMORY_HOTREMOVE; the short answer is that 
it probably shouldn't matter at all since we already support node 
hot-remove and the fact that they are emulated nodes isn't really of 
interest.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
