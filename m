Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id C4F6B900086
	for <linux-mm@kvack.org>; Wed, 13 Apr 2011 14:57:56 -0400 (EDT)
Received: from wpaz29.hot.corp.google.com (wpaz29.hot.corp.google.com [172.24.198.93])
	by smtp-out.google.com with ESMTP id p3DIvqNv002403
	for <linux-mm@kvack.org>; Wed, 13 Apr 2011 11:57:53 -0700
Received: from pzk2 (pzk2.prod.google.com [10.243.19.130])
	by wpaz29.hot.corp.google.com with ESMTP id p3DIvokn016149
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 13 Apr 2011 11:57:51 -0700
Received: by pzk2 with SMTP id 2so707236pzk.9
        for <linux-mm@kvack.org>; Wed, 13 Apr 2011 11:57:50 -0700 (PDT)
Date: Wed, 13 Apr 2011 11:57:48 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [0/7,v10] NUMA Hotplug Emulator (v10)
In-Reply-To: <749B9D3DBF0F054390025D9EAFF47F224A3D6C35@shsmsx501.ccr.corp.intel.com>
Message-ID: <alpine.DEB.2.00.1104131151280.5563@chino.kir.corp.google.com>
References: <749B9D3DBF0F054390025D9EAFF47F224A3D6C35@shsmsx501.ccr.corp.intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Zhang, Yang Z" <yang.z.zhang@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Haicheng Li <haicheng.li@linux.intel.com>, lethal@linux-sh.org, Andi Kleen <andi.kleen@intel.com>, dave@linux.vnet.ibm.com, Greg KH <gregkh@suse.de>, Ingo Molnar <mingo@elte.hu>, Len Brown <lenb@kernel.org>, linux-kernel@vger.kernel.org, Yinghai Lu <yinghai@kernel.org>, Xin Li <xin.li@intel.com>

On Thu, 31 Mar 2011, Zhang, Yang Z wrote:

> * PATCHSET INTRODUCTION
> 
> patch 1: Documentation.
> patch 2: Adds a numa=possible=<N> command line option to set an additional N nodes
>                  as being possible for memory hotplug.
> 
> patch 3: Add node hotplug emulation, introduce debugfs node/add_node interface
> 
> patch 4: Abstract cpu register functions, make these interface friend for cpu
>                  hotplug emulation
> patch 5: Support cpu probe/release in x86, it provide a software method to hot
>                  add/remove cpu with sysfs interface.
> patch 6: Fake CPU socket with logical CPU on x86, to prevent the scheduling
>                  domain to build the incorrect hierarchy.
> patch 7: Implement per-node add_memory debugfs interface
> 

I think it would probably be better to separate these into the x86 support 
(patch 2, part of 3, 4, 5, and patch 7) and the generic memory hotplug, 
cpu, and documentation (patch 1, most of 3, wiring up in 4 and 5, patch 
7).  In each changelog you can talk about the entire scope of the feature 
and what each patch is leading to, but this separation will help to get it 
merged first by the x86 maintainers and then the generic bits through the 
-mm tree.

Thanks for following up on this!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
