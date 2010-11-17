Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id D9F088D0002
	for <linux-mm@kvack.org>; Wed, 17 Nov 2010 18:18:11 -0500 (EST)
Received: from hpaq14.eem.corp.google.com (hpaq14.eem.corp.google.com [172.25.149.14])
	by smtp-out.google.com with ESMTP id oAHNI6QC001109
	for <linux-mm@kvack.org>; Wed, 17 Nov 2010 15:18:06 -0800
Received: from gyf2 (gyf2.prod.google.com [10.243.50.66])
	by hpaq14.eem.corp.google.com with ESMTP id oAHNHHeO006287
	for <linux-mm@kvack.org>; Wed, 17 Nov 2010 15:18:04 -0800
Received: by gyf2 with SMTP id 2so1841635gyf.7
        for <linux-mm@kvack.org>; Wed, 17 Nov 2010 15:18:04 -0800 (PST)
Date: Wed, 17 Nov 2010 15:17:58 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [7/8,v3] NUMA Hotplug Emulator: extend memory probe interface
 to support NUMA
In-Reply-To: <1290034830.9173.4363.camel@nimitz>
Message-ID: <alpine.DEB.2.00.1011171508570.24488@chino.kir.corp.google.com>
References: <20101117020759.016741414@intel.com> <20101117021000.916235444@intel.com> <1290019807.9173.3789.camel@nimitz> <alpine.DEB.2.00.1011171312590.10254@chino.kir.corp.google.com> <1290030945.9173.4211.camel@nimitz> <alpine.DEB.2.00.1011171434320.22190@chino.kir.corp.google.com>
 <1290034830.9173.4363.camel@nimitz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: shaohui.zheng@intel.com, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, haicheng.li@linux.intel.com, lethal@linux-sh.org, ak@linux.intel.com, shaohui.zheng@linux.intel.com, Haicheng Li <haicheng.li@intel.com>, Wu Fengguang <fengguang.wu@intel.com>, Greg KH <greg@kroah.com>, Aaron Durbin <adurbin@google.com>
List-ID: <linux-mm.kvack.org>

On Wed, 17 Nov 2010, Dave Hansen wrote:

> It's not just the mem_map[], though.  When a section is sitting
> "offline", it's pretty much all ready to go, except that its pages
> aren't in the allocators.  But, all of the other mm structures have
> already been modified to make room for the pages.  Zones have been added
> or modified, pgdats resized, 'struct page's initialized.
> 

Ok, so let's create an interface that compliments the probe interface that 
takes a quantity of memory to be hot-added from the amount of hidden RAM 
only after we fake the nodes_add array for each section within that 
quantity by calling update_nodes_add() and then looping through for each 
section calling add_memory().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
