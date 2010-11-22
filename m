Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 6EE156B0071
	for <linux-mm@kvack.org>; Sun, 21 Nov 2010 22:45:53 -0500 (EST)
Date: Mon, 22 Nov 2010 10:24:11 +0800
From: Shaohui Zheng <shaohui.zheng@intel.com>
Subject: Re: [patch 1/2] x86: add numa=possible command line option
Message-ID: <20101122022411.GC9081@shaohui>
References: <A24AE1FFE7AEC5489F83450EE98351BF28723FC48C@shsmsx502.ccr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <A24AE1FFE7AEC5489F83450EE98351BF28723FC48C@shsmsx502.ccr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org, gregkh@suse.de, rientjes@google.com
Cc: mingo@redhat.com, hpa@zytor.com, tglx@linutronix.de, lethal@linux-sh.org, ak@linux.intel.com, yinghai@kernel.org, randy.dunlap@oracle.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, shaohui.zheng@intel.com, haicheng.li@intel.com, haicheng.li@linux.intel.com
List-ID: <linux-mm.kvack.org>

> Adds a numa=possible=<N> command line option to set an additional N nodes
> as being possible for memory hotplug.  This set of possible nodes
> controls nr_node_ids and the sizes of several dynamically allocated node
> arrays.
> 
> This allows memory hotplug to create new nodes for newly added memory
> rather than binding it to existing nodes.
> 
> The first use-case for this will be node hotplug emulation which will use
> these possible nodes to create new nodes to test the memory hotplug
> callbacks and surrounding memory hotplug code.

It is the improved solution from thread http://lkml.org/lkml/2010/11/18/3,
our draft patch set all the nodes as possbile node, it wastes a lot of memory,
the command line numa=possible=<N> seems to be an acceptable, and it is a optimization
for our patch.

I like your active work attitude for the patch reviewing, it is real helpful to 
improve the patch quality.

the NUMA Hotplug Emulator is an overall solution for Node/CPU/Memory hotplug
emulation, it includes a lot of engineers' review comments and feedbacks in the
mailling list. We review and test each version very carefully, and make sure
each version is very stable and it includes in most of the feedbacks, so we deliver
each version very slow.

we do NOT want to split the emulator into many parts, and want to maintain them together.
How about add this patch into our emulator patchset, and add your sign-off?. Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
