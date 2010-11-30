Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id CC5E56B004A
	for <linux-mm@kvack.org>; Mon, 29 Nov 2010 21:45:20 -0500 (EST)
Date: Tue, 30 Nov 2010 09:22:05 +0800
From: Shaohui Zheng <shaohui.zheng@intel.com>
Subject: Re: [2/8, v5] NUMA Hotplug Emulator: Add node hotplug emulation
Message-ID: <20101130012205.GB3021@shaohui>
References: <20101129091750.950277284@intel.com>
 <20101129091935.703824659@intel.com>
 <alpine.DEB.2.00.1011291600020.21653@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1011291600020.21653@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, haicheng.li@linux.intel.com, lethal@linux-sh.org, ak@linux.intel.com, shaohui.zheng@linux.intel.com, dave@linux.vnet.ibm.com, gregkh@suse.de, Haicheng Li <haicheng.li@intel.com>
List-ID: <linux-mm.kvack.org>

On Mon, Nov 29, 2010 at 04:01:18PM -0800, David Rientjes wrote:
> On Mon, 29 Nov 2010, shaohui.zheng@intel.com wrote:
> 
> > From: David Rientjes <rientjes@google.com>
> > 
> > Add an interface to allow new nodes to be added when performing memory
> > hot-add.  This provides a convenient interface to test memory hotplug
> > notifier callbacks and surrounding hotplug code when new nodes are
> > onlined without actually having a machine with such hotpluggable SRAT
> > entries.
> > 
> > This adds a new debugfs interface at /sys/kernel/debug/hotplug/add_node
> > that behaves in a similar way to the memory hot-add "probe" interface.
> > Its format is size@start, where "size" is the size of the new node to be
> > added and "start" is the physical address of the new memory.
> > 
> 
> Looks like you've changed some of the references in my changlog to 
> node/add_node, but not others, such as the above.  I'd actually much 
> rather prefer to take Greg's latest suggestion of doing 
> s/hotplug/mem_hotplug instead.
> 
> Would it be possible to repost the patch with that change?
> 
> Thanks!

We have two memory hotplug interfaces here:
add_node: add a new NUMA node
probe: add memory section

so puting add_node to node/add_node and puting probe to memory/probe should make sense. 
it is similar with sysfs hierarchy.

if we want to move the add_node to mem_hotplug/add_node, I'd prefer to put the probe
interface to mem_hotplug/probe since they are also related to memory hotplug.

I will include this change in next patchset.

-- 
Thanks & Regards,
Shaohui

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
