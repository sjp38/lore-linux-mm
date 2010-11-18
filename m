Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id BB6006B0089
	for <linux-mm@kvack.org>; Thu, 18 Nov 2010 01:49:00 -0500 (EST)
Date: Thu, 18 Nov 2010 13:27:50 +0800
From: Shaohui Zheng <shaohui.zheng@intel.com>
Subject: Re: [2/8,v3] NUMA Hotplug Emulator: infrastructure of NUMA hotplug
 emulation
Message-ID: <20101118052750.GD2408@shaohui>
References: <20101117020759.016741414@intel.com>
 <20101117021000.568681101@intel.com>
 <alpine.DEB.2.00.1011162359160.17408@chino.kir.corp.google.com>
 <20101117075128.GA30254@shaohui>
 <alpine.DEB.2.00.1011171304060.10254@chino.kir.corp.google.com>
 <20101118041407.GA2408@shaohui>
 <20101118062715.GD17539@linux-sh.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101118062715.GD17539@linux-sh.org>
Sender: owner-linux-mm@kvack.org
To: Paul Mundt <lethal@linux-sh.org>
Cc: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, haicheng.li@linux.intel.com, ak@linux.intel.com, shaohui.zheng@linux.intel.com, Yinghai Lu <yinghai@kernel.org>, Haicheng Li <haicheng.li@intel.com>
List-ID: <linux-mm.kvack.org>

On Thu, Nov 18, 2010 at 03:27:15PM +0900, Paul Mundt wrote:
> On Thu, Nov 18, 2010 at 12:14:07PM +0800, Shaohui Zheng wrote:
> > On Wed, Nov 17, 2010 at 01:10:50PM -0800, David Rientjes wrote:
> > > The idea that I've proposed (and you've apparently thought about and even 
> > > implemented at one point) is much more powerful than that.  We need not 
> > > query the state of hidden nodes that we've setup at boot but can rather 
> > > use the amount of hidden memory to setup the nodes in any way that we want 
> > > at runtime (various sizes, interleaved node ids, etc).
> > 
> > yes, if we select your proposal. we just mark all the nodes as POSSIBLE node.
> > there is no hidden nodes any more. the node will be created after add memory
> > to the node first time. 
> > 
> This is roughly what I had in mind in my N_HIDDEN review, so I quite
> favour this approach.

Our testing shows that it is a feasible approach, and it works well.
however, there is still a problem which we should worry about.

in our draft patch, we re-setup nr_node_ids when CONFIG_ARCH_MEMORY_PROBE enabled 
and mem=XXX was specified in grub. we set nr_node_ids as MAX_NUMNODES + 1, because
 we do not know how many nodes will be hot-added through memory/probe interface. 
 it might be a little wasting of memory.

-- 
Thanks & Regards,
Shaohui

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
