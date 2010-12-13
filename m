Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 757966B008C
	for <linux-mm@kvack.org>; Mon, 13 Dec 2010 15:56:39 -0500 (EST)
Received: from wpaz1.hot.corp.google.com (wpaz1.hot.corp.google.com [172.24.198.65])
	by smtp-out.google.com with ESMTP id oBDKuH0l022244
	for <linux-mm@kvack.org>; Mon, 13 Dec 2010 12:56:18 -0800
Received: from pxi2 (pxi2.prod.google.com [10.243.27.2])
	by wpaz1.hot.corp.google.com with ESMTP id oBDKu9Bt031485
	for <linux-mm@kvack.org>; Mon, 13 Dec 2010 12:56:16 -0800
Received: by pxi2 with SMTP id 2so1361661pxi.12
        for <linux-mm@kvack.org>; Mon, 13 Dec 2010 12:56:16 -0800 (PST)
Date: Mon, 13 Dec 2010 12:56:13 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [7/7,v8] NUMA Hotplug Emulator: Implement per-node add_memory
 debugfs interface
In-Reply-To: <20101213020924.GB19637@shaohui>
Message-ID: <alpine.DEB.2.00.1012131255580.13478@chino.kir.corp.google.com>
References: <A24AE1FFE7AEC5489F83450EE98351BF2A40FED20A@shsmsx502.ccr.corp.intel.com> <20101209012124.GD5798@shaohui> <alpine.DEB.2.00.1012091325530.13564@chino.kir.corp.google.com> <20101209235705.GA10674@shaohui> <alpine.DEB.2.00.1012101529190.30039@chino.kir.corp.google.com>
 <20101213020924.GB19637@shaohui>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Shaohui Zheng <shaohui.zheng@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, haicheng.li@linux.intel.com, lethal@linux-sh.org, Andi Kleen <ak@linux.intel.com>, Greg Kroah-Hartman <gregkh@suse.de>
List-ID: <linux-mm.kvack.org>

On Mon, 13 Dec 2010, Shaohui Zheng wrote:

> For the state transition to N_HIGH_MEMORY, it does not happen on the above too
> interfaces. It happens when the memory was onlined with sysfs /sys/device/system/memory/memoryXX/online
> interface.
> 
> That is the code path:
> store_mem_state
> 	->memory_block_change_state
> 	 	->memory_block_action
> 			->online_pages
> 
> 			if (onlined_pages) {
> 				kswapd_run(zone_to_nid(zone));
> 				node_set_state(zone_to_nid(zone), N_HIGH_MEMORY);
> 			}
> 
> does it address your question? thanks.
> 

Ok, thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
