Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 6D8218D0002
	for <linux-mm@kvack.org>; Wed,  1 Dec 2010 19:57:51 -0500 (EST)
Received: from hpaq14.eem.corp.google.com (hpaq14.eem.corp.google.com [172.25.149.14])
	by smtp-out.google.com with ESMTP id oB20vfLe013628
	for <linux-mm@kvack.org>; Wed, 1 Dec 2010 16:57:41 -0800
Received: from pxi7 (pxi7.prod.google.com [10.243.27.7])
	by hpaq14.eem.corp.google.com with ESMTP id oB20vdgg031375
	for <linux-mm@kvack.org>; Wed, 1 Dec 2010 16:57:39 -0800
Received: by pxi7 with SMTP id 7so1998542pxi.22
        for <linux-mm@kvack.org>; Wed, 01 Dec 2010 16:57:38 -0800 (PST)
Date: Wed, 1 Dec 2010 16:57:35 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [8/8, v6] NUMA Hotplug Emulator: implement debugfs interface
 for memory probe
In-Reply-To: <20101130071437.461969179@intel.com>
Message-ID: <alpine.DEB.2.00.1012011656590.1896@chino.kir.corp.google.com>
References: <20101130071324.908098411@intel.com> <20101130071437.461969179@intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Shaohui Zheng <shaohui.zheng@intel.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, haicheng.li@linux.intel.com, lethal@linux-sh.org, ak@linux.intel.com, shaohui.zheng@linux.intel.com, dave@linux.vnet.ibm.com, gregkh@suse.de, Haicheng Li <haicheng.li@intel.com>
List-ID: <linux-mm.kvack.org>

On Tue, 30 Nov 2010, shaohui.zheng@intel.com wrote:

> From: Shaohui Zheng <shaohui.zheng@intel.com>
> 
> Implement a debugfs inteface /sys/kernel/debug/mem_hotplug/probe for meomory hotplug
> emulation.  it accepts the same parameters like
> /sys/devices/system/memory/probe.
> 

NACK, we don't need two interfaces to do the same thing.  

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
