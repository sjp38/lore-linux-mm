Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 5E6296B00ED
	for <linux-mm@kvack.org>; Wed, 17 Nov 2010 04:12:01 -0500 (EST)
Date: Wed, 17 Nov 2010 15:51:28 +0800
From: Shaohui Zheng <shaohui.zheng@intel.com>
Subject: Re: [2/8,v3] NUMA Hotplug Emulator: infrastructure of NUMA hotplug
 emulation
Message-ID: <20101117075128.GA30254@shaohui>
References: <20101117020759.016741414@intel.com>
 <20101117021000.568681101@intel.com>
 <alpine.DEB.2.00.1011162359160.17408@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1011162359160.17408@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, haicheng.li@linux.intel.com, lethal@linux-sh.org, ak@linux.intel.com, shaohui.zheng@linux.intel.com, Yinghai Lu <yinghai@kernel.org>, Haicheng Li <haicheng.li@intel.com>
List-ID: <linux-mm.kvack.org>

On Wed, Nov 17, 2010 at 12:16:47AM -0800, David Rientjes wrote:
> On Wed, 17 Nov 2010, shaohui.zheng@intel.com wrote:
> 
> > From: Haicheng Li <haicheng.li@intel.com>
> > 
> > NUMA hotplug emulator introduces a new node state N_HIDDEN to
> > identify the fake offlined node. It firstly hides RAM via E820
> > table and then emulates fake offlined nodes with the hidden RAM.
> > 
> 
> Hmm, why can't you use numa=hide to hide a specified quantity of memory 
> from the kernel and then use the add_memory() interface to hot-add the 
> offlined memory in the desired quantity?  In other words, why do you need 
> to track the offlined nodes with a state?
> 
> The userspace interface would take a desired size of hidden memory to 
> hot-add and the node id would be the first_unset_node(node_online_map).
Yes, it is a good idea, your solution is what we indeed do in our first 2
versions.  We use mem=memsize to hide memory, and we call add_memory interface
to hot-add offlined memory with desired quantity, and we can also add to
desired nodes(even through the nodes does not exists). it is very flexible
solution.

However, this solution was denied since we notice NUMA emulation, we should
reuse it.

Currently, our solution creates static nodes when OS boots, only the node with 
state N_HIDDEN can be hot-added with node/probe interface, and we can query 


> 
> > After system bootup, user is able to hotplug-add these offlined
> > nodes, which is just similar to a real hardware hotplug behavior.
> > 
> > Using boot option "numa=hide=N*size" to fake offlined nodes:
> > 	- N is the number of hidden nodes
> > 	- size is the memory size (in MB) per hidden node.
> > 
> 
> size should be parsed with memparse() so users can specify 'M' or 'G', it 
> would even make your parsing code simpler.
Agree, if we use memparse, users can specify 'M' or 'G', we will added it when
we send next version.

-- 
Thanks & Regards,
Shaohui

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
