Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 7E0326B004A
	for <linux-mm@kvack.org>; Thu, 18 Nov 2010 16:28:55 -0500 (EST)
Received: from kpbe18.cbf.corp.google.com (kpbe18.cbf.corp.google.com [172.25.105.82])
	by smtp-out.google.com with ESMTP id oAILSorr013694
	for <linux-mm@kvack.org>; Thu, 18 Nov 2010 13:28:50 -0800
Received: from gxk25 (gxk25.prod.google.com [10.202.11.25])
	by kpbe18.cbf.corp.google.com with ESMTP id oAILSfwX002934
	for <linux-mm@kvack.org>; Thu, 18 Nov 2010 13:28:49 -0800
Received: by gxk25 with SMTP id 25so2181697gxk.8
        for <linux-mm@kvack.org>; Thu, 18 Nov 2010 13:28:48 -0800 (PST)
Date: Thu, 18 Nov 2010 13:28:45 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [7/8,v3] NUMA Hotplug Emulator: extend memory probe interface
 to support NUMA
In-Reply-To: <20101118062416.GC17539@linux-sh.org>
Message-ID: <alpine.DEB.2.00.1011181326010.26680@chino.kir.corp.google.com>
References: <20101117020759.016741414@intel.com> <20101117021000.916235444@intel.com> <1290019807.9173.3789.camel@nimitz> <alpine.DEB.2.00.1011171312590.10254@chino.kir.corp.google.com> <20101118044850.GC2408@shaohui> <20101118062416.GC17539@linux-sh.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Paul Mundt <lethal@linux-sh.org>
Cc: Shaohui Zheng <shaohui.zheng@intel.com>, Dave Hansen <dave@linux.vnet.ibm.com>, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, haicheng.li@linux.intel.com, ak@linux.intel.com, shaohui.zheng@linux.intel.com, Haicheng Li <haicheng.li@intel.com>, Wu Fengguang <fengguang.wu@intel.com>, Greg KH <greg@kroah.com>
List-ID: <linux-mm.kvack.org>

On Thu, 18 Nov 2010, Paul Mundt wrote:

> This is all stuff that the memblock API can deal with, I'm not sure why
> there seems to be an insistence on wedging all manner of unrelated bits
> in to e820. Many platforms using memblock today already offline large
> amounts of contiguous physical memory for use in drivers, if you were to
> follow this scheme and simply layer a node creation shim on top of that
> you would end up with something that is almost entirely generic.
> 

I don't see why this patchset needs to use the memblock API at all, it 
should be built entirely on the generic mem-hotplug API.  The only 
extension needed is the remapping of removed memory to a new node id (done 
on x86 with update_nodes_add()) prior to add_memory() for each arch that 
supports onlining new nodes.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
