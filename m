Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 0DE5D6B0087
	for <linux-mm@kvack.org>; Fri, 10 Dec 2010 18:30:49 -0500 (EST)
Received: from kpbe11.cbf.corp.google.com (kpbe11.cbf.corp.google.com [172.25.105.75])
	by smtp-out.google.com with ESMTP id oBANUjN2025896
	for <linux-mm@kvack.org>; Fri, 10 Dec 2010 15:30:46 -0800
Received: from pvg12 (pvg12.prod.google.com [10.241.210.140])
	by kpbe11.cbf.corp.google.com with ESMTP id oBANUhmk025836
	for <linux-mm@kvack.org>; Fri, 10 Dec 2010 15:30:44 -0800
Received: by pvg12 with SMTP id 12so1138151pvg.26
        for <linux-mm@kvack.org>; Fri, 10 Dec 2010 15:30:43 -0800 (PST)
Date: Fri, 10 Dec 2010 15:30:38 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [7/7,v8] NUMA Hotplug Emulator: Implement per-node add_memory
 debugfs interface
In-Reply-To: <20101209235705.GA10674@shaohui>
Message-ID: <alpine.DEB.2.00.1012101529190.30039@chino.kir.corp.google.com>
References: <A24AE1FFE7AEC5489F83450EE98351BF2A40FED20A@shsmsx502.ccr.corp.intel.com> <20101209012124.GD5798@shaohui> <alpine.DEB.2.00.1012091325530.13564@chino.kir.corp.google.com> <20101209235705.GA10674@shaohui>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Shaohui Zheng <shaohui.zheng@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, haicheng.li@linux.intel.com, lethal@linux-sh.org, Andi Kleen <ak@linux.intel.com>, Greg Kroah-Hartman <gregkh@suse.de>
List-ID: <linux-mm.kvack.org>

On Fri, 10 Dec 2010, Shaohui Zheng wrote:

> > That doesn't address the question.  My question is whether or not adding 
> > memory to a memoryless node in this way transitions its state to 
> > N_HIGH_MEMORY in the VM?
> I guess that you are talking about memory hotplug on x86_32, memory hotplug is
> NOT supported well for x86_32, and the function add_memory does not consider
> this situlation.
> 
> For 64bit, N_HIGH_MEMORY == N_NORMAL_MEMORY, so we need not to do the transition.
> 

One more time :)  Memoryless nodes do not have their bit set in 
N_HIGH_MEMORY.  When memory is added to a memoryless node with this new 
interface, does the bit get set?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
