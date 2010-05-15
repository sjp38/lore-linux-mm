Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 2AA1A6B01E3
	for <linux-mm@kvack.org>; Sat, 15 May 2010 08:04:20 -0400 (EDT)
Date: Sat, 15 May 2010 19:59:50 +0800
From: Shaohui Zheng <shaohui.zheng@intel.com>
Subject: Re: [RFC, 0/7] NUMA Hotplug emulator
Message-ID: <20100515115950.GA23083@shaohui>
References: <20100513113629.GA2169@shaohui>
 <20100514065744.GB3296@balbir.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100514065744.GB3296@balbir.in.ibm.com>
Sender: owner-linux-mm@kvack.org
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, ak@linux.intel.co, fengguang.wu@intel.com, haicheng.li@linux.intel.com, shaohui.zheng@linux.intel.com
List-ID: <linux-mm.kvack.org>

On Fri, May 14, 2010 at 12:27:44PM +0530, Balbir Singh wrote:
> * Shaohui Zheng <shaohui.zheng@intel.com> [2010-05-13 19:36:30]:
> 
> > Hi, All
> > 	This patchset introduces NUMA hotplug emulator for x86. it refers too
> > many files and might introduce new bugs, so we send a RFC to comminity first
> > and expect comments and suggestions, thanks.
> > 
> > * WHAT IS HOTPLUG EMULATOR 
> > 
> > NUMA hotplug emulator is collectively named for the hotplug emulation
> > it is able to emulate NUMA Node Hotplug thru a pure software way. It
> > intends to help people easily debug and test node/cpu/memory hotplug
> > related stuff on a none-numa-hotplug-support machine, even an UMA machine.
> > 
> > The emulator provides mechanism to emulate the process of physcial cpu/mem
> > hotadd, it provides possibility to debug CPU and memory hotplug on the machines
> > without NUMA support for kenrel developers. It offers an interface for cpu
> > and memory hotplug test purpose.
> >
> 
> Sounds like an interesting project, could you please
> 
> Post your patches as threaded, ideally having 0/7 to 7/7 in a thread
> helps track the patches and comments.
> 
> -- 
> 	Three Cheers,
> 	Balbir

Sorry for the late response, I have no experience to post all the patches into one 
thread, I will consult local expert.

Thanks Balbir, because of your guys's feedbacks and review comments, the code quality
should be guaranteed. 

-- 
Thanks & Regards,
Shaohui

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
