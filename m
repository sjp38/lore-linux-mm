Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 04E376B0047
	for <linux-mm@kvack.org>; Sat,  6 Mar 2010 00:46:09 -0500 (EST)
Message-ID: <4B91EBC6.6080509@kernel.org>
Date: Fri, 05 Mar 2010 21:44:38 -0800
From: Yinghai Lu <yinghai@kernel.org>
MIME-Version: 1.0
Subject: please don't apply : bootmem: avoid DMA32 zone by default
References: <49b004811003041321g2567bac8yb73235be32a27e7c@mail.gmail.com> 	<20100305032106.GA12065@cmpxchg.org> <49b004811003042117n720f356h7e10997a1a783475@mail.gmail.com> <4B915074.4020704@kernel.org> <4B916BD6.8010701@kernel.org>
In-Reply-To: <4B916BD6.8010701@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Greg Thelen <gthelen@google.com>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On 03/05/2010 12:38 PM, Yinghai Lu wrote:
> if you don't want to drop
> |  bootmem: avoid DMA32 zone by default
> 
> today mainline tree actually DO NOT need that patch according to print out ...
> 
> please apply this one too.
> 
> [PATCH] x86/bootmem: introduce bootmem_default_goal
> 
> don't punish the 64bit systems with less 4G RAM.
> they should use _pa(MAX_DMA_ADDRESS) at first pass instead of failback...

andrew,

please drop Johannes' patch : bootmem: avoid DMA32 zone by default

so you don't need to apply two fix patches from me:
[PATCH] early_res: double check with updated goal in alloc_memory_core_early
[PATCH] x86/bootmem: introduce bootmem_default_goal

move all bootmem to above 4g, make system performance get worse...

Thanks

Yinghai Lu

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
