Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id AE0F26B0087
	for <linux-mm@kvack.org>; Thu,  2 Dec 2010 18:37:12 -0500 (EST)
Received: from wpaz17.hot.corp.google.com (wpaz17.hot.corp.google.com [172.24.198.81])
	by smtp-out.google.com with ESMTP id oB2Nb85P005971
	for <linux-mm@kvack.org>; Thu, 2 Dec 2010 15:37:08 -0800
Received: from pvg12 (pvg12.prod.google.com [10.241.210.140])
	by wpaz17.hot.corp.google.com with ESMTP id oB2NaowC021419
	for <linux-mm@kvack.org>; Thu, 2 Dec 2010 15:37:07 -0800
Received: by pvg12 with SMTP id 12so1758196pvg.12
        for <linux-mm@kvack.org>; Thu, 02 Dec 2010 15:37:06 -0800 (PST)
Date: Thu, 2 Dec 2010 15:37:03 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch 7/7, v7] NUMA Hotplug Emulator: Implement mem_hotplug/add_memory
 debugfs interface
In-Reply-To: <20101202050737.651398415@intel.com>
Message-ID: <alpine.DEB.2.00.1012021534140.6878@chino.kir.corp.google.com>
References: <20101202050518.819599911@intel.com> <20101202050737.651398415@intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Shaohui Zheng <shaohui.zheng@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, haicheng.li@linux.intel.com, lethal@linux-sh.org, ak@linux.intel.com, shaohui.zheng@linux.intel.com, dave@linux.vnet.ibm.com, Greg Kroah-Hartman <gregkh@suse.de>, Haicheng Li <haicheng.li@intel.com>
List-ID: <linux-mm.kvack.org>

On Thu, 2 Dec 2010, shaohui.zheng@intel.com wrote:

> From:  Shaohui Zheng <shaohui.zheng@intel.com>
> 
> Add mem_hotplug/add_memory interface to support to memory hotplug emulation.
> the reserved memory can be added into desired node with this interface.
> 
> Add a memory section(128M) to node 3(boots with mem=1024m)
> 
> 	echo 0x40000000,3 > mem_hotplug/add_memory
> 
> And more we make it friendly, it is possible to add memory to do
> 
> 	echo 3g > mem_hotplug/add_memory
> 	echo 1024m,3 > mem_hotplug/add_memory
> 
> Another format suggested by Dave Hansen:
> 
> 	echo physical_address=0x40000000 numa_node=3 > mem_hotplug/add_memory
> 
> it is more explicit to show meaning of the parameters.
> 

NACK, we don't need such convoluted definitions if debugfs were extended 
with per-node triggers to add_memory as I suggested in v6 of your 
proposal:

	/sys/kernel/debug/mem_hotplug/add_node (already exists)
	/sys/kernel/debug/mem_hotplug/node0/add_memory
	/sys/kernel/debug/mem_hotplug/node1/add_memory
	...

You can then write a physical starting address to the add_memory files to 
hotadd memory to a node other than the one to which it has physical 
affinity.  This is much more extendable if we add additional per-node 
triggers later.

It would also be helpful if you were to reach consensus on the matters 
under discussion before posting a new version of your patchset everyday.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
