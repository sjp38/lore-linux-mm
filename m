Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 9EB406B0087
	for <linux-mm@kvack.org>; Tue,  7 Dec 2010 19:45:02 -0500 (EST)
Date: Wed, 8 Dec 2010 07:20:00 +0800
From: Shaohui Zheng <shaohui.zheng@linux.intel.com>
Subject: Re: [1/7,v8] NUMA Hotplug Emulator: documentation
Message-ID: <20101207232000.GA5353@shaohui>
References: <20101207010033.280301752@intel.com>
 <20101207010139.681125359@intel.com>
 <20101207182420.GA2038@mgebm.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101207182420.GA2038@mgebm.net>
Sender: owner-linux-mm@kvack.org
To: Eric B Munson <emunson@mgebm.net>
Cc: shaohui.zheng@intel.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, haicheng.li@linux.intel.com, lethal@linux-sh.org, ak@linux.intel.com, rientjes@google.com, dave@linux.vnet.ibm.com, gregkh@suse.de, Haicheng Li <haicheng.li@intel.com>
List-ID: <linux-mm.kvack.org>

On Tue, Dec 07, 2010 at 11:24:20AM -0700, Eric B Munson wrote:
> Shaohui,
> 
> The documentation patch seems to be stale, it needs to be updated to match the
> new file names.
> 
Eric,
	the major change on the patchset is on the interface, for the v8 emulator,
we accept David's per-node debugfs add_memory interface, we already included
in the documentation patch. the change is very small, so it is not obvious.

This is the change on the documentation compare with v7:
+3) Memory hotplug emulation:
+
+The emulator reserves memory before OS boots, the reserved memory region is
+removed from e820 table. Each online node has an add_memory interface, and
+memory can be hot-added via the per-ndoe add_memory debugfs interface.
+
+The difficulty of Memory Release is well-known, we have no plan for it until
+now.
+
+ - reserve memory thru a kernel boot paramter
+ 	mem=1024m
+
+ - add a memory section to node 3
+    # echo 0x40000000 > mem_hotplug/node3/add_memory
+	OR
+    # echo 1024m > mem_hotplug/node3/add_memory
+

-- 
Thanks & Regards,
Shaohui

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
