Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1AA4F6B0007
	for <linux-mm@kvack.org>; Thu,  5 Jul 2018 04:24:40 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id e193-v6so972119wmg.1
        for <linux-mm@kvack.org>; Thu, 05 Jul 2018 01:24:40 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l4-v6sor2714562wrm.21.2018.07.05.01.24.38
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 05 Jul 2018 01:24:38 -0700 (PDT)
Date: Thu, 5 Jul 2018 10:24:35 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH] x86/numa_emulation: Fix uniform size build failure
Message-ID: <20180705082435.GA29656@gmail.com>
References: <153065162801.12250.4860144566061573514.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <153065162801.12250.4860144566061573514.stgit@dwillia2-desk3.amr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: David Rientjes <rientjes@google.com>, Thomas Gleixner <tglx@linutronix.de>, Wei Yang <richard.weiyang@gmail.com>, kbuild test robot <lkp@intel.com>, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org


* Dan Williams <dan.j.williams@intel.com> wrote:

> The calculation of a uniform numa-node size attempted to perform
> division with a 64-bit diviser leading to the following failure on
> 32-bit:
> 
>     arch/x86/mm/numa_emulation.o: In function `split_nodes_size_interleave_uniform':
>     arch/x86/mm/numa_emulation.c:239: undefined reference to `__udivdi3'
> 
> Convert the implementation to do the division in terms of pages and then
> shift the result back to an absolute physical address.
> 
> Fixes: 93e738834fcc ("x86/numa_emulation: Introduce uniform split capability")
> Cc: David Rientjes <rientjes@google.com>
> Cc: Thomas Gleixner <tglx@linutronix.de>
> Cc: Wei Yang <richard.weiyang@gmail.com>
> Reported-by: kbuild test robot <lkp@intel.com>
> Signed-off-by: Dan Williams <dan.j.williams@intel.com>

I'm still getting this link failure on 32-bit kernels:

 arch/x86/mm/numa_emulation.o: In function `split_nodes_size_interleave_uniform.constprop.1':
 numa_emulation.c:(.init.text+0x669): undefined reference to `__udivdi3'
 Makefile:1005: recipe for target 'vmlinux' failed

config attached.

These numa_emulation changes are a bit of a trainwreck - I'm removing both 
num_emulation commits from -tip for now, could you please resubmit a fixed/tested 
combo version?

Thanks,

	Ingo
