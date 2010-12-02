Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 572E58D0002
	for <linux-mm@kvack.org>; Wed,  1 Dec 2010 19:55:49 -0500 (EST)
Received: from kpbe16.cbf.corp.google.com (kpbe16.cbf.corp.google.com [172.25.105.80])
	by smtp-out.google.com with ESMTP id oB20tlfM002755
	for <linux-mm@kvack.org>; Wed, 1 Dec 2010 16:55:47 -0800
Received: from pxi15 (pxi15.prod.google.com [10.243.27.15])
	by kpbe16.cbf.corp.google.com with ESMTP id oB20tUng000727
	for <linux-mm@kvack.org>; Wed, 1 Dec 2010 16:55:46 -0800
Received: by pxi15 with SMTP id 15so1257147pxi.33
        for <linux-mm@kvack.org>; Wed, 01 Dec 2010 16:55:46 -0800 (PST)
Date: Wed, 1 Dec 2010 16:55:42 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [7/8, v6] NUMA Hotplug Emulator: extend memory probe interface
 to support NUMA
In-Reply-To: <20101130071437.358387592@intel.com>
Message-ID: <alpine.DEB.2.00.1012011653530.1896@chino.kir.corp.google.com>
References: <20101130071324.908098411@intel.com> <20101130071437.358387592@intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Shaohui Zheng <shaohui.zheng@intel.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, haicheng.li@linux.intel.com, lethal@linux-sh.org, ak@linux.intel.com, shaohui.zheng@linux.intel.com, dave@linux.vnet.ibm.com, gregkh@suse.de, Haicheng Li <haicheng.li@intel.com>, Wu Fengguang <fengguang.wu@intel.com>
List-ID: <linux-mm.kvack.org>

On Tue, 30 Nov 2010, shaohui.zheng@intel.com wrote:

> From: Shaohui Zheng <shaohui.zheng@intel.com>
> 
> Extend memory probe interface to support an extra paramter nid,
> the reserved memory can be added into this node if node exists.
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
> it is more explicit to show meaning of the parameters.
> 

I don't like this interface, I think it would be much better to map the 
memory region to the desired node id prior to using probe as an extention 
to debugfs.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
