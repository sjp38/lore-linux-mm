Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id A40AF6B0087
	for <linux-mm@kvack.org>; Thu, 23 Dec 2010 00:32:34 -0500 (EST)
Date: Wed, 22 Dec 2010 21:28:04 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [5/7, v9] NUMA Hotplug Emulator: Support cpu probe/release in
 x86_64
Message-Id: <20101222212804.a164f488.akpm@linux-foundation.org>
In-Reply-To: <20101223022428.GB12333@shaohui>
References: <20101210073119.156388875@intel.com>
	<20101210073242.670777298@intel.com>
	<20101222162727.56b830b0.akpm@linux-foundation.org>
	<20101223013410.GA11356@shaohui>
	<20101222192118.2d286ca9.akpm@linux-foundation.org>
	<20101223022428.GB12333@shaohui>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Shaohui Zheng <shaohui.zheng@linux.intel.com>
Cc: shaohui.zheng@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, haicheng.li@linux.intel.com, lethal@linux-sh.org, ak@linux.intel.com, rientjes@google.com, dave@linux.vnet.ibm.com, gregkh@suse.de, Ingo Molnar <mingo@elte.hu>, Len Brown <len.brown@intel.com>, Yinghai Lu <Yinghai.Lu@Sun.COM>, Tejun Heo <tj@kernel.org>, Haicheng Li <haicheng.li@intel.com>
List-ID: <linux-mm.kvack.org>

On Thu, 23 Dec 2010 10:24:28 +0800 Shaohui Zheng <shaohui.zheng@linux.intel.com> wrote:

> > 
> > Why *does* it check `count' and then not use it?
> > 
> 
> it is a tricky thing. When I debug it under a Virtual Machine, If I do a cpu
> probe via sysfs cpu/probe interface, The function arch_cpu_probe will be called
> __three__ times, but only one call is valid, so I add a check on `count` to
> ignore the invalid calls.

hm, why does it get called three times?  Is that something which
can/should be fixed in callers rather than in the callee?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
