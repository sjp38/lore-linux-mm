Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 892078D000E
	for <linux-mm@kvack.org>; Wed,  1 Dec 2010 20:50:57 -0500 (EST)
Date: Thu, 2 Dec 2010 08:27:16 +0800
From: Shaohui Zheng <shaohui.zheng@intel.com>
Subject: Re: [8/8, v6] NUMA Hotplug Emulator: implement debugfs interface
 for memory probe
Message-ID: <20101202002716.GA13693@shaohui>
References: <A24AE1FFE7AEC5489F83450EE98351BF288D88D224@shsmsx502.ccr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <A24AE1FFE7AEC5489F83450EE98351BF288D88D224@shsmsx502.ccr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
To: "shaohui.zheng@linux.intel.com" <shaohui.zheng@linux.intel.com>, David Rientjes <rientjes@google.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, haicheng.li@linux.intel.com, lethal@linux-sh.org, ak@linux.intel.com, dave@linux.vnet.ibm.com, gregkh@suse.de, Haicheng Li <haicheng.li@intel.com>
List-ID: <linux-mm.kvack.org>

> 
> I doubt either Greg or Dave suggested adding duplicate interfaces for the 
> same functionality.
> 
> The difference is that we needed to add the add_node interface in a new 
> mem_hotplug debugfs directory because it's only useful for debugging 
> kernel code and, thus, doesn't really have an appropriate place in sysfs.  
> Nobody is going to use add_node unless they lack hotpluggable memory 
> sections in their SRAT and want to debug the memory hotplug callers.  For 
> example, I already wrote all of this node hotplug emulation stuff when I 
> wrote the node hotplug support for SLAB.
> 
> Memory hotplug, however, does serve a non-debugging function and is 
> appropriate in sysfs since this is how people hotplug memory.  It's an ABI 
> that we can't simply remove without deprecation over a substantial period 
> of time and in this case it doesn't seem to have a clear advantage.  We 
> need not add special emulation support for something that is already 
> possible for real systems, so adding a duplicate interface in debugfs is 
> inappropriate.

so we should still keep the sysfs memory/probe interface without any modifications,
but for the debugfs mem_hotplug/probe interface, we can add the memory region 
to a desired node. It is an extention for the sysfs memory/probe interface, it can 
be used for memory hotplug emulation. Do I understand it correctly?

-- 
Thanks & Regards,
Shaohui

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
