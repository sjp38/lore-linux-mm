Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 320326B0095
	for <linux-mm@kvack.org>; Fri, 19 Feb 2010 13:22:34 -0500 (EST)
Date: Fri, 19 Feb 2010 12:22:09 -0600 (CST)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH] [4/4] SLAB: Fix node add timer race in cache_reap
In-Reply-To: <20100215103250.GD21783@one.firstfloor.org>
Message-ID: <alpine.DEB.2.00.1002191221110.26567@router.home>
References: <20100211953.850854588@firstfloor.org> <20100211205404.085FEB1978@basil.firstfloor.org> <20100215061535.GI5723@laptop> <20100215103250.GD21783@one.firstfloor.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: Nick Piggin <npiggin@suse.de>, penberg@cs.helsinki.fi, linux-kernel@vger.kernel.org, linux-mm@kvack.org, haicheng.li@intel.com, rientjes@google.com
List-ID: <linux-mm.kvack.org>

On Mon, 15 Feb 2010, Andi Kleen wrote:

> > How, may I ask? cpuup_prepare in the hotplug notifier should always
> > run before start_cpu_timer.
>
> I'm not fully sure, but I have the oops to prove it :)

I still suspect that this has something to do with Pekka's changing the
boot order for allocator bootstrap. Can we clarify why these problems
exist before we try band aid?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
