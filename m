Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 215906B004A
	for <linux-mm@kvack.org>; Tue, 30 Nov 2010 15:10:46 -0500 (EST)
Received: from kpbe17.cbf.corp.google.com (kpbe17.cbf.corp.google.com [172.25.105.81])
	by smtp-out.google.com with ESMTP id oAUKAOcb029097
	for <linux-mm@kvack.org>; Tue, 30 Nov 2010 12:10:25 -0800
Received: from pwi10 (pwi10.prod.google.com [10.241.219.10])
	by kpbe17.cbf.corp.google.com with ESMTP id oAUKABch008029
	for <linux-mm@kvack.org>; Tue, 30 Nov 2010 12:10:18 -0800
Received: by pwi10 with SMTP id 10so1195553pwi.13
        for <linux-mm@kvack.org>; Tue, 30 Nov 2010 12:10:11 -0800 (PST)
Date: Tue, 30 Nov 2010 12:10:09 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [2/8, v5] NUMA Hotplug Emulator: Add node hotplug emulation
In-Reply-To: <20101130012205.GB3021@shaohui>
Message-ID: <alpine.DEB.2.00.1011301208060.12979@chino.kir.corp.google.com>
References: <20101129091750.950277284@intel.com> <20101129091935.703824659@intel.com> <alpine.DEB.2.00.1011291600020.21653@chino.kir.corp.google.com> <20101130012205.GB3021@shaohui>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Shaohui Zheng <shaohui.zheng@intel.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, haicheng.li@linux.intel.com, lethal@linux-sh.org, ak@linux.intel.com, shaohui.zheng@linux.intel.com, dave@linux.vnet.ibm.com, gregkh@suse.de, Haicheng Li <haicheng.li@intel.com>
List-ID: <linux-mm.kvack.org>

On Tue, 30 Nov 2010, Shaohui Zheng wrote:

> We have two memory hotplug interfaces here:
> add_node: add a new NUMA node
> probe: add memory section
> 
> so puting add_node to node/add_node and puting probe to memory/probe should make sense. 
> it is similar with sysfs hierarchy.
> 
> if we want to move the add_node to mem_hotplug/add_node, I'd prefer to put the probe
> interface to mem_hotplug/probe since they are also related to memory hotplug.
> 
> I will include this change in next patchset.
> 

No, please don't move the 'probe' trigger to debugfs; hotadding memory 
should not depend on CONFIG_DEBUG_FS.  Node hotplug emulation _is_ a 
debugging function and can therefore be defined in debugfs as I did but 
with a s/hotplug/mem_hotplug change that Greg suggested.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
