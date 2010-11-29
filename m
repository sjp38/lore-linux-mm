Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id CA6CC6B0099
	for <linux-mm@kvack.org>; Mon, 29 Nov 2010 05:45:23 -0500 (EST)
Message-Id: <20101129091750.950277284@intel.com>
Date: Mon, 29 Nov 2010 17:17:50 +0800
From: shaohui.zheng@intel.com
Subject: [0/8, v5]  NUMA Hotplug Emulator(v5) - Feedbacks & Responses
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, haicheng.li@linux.intel.com, lethal@linux-sh.org, ak@linux.intel.com, shaohui.zheng@linux.intel.com, rientjes@google.com, dave@linux.vnet.ibm.com, gregkh@suse.de
List-ID: <linux-mm.kvack.org>

Hi, All

	Thanks for all the review comments and feedbacks, This patcheset is v5 NUMA
Hotplug Emulator.

* PATCHSET INTRODUCTION

patch 1: Adds a numa=possible=<N> command line option to set an additional N nodes
		 as being possible for memory hotplug. 
	    
patch 2: Add node hotplug emulation, introduce debugfs node/add_node interface

patch 3: Abstract cpu register functions, make these interface friend for cpu
		 hotplug emulation
patch 4: Support cpu probe/release in x86, it provides a software method to hot
		 add/remove cpu with sysfs interface.
patch 5: Fake CPU socket with logical CPU on x86, to prevent the scheduling
		 domain to build the incorrect hierarchy.
patch 6: extend memory probe interface to support NUMA, we can add the memory to
		 a specified node with the interface.
patch 7: implement memory probe interface with debugfs
patch 8: Documentation.

* FEEDBACKS & RESPONSES

David: Suggests to use a flexible method to to do node hotplug emulation. After
       review our 2 versions emulator implemetations, David provides a better solution
	   to solve both the flexibility and memory wasting issue. 
	   
	   Add numa=possible=<N> command line option, provide sysfs inteface
	   /sys/devices/system/node/add_node interface, and move the inteface to debugfs
	   /sys/kernel/debug/hotplug/add_node after hearing the voice from community.

Greg KH: move the interface from hotplug/add_node to node/add_node

Response: Accept David's node=possible=<n> command line options. After talking
       with David, he agree to add his patch to our patchset, thanks David's solution(patch 1).

	   David's original interface /sys/kernel/debug/hotplug/add_node is not so clear for
	   node hotplug emulation, we accept Greg's suggestion, move the interface to ndoe/add_node  
	   (patch 2)
		 
Dave Hansen: For memory hotplug, Dave reminds Greg KH's advice, suggest us to use configfs replace
       sysfs. After Dave knows that it is just for test purpose, Dave thinks debugfs should
	   be the best.

Response: memory probe sysfs interface already exists, I'd like to still keep it, and extend it
       to support memory add on a specified node(patch 6).

	   We accepts Dave's suggestion, implement memory probe interface with debugfs(patch 7).

-- 
Thanks & Regards,
Shaohui


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
