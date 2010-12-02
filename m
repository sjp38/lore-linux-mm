Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 46B3C8D0002
	for <linux-mm@kvack.org>; Wed,  1 Dec 2010 20:06:35 -0500 (EST)
Received: from kpbe20.cbf.corp.google.com (kpbe20.cbf.corp.google.com [172.25.105.84])
	by smtp-out.google.com with ESMTP id oB2168ji012225
	for <linux-mm@kvack.org>; Wed, 1 Dec 2010 17:06:08 -0800
Received: from pzk26 (pzk26.prod.google.com [10.243.19.154])
	by kpbe20.cbf.corp.google.com with ESMTP id oB2167BF017705
	for <linux-mm@kvack.org>; Wed, 1 Dec 2010 17:06:07 -0800
Received: by pzk26 with SMTP id 26so1339998pzk.21
        for <linux-mm@kvack.org>; Wed, 01 Dec 2010 17:06:07 -0800 (PST)
Date: Wed, 1 Dec 2010 17:06:02 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [2/8, v6] NUMA Hotplug Emulator: Add numa=possible option
In-Reply-To: <20101130071436.836186525@intel.com>
Message-ID: <alpine.DEB.2.00.1012011705280.6088@chino.kir.corp.google.com>
References: <20101130071324.908098411@intel.com> <20101130071436.836186525@intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Shaohui Zheng <shaohui.zheng@intel.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, haicheng.li@linux.intel.com, lethal@linux-sh.org, ak@linux.intel.com, shaohui.zheng@linux.intel.com, dave@linux.vnet.ibm.com, gregkh@suse.de, Haicheng Li <haicheng.li@intel.com>
List-ID: <linux-mm.kvack.org>

On Tue, 30 Nov 2010, shaohui.zheng@intel.com wrote:

> From:  David Rientjes <rientjes@google.com>
> 
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
> 
> CC: Shaohui Zheng <shaohui.zheng@intel.com>
> CC: Haicheng Li <haicheng.li@intel.com>
> Signed-off-by: David Rientjes <rientjes@google.com>

You're going to need to add your Signed-off-by line immediately after mine 
if you're pushing these to a maintainer, you're along the submission 
chain.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
