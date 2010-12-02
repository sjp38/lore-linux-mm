Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 3D61B8D0002
	for <linux-mm@kvack.org>; Wed,  1 Dec 2010 19:59:29 -0500 (EST)
Received: from wpaz33.hot.corp.google.com (wpaz33.hot.corp.google.com [172.24.198.97])
	by smtp-out.google.com with ESMTP id oB20xRq7013118
	for <linux-mm@kvack.org>; Wed, 1 Dec 2010 16:59:27 -0800
Received: from pxi9 (pxi9.prod.google.com [10.243.27.9])
	by wpaz33.hot.corp.google.com with ESMTP id oB20xP4A015043
	for <linux-mm@kvack.org>; Wed, 1 Dec 2010 16:59:26 -0800
Received: by pxi9 with SMTP id 9so1936435pxi.37
        for <linux-mm@kvack.org>; Wed, 01 Dec 2010 16:59:25 -0800 (PST)
Date: Wed, 1 Dec 2010 16:59:22 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [2/8, v5] NUMA Hotplug Emulator: Add node hotplug emulation
In-Reply-To: <20101130231613.GA9117@shaohui>
Message-ID: <alpine.DEB.2.00.1012011658540.1896@chino.kir.corp.google.com>
References: <20101129091750.950277284@intel.com> <20101129091935.703824659@intel.com> <alpine.DEB.2.00.1011291600020.21653@chino.kir.corp.google.com> <20101130012205.GB3021@shaohui> <alpine.DEB.2.00.1011301208060.12979@chino.kir.corp.google.com>
 <20101130231613.GA9117@shaohui>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Shaohui Zheng <shaohui.zheng@intel.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, haicheng.li@linux.intel.com, lethal@linux-sh.org, ak@linux.intel.com, shaohui.zheng@linux.intel.com, dave@linux.vnet.ibm.com, gregkh@suse.de, Haicheng Li <haicheng.li@intel.com>
List-ID: <linux-mm.kvack.org>

On Wed, 1 Dec 2010, Shaohui Zheng wrote:

> David,
> 	we provide both debugfs and sysfs interface for memory probe, the sysfs 
> interface is always available. For debugfs interface, it depends on CONFIG_DEBUG_FS.
> 	we can also think that memory hotplug emulation _is_ a debuging function,
> so we accept Dave's suggestion to provide debugfs interface.
> 

We don't need two different interfaces, one in sysfs and one in debugfs, 
to hotplug memory.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
