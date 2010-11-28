Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 563F18D0001
	for <linux-mm@kvack.org>; Sat, 27 Nov 2010 21:04:08 -0500 (EST)
Received: from hpaq12.eem.corp.google.com (hpaq12.eem.corp.google.com [172.25.149.12])
	by smtp-out.google.com with ESMTP id oAS246LA004157
	for <linux-mm@kvack.org>; Sat, 27 Nov 2010 18:04:06 -0800
Received: from pxi17 (pxi17.prod.google.com [10.243.27.17])
	by hpaq12.eem.corp.google.com with ESMTP id oAS243QJ008100
	for <linux-mm@kvack.org>; Sat, 27 Nov 2010 18:04:04 -0800
Received: by pxi17 with SMTP id 17so617929pxi.34
        for <linux-mm@kvack.org>; Sat, 27 Nov 2010 18:04:03 -0800 (PST)
Date: Sat, 27 Nov 2010 18:03:58 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch 1/2] x86: add numa=possible command line option
In-Reply-To: <20101122022411.GC9081@shaohui>
Message-ID: <alpine.DEB.2.00.1011271802210.3764@chino.kir.corp.google.com>
References: <A24AE1FFE7AEC5489F83450EE98351BF28723FC48C@shsmsx502.ccr.corp.intel.com> <20101122022411.GC9081@shaohui>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Shaohui Zheng <shaohui.zheng@intel.com>
Cc: akpm@linux-foundation.org, gregkh@suse.de, mingo@redhat.com, hpa@zytor.com, tglx@linutronix.de, lethal@linux-sh.org, ak@linux.intel.com, yinghai@kernel.org, randy.dunlap@oracle.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, haicheng.li@intel.com, haicheng.li@linux.intel.com
List-ID: <linux-mm.kvack.org>

On Mon, 22 Nov 2010, Shaohui Zheng wrote:

> It is the improved solution from thread http://lkml.org/lkml/2010/11/18/3,
> our draft patch set all the nodes as possbile node, it wastes a lot of memory,
> the command line numa=possible=<N> seems to be an acceptable, and it is a optimization
> for our patch.
> 

node_possible_map is a generic nodemask used throughout the kernel, but 
its handling is highly dependent on the arch.  This patch enables the 
support for x86, I'd encourage anyone else interested in other archs to 
look into adding the support for it as well (perhaps you can do it for 
powerpc?).

> I like your active work attitude for the patch reviewing, it is real helpful to 
> improve the patch quality.
> 

Thanks, I'm happy to be involved!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
