Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 053FC8D000E
	for <linux-mm@kvack.org>; Wed,  1 Dec 2010 21:35:34 -0500 (EST)
From: "Zheng, Shaohui" <shaohui.zheng@intel.com>
Date: Thu, 2 Dec 2010 10:35:00 +0800
Subject: RE: [8/8, v6] NUMA Hotplug Emulator: implement debugfs interface
 for memory probe
Message-ID: <A24AE1FFE7AEC5489F83450EE98351BF288D88D2B8@shsmsx502.ccr.corp.intel.com>
References: <A24AE1FFE7AEC5489F83450EE98351BF288D88D224@shsmsx502.ccr.corp.intel.com>
 <20101202002716.GA13693@shaohui>
 <alpine.DEB.2.00.1012011807190.13942@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.1012011807190.13942@chino.kir.corp.google.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "lethal@linux-sh.org" <lethal@linux-sh.org>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Greg KH <gregkh@suse.de>, "Li, Haicheng" <haicheng.li@intel.com>, "shaohui.zheng@linux.intel.com" <shaohui.zheng@linux.intel.com>
List-ID: <linux-mm.kvack.org>

Why should we add so many interfaces for memory hotplug emulation? If so, w=
e should create both sysfs and debugfs=20
entries for an online node, we are trying to add redundant code logic.

We need not make a simple thing such complicated, Simple is beautiful, I'd =
prefer to rename the mem_hotplug/probe=20
interface as mem_hotplug/add_memory.

	/sys/kernel/debug/mem_hotplug/add_node (already exists)
	/sys/kernel/debug/mem_hotplug/add_memory (rename probe as add_memory)

Thanks & Regards,
Shaohui


-----Original Message-----
From: David Rientjes [mailto:rientjes@google.com]=20
Sent: Thursday, December 02, 2010 10:13 AM
To: Zheng, Shaohui
Cc: Andrew Morton; linux-mm@kvack.org; linux-kernel@vger.kernel.org; lethal=
@linux-sh.org; Andi Kleen; Dave Hansen; Greg KH; Li, Haicheng
Subject: Re: [8/8, v6] NUMA Hotplug Emulator: implement debugfs interface f=
or memory probe

On Thu, 2 Dec 2010, Shaohui Zheng wrote:

> so we should still keep the sysfs memory/probe interface without any modi=
fications,
> but for the debugfs mem_hotplug/probe interface, we can add the memory re=
gion=20
> to a desired node.

This feature would be distinct from the add_node interface already=20
provided: instead of hotplugging a new node to test the memory hotplug=20
callbacks, this new interface would only be hotadding new memory to a node=
=20
other than the one it has physical affinity with.  For that support, I'd=20
suggest new probe files in debugfs for each online node:

	/sys/kernel/debug/mem_hotplug/add_node (already exists)
	/sys/kernel/debug/mem_hotplug/node0/add_memory
	/sys/kernel/debug/mem_hotplug/node1/add_memory
	...

and then you can offline and remove that memory with the existing hotplug=20
support (CONFIG_MEMORY_HOTPLUG and CONFIG_MEMORY_HOTREMOVE, respectively).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
