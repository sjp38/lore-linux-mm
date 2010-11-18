Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id E8A596B004A
	for <linux-mm@kvack.org>; Thu, 18 Nov 2010 16:19:34 -0500 (EST)
Received: from wpaz37.hot.corp.google.com (wpaz37.hot.corp.google.com [172.24.198.101])
	by smtp-out.google.com with ESMTP id oAILJWfT009665
	for <linux-mm@kvack.org>; Thu, 18 Nov 2010 13:19:32 -0800
Received: from yxm34 (yxm34.prod.google.com [10.190.4.34])
	by wpaz37.hot.corp.google.com with ESMTP id oAILJVk4032183
	for <linux-mm@kvack.org>; Thu, 18 Nov 2010 13:19:31 -0800
Received: by yxm34 with SMTP id 34so2571879yxm.2
        for <linux-mm@kvack.org>; Thu, 18 Nov 2010 13:19:30 -0800 (PST)
Date: Thu, 18 Nov 2010 13:19:27 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [2/8,v3] NUMA Hotplug Emulator: infrastructure of NUMA hotplug
 emulation
In-Reply-To: <20101118041407.GA2408@shaohui>
Message-ID: <alpine.DEB.2.00.1011181316290.26680@chino.kir.corp.google.com>
References: <20101117020759.016741414@intel.com> <20101117021000.568681101@intel.com> <alpine.DEB.2.00.1011162359160.17408@chino.kir.corp.google.com> <20101117075128.GA30254@shaohui> <alpine.DEB.2.00.1011171304060.10254@chino.kir.corp.google.com>
 <20101118041407.GA2408@shaohui>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Shaohui Zheng <shaohui.zheng@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, haicheng.li@linux.intel.com, lethal@linux-sh.org, ak@linux.intel.com, shaohui.zheng@linux.intel.com, Yinghai Lu <yinghai@kernel.org>, Haicheng Li <haicheng.li@intel.com>
List-ID: <linux-mm.kvack.org>

On Thu, 18 Nov 2010, Shaohui Zheng wrote:

> On Wed, Nov 17, 2010 at 01:10:50PM -0800, David Rientjes wrote:
> > I don't understand why that's a requirement, NUMA emulation is a seperate 
> > feature.  Although both are primarily used to test and instrument other VM 
> > and kernel code, NUMA emulation is restricted to only being used at boot 
> > to fake nodes on smaller machines and can be used to test things like the 
> > slab allocator.  The NUMA hotplug emulator that you're developing here is 
> > primarily used to test the hotplug callbacks; for that use-case, it seems 
> > particularly helpful if nodes can be hotplugged of various sizes and node 
> > ids rather than having static characteristics that cannot be changed with 
> > a reboot.
> > 
> I agree with you. the early emulator do the same thing as you said, but there 
> is already NUMA emulation to create fake node, our emulator also creates 
> fake nodes. We worried about that we will suffer the critiques from the community,
> so we drop the original degsin.
> 
> I did not know whether other engineers have the same attitude with you. I think 
> that I can publish both codes, and let the community to decide which one is prefered.
> 
> In my personal opinion, both methods are acceptable for me.
> 

The way that I've proposed it in my email to Dave was different: we use 
the memory hotplug interface to add and online the memory only after an 
interface has been added that will change the node mappings to 
first_unset_node(node_online_map).  The memory hotplug interface may 
create a new pgdat, so this is the node creation mechanism that should be 
used as opposed to those in NUMA emulation.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
