Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 78D566B01F4
	for <linux-mm@kvack.org>; Fri, 14 May 2010 03:00:32 -0400 (EDT)
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [202.81.31.247])
	by e23smtp08.au.ibm.com (8.14.3/8.13.1) with ESMTP id o4EGw1DH010531
	for <linux-mm@kvack.org>; Sat, 15 May 2010 02:58:01 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o4E6odHR1573084
	for <linux-mm@kvack.org>; Fri, 14 May 2010 16:50:39 +1000
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o4E6vm5x014291
	for <linux-mm@kvack.org>; Fri, 14 May 2010 16:57:48 +1000
Date: Fri, 14 May 2010 12:27:44 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [RFC, 0/7] NUMA Hotplug emulator
Message-ID: <20100514065744.GB3296@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20100513113629.GA2169@shaohui>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20100513113629.GA2169@shaohui>
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, ak@linux.intel.co, fengguang.wu@intel.com, haicheng.li@linux.intel.com, shaohui.zheng@linux.intel.com
List-ID: <linux-mm.kvack.org>

* Shaohui Zheng <shaohui.zheng@intel.com> [2010-05-13 19:36:30]:

> Hi, All
> 	This patchset introduces NUMA hotplug emulator for x86. it refers too
> many files and might introduce new bugs, so we send a RFC to comminity first
> and expect comments and suggestions, thanks.
> 
> * WHAT IS HOTPLUG EMULATOR 
> 
> NUMA hotplug emulator is collectively named for the hotplug emulation
> it is able to emulate NUMA Node Hotplug thru a pure software way. It
> intends to help people easily debug and test node/cpu/memory hotplug
> related stuff on a none-numa-hotplug-support machine, even an UMA machine.
> 
> The emulator provides mechanism to emulate the process of physcial cpu/mem
> hotadd, it provides possibility to debug CPU and memory hotplug on the machines
> without NUMA support for kenrel developers. It offers an interface for cpu
> and memory hotplug test purpose.
>

Sounds like an interesting project, could you please

Post your patches as threaded, ideally having 0/7 to 7/7 in a thread
helps track the patches and comments.

-- 
	Three Cheers,
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
