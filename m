Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 209A28D0080
	for <linux-mm@kvack.org>; Wed, 17 Nov 2010 03:16:55 -0500 (EST)
Received: from wpaz17.hot.corp.google.com (wpaz17.hot.corp.google.com [172.24.198.81])
	by smtp-out.google.com with ESMTP id oAH8Gqg8003631
	for <linux-mm@kvack.org>; Wed, 17 Nov 2010 00:16:53 -0800
Received: from iwn38 (iwn38.prod.google.com [10.241.68.102])
	by wpaz17.hot.corp.google.com with ESMTP id oAH8Gpsv030436
	for <linux-mm@kvack.org>; Wed, 17 Nov 2010 00:16:51 -0800
Received: by iwn38 with SMTP id 38so566861iwn.6
        for <linux-mm@kvack.org>; Wed, 17 Nov 2010 00:16:50 -0800 (PST)
Date: Wed, 17 Nov 2010 00:16:47 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [2/8,v3] NUMA Hotplug Emulator: infrastructure of NUMA hotplug
 emulation
In-Reply-To: <20101117021000.568681101@intel.com>
Message-ID: <alpine.DEB.2.00.1011162359160.17408@chino.kir.corp.google.com>
References: <20101117020759.016741414@intel.com> <20101117021000.568681101@intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Shaohui Zheng <shaohui.zheng@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, haicheng.li@linux.intel.com, lethal@linux-sh.org, ak@linux.intel.com, shaohui.zheng@linux.intel.com, Yinghai Lu <yinghai@kernel.org>, Haicheng Li <haicheng.li@intel.com>
List-ID: <linux-mm.kvack.org>

On Wed, 17 Nov 2010, shaohui.zheng@intel.com wrote:

> From: Haicheng Li <haicheng.li@intel.com>
> 
> NUMA hotplug emulator introduces a new node state N_HIDDEN to
> identify the fake offlined node. It firstly hides RAM via E820
> table and then emulates fake offlined nodes with the hidden RAM.
> 

Hmm, why can't you use numa=hide to hide a specified quantity of memory 
from the kernel and then use the add_memory() interface to hot-add the 
offlined memory in the desired quantity?  In other words, why do you need 
to track the offlined nodes with a state?

The userspace interface would take a desired size of hidden memory to 
hot-add and the node id would be the first_unset_node(node_online_map).

> After system bootup, user is able to hotplug-add these offlined
> nodes, which is just similar to a real hardware hotplug behavior.
> 
> Using boot option "numa=hide=N*size" to fake offlined nodes:
> 	- N is the number of hidden nodes
> 	- size is the memory size (in MB) per hidden node.
> 

size should be parsed with memparse() so users can specify 'M' or 'G', it 
would even make your parsing code simpler.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
