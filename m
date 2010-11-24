Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 6B68E6B0071
	for <linux-mm@kvack.org>; Wed, 24 Nov 2010 03:07:21 -0500 (EST)
Date: Wed, 24 Nov 2010 14:45:16 +0800
From: Shaohui Zheng <shaohui.zheng@intel.com>
Subject: Re: [patch 2/2] mm: add node hotplug emulation
Message-ID: <20101124064516.GA6777@shaohui>
References: <A24AE1FFE7AEC5489F83450EE98351BF28723FC4A7@shsmsx502.ccr.corp.intel.com>
 <20101122014706.GB9081@shaohui>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101122014706.GB9081@shaohui>
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org, gregkh@suse.de, rientjes@google.com
Cc: mingo@redhat.com, hpa@zytor.com, tglx@linutronix.de, lethal@linux-sh.org, ak@linux.intel.com, yinghai@kernel.org, randy.dunlap@oracle.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, haicheng.li@intel.com, haicheng.li@linux.intel.com, shaohui.zheng@linux.intel.com
List-ID: <linux-mm.kvack.org>

On Mon, Nov 22, 2010 at 09:47:06AM +0800, Shaohui Zheng wrote:
> On Mon, Nov 22, 2010 at 09:47:02AM +0800, Zheng, Shaohui wrote:
> 
> For cpu/memory physical hotplug, we have the unique interface probe/release,
> it is the _standard_ interface, it is not only for x86, ppc use the the interface
> as well. For node hotplug, it should follow the rule.
> 
> You are creating a new interface /sys/devices/system/memory/add_node to add both
> memory and node, you are just trying to create DUPLICATED feature with the
> memory probe interface, it breaks the rule. 
> 
> I did NOT see the feature difference with our emulator patch http://lkml.org/lkml/2010/11/16/740,
> you pick up a piece of feature from emulator, and create an other thread. You
> are trying to replace the interface with a new one, which is not recommended.
> the memory probe interface is already powerful and flexible enough after apply
> our patch. What's more important, it keeps the old directives, and it maintains
> backwards compatibility.
> 
> Add a memory section(128M) to node 3(boots with mem=1024m)
> 
> 	echo 0x40000000,3 > memory/probe
> 
> And more we make it friendly, it is possible to add memory to do
> 
> 	echo 3g > memory/probe
> 	echo 1024m,3 > memory/probe
> 
> It maintains backwards compatibility.
> 
> Another format suggested by Dave Hansen:
> 
> 	echo physical_address=0x40000000 numa_node=3 > memory/probe
> 
> we should not need duplicated interface /sys/devices/system/memory/add_node here.

ah, a long time silence.

Does somebody know the status of this patch, is it accepted by the maintainer?
I am not in patch's CC list, so I will not get mail notice when the patch was
accepted by the maintainer.

the other hotplug emulator patches has dependency on this patch, so I can not
re-make my patchset if this patch is still pending. thanks.

-- 
Thanks & Regards,
Shaohui

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
