Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id BC95B6B004A
	for <linux-mm@kvack.org>; Mon, 29 Nov 2010 19:01:25 -0500 (EST)
Received: from hpaq5.eem.corp.google.com (hpaq5.eem.corp.google.com [172.25.149.5])
	by smtp-out.google.com with ESMTP id oAU01MLj017921
	for <linux-mm@kvack.org>; Mon, 29 Nov 2010 16:01:22 -0800
Received: from pvc21 (pvc21.prod.google.com [10.241.209.149])
	by hpaq5.eem.corp.google.com with ESMTP id oAU00WsD015754
	for <linux-mm@kvack.org>; Mon, 29 Nov 2010 16:01:20 -0800
Received: by pvc21 with SMTP id 21so1102563pvc.31
        for <linux-mm@kvack.org>; Mon, 29 Nov 2010 16:01:20 -0800 (PST)
Date: Mon, 29 Nov 2010 16:01:18 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [2/8, v5] NUMA Hotplug Emulator: Add node hotplug emulation
In-Reply-To: <20101129091935.703824659@intel.com>
Message-ID: <alpine.DEB.2.00.1011291600020.21653@chino.kir.corp.google.com>
References: <20101129091750.950277284@intel.com> <20101129091935.703824659@intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Shaohui Zheng <shaohui.zheng@intel.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, haicheng.li@linux.intel.com, lethal@linux-sh.org, ak@linux.intel.com, shaohui.zheng@linux.intel.com, dave@linux.vnet.ibm.com, gregkh@suse.de, Haicheng Li <haicheng.li@intel.com>
List-ID: <linux-mm.kvack.org>

On Mon, 29 Nov 2010, shaohui.zheng@intel.com wrote:

> From: David Rientjes <rientjes@google.com>
> 
> Add an interface to allow new nodes to be added when performing memory
> hot-add.  This provides a convenient interface to test memory hotplug
> notifier callbacks and surrounding hotplug code when new nodes are
> onlined without actually having a machine with such hotpluggable SRAT
> entries.
> 
> This adds a new debugfs interface at /sys/kernel/debug/hotplug/add_node
> that behaves in a similar way to the memory hot-add "probe" interface.
> Its format is size@start, where "size" is the size of the new node to be
> added and "start" is the physical address of the new memory.
> 

Looks like you've changed some of the references in my changlog to 
node/add_node, but not others, such as the above.  I'd actually much 
rather prefer to take Greg's latest suggestion of doing 
s/hotplug/mem_hotplug instead.

Would it be possible to repost the patch with that change?

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
