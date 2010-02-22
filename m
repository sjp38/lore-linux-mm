Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id B3D8F6B0078
	for <linux-mm@kvack.org>; Mon, 22 Feb 2010 05:57:15 -0500 (EST)
Message-ID: <4B826307.8030805@cs.helsinki.fi>
Date: Mon, 22 Feb 2010 12:57:11 +0200
From: Pekka Enberg <penberg@cs.helsinki.fi>
MIME-Version: 1.0
Subject: Re: [PATCH] [4/4] SLAB: Fix node add timer race in cache_reap
References: <20100211953.850854588@firstfloor.org> <20100211205404.085FEB1978@basil.firstfloor.org> <20100215061535.GI5723@laptop> <20100215103250.GD21783@one.firstfloor.org> <alpine.DEB.2.00.1002191221110.26567@router.home>
In-Reply-To: <alpine.DEB.2.00.1002191221110.26567@router.home>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Andi Kleen <andi@firstfloor.org>, Nick Piggin <npiggin@suse.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, haicheng.li@intel.com, rientjes@google.com
List-ID: <linux-mm.kvack.org>

Christoph Lameter kirjoitti:
> On Mon, 15 Feb 2010, Andi Kleen wrote:
> 
>>> How, may I ask? cpuup_prepare in the hotplug notifier should always
>>> run before start_cpu_timer.
>> I'm not fully sure, but I have the oops to prove it :)
> 
> I still suspect that this has something to do with Pekka's changing the
> boot order for allocator bootstrap. Can we clarify why these problems
> exist before we try band aid?

I don't see how my changes broke things but maybe I'm not looking hard 
enough. Cache reaping is still setup from cpucache_init() which is an 
initcall which is not affected by my changes AFAICT and from 
cpuup_callback() which shoulda also not be affected.

				Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
