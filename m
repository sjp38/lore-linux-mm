Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 6648C6B0071
	for <linux-mm@kvack.org>; Tue, 30 Nov 2010 19:39:50 -0500 (EST)
Date: Wed, 1 Dec 2010 07:16:13 +0800
From: Shaohui Zheng <shaohui.zheng@intel.com>
Subject: Re: [2/8, v5] NUMA Hotplug Emulator: Add node hotplug emulation
Message-ID: <20101130231613.GA9117@shaohui>
References: <20101129091750.950277284@intel.com>
 <20101129091935.703824659@intel.com>
 <alpine.DEB.2.00.1011291600020.21653@chino.kir.corp.google.com>
 <20101130012205.GB3021@shaohui>
 <alpine.DEB.2.00.1011301208060.12979@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1011301208060.12979@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, haicheng.li@linux.intel.com, lethal@linux-sh.org, ak@linux.intel.com, shaohui.zheng@linux.intel.com, dave@linux.vnet.ibm.com, gregkh@suse.de, Haicheng Li <haicheng.li@intel.com>
List-ID: <linux-mm.kvack.org>

On Tue, Nov 30, 2010 at 12:10:09PM -0800, David Rientjes wrote:
> On Tue, 30 Nov 2010, Shaohui Zheng wrote:
> 
> > We have two memory hotplug interfaces here:
> > add_node: add a new NUMA node
> > probe: add memory section
> > 
> > so puting add_node to node/add_node and puting probe to memory/probe should make sense. 
> > it is similar with sysfs hierarchy.
> > 
> > if we want to move the add_node to mem_hotplug/add_node, I'd prefer to put the probe
> > interface to mem_hotplug/probe since they are also related to memory hotplug.
> > 
> > I will include this change in next patchset.
> > 
> 
> No, please don't move the 'probe' trigger to debugfs; hotadding memory 
> should not depend on CONFIG_DEBUG_FS.  Node hotplug emulation _is_ a 
> debugging function and can therefore be defined in debugfs as I did but 
> with a s/hotplug/mem_hotplug change that Greg suggested.

David,
	we provide both debugfs and sysfs interface for memory probe, the sysfs 
interface is always available. For debugfs interface, it depends on CONFIG_DEBUG_FS.
	we can also think that memory hotplug emulation _is_ a debuging function,
so we accept Dave's suggestion to provide debugfs interface.

-- 
Thanks & Regards,
Shaohui

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
