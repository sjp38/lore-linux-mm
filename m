Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id ADC7A8D000E
	for <linux-mm@kvack.org>; Wed,  1 Dec 2010 21:13:27 -0500 (EST)
Received: from kpbe18.cbf.corp.google.com (kpbe18.cbf.corp.google.com [172.25.105.82])
	by smtp-out.google.com with ESMTP id oB22DN7w017385
	for <linux-mm@kvack.org>; Wed, 1 Dec 2010 18:13:23 -0800
Received: from pvg13 (pvg13.prod.google.com [10.241.210.141])
	by kpbe18.cbf.corp.google.com with ESMTP id oB22DLRe009879
	for <linux-mm@kvack.org>; Wed, 1 Dec 2010 18:13:22 -0800
Received: by pvg13 with SMTP id 13so1557540pvg.38
        for <linux-mm@kvack.org>; Wed, 01 Dec 2010 18:13:21 -0800 (PST)
Date: Wed, 1 Dec 2010 18:13:18 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [8/8, v6] NUMA Hotplug Emulator: implement debugfs interface
 for memory probe
In-Reply-To: <20101202002716.GA13693@shaohui>
Message-ID: <alpine.DEB.2.00.1012011807190.13942@chino.kir.corp.google.com>
References: <A24AE1FFE7AEC5489F83450EE98351BF288D88D224@shsmsx502.ccr.corp.intel.com> <20101202002716.GA13693@shaohui>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Shaohui Zheng <shaohui.zheng@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, lethal@linux-sh.org, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Greg KH <gregkh@suse.de>, Haicheng Li <haicheng.li@intel.com>
List-ID: <linux-mm.kvack.org>

On Thu, 2 Dec 2010, Shaohui Zheng wrote:

> so we should still keep the sysfs memory/probe interface without any modifications,
> but for the debugfs mem_hotplug/probe interface, we can add the memory region 
> to a desired node.

This feature would be distinct from the add_node interface already 
provided: instead of hotplugging a new node to test the memory hotplug 
callbacks, this new interface would only be hotadding new memory to a node 
other than the one it has physical affinity with.  For that support, I'd 
suggest new probe files in debugfs for each online node:

	/sys/kernel/debug/mem_hotplug/add_node (already exists)
	/sys/kernel/debug/mem_hotplug/node0/add_memory
	/sys/kernel/debug/mem_hotplug/node1/add_memory
	...

and then you can offline and remove that memory with the existing hotplug 
support (CONFIG_MEMORY_HOTPLUG and CONFIG_MEMORY_HOTREMOVE, respectively).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
