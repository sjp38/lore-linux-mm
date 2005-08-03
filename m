Date: Wed, 3 Aug 2005 10:56:00 -0400
From: Martin Hicks <mort@sgi.com>
Subject: Re: [PATCH] VM: add vm.free_node_memory sysctl
Message-ID: <20050803145600.GS26803@localhost>
References: <20050801113913.GA7000@elte.hu> <20050801102903.378da54f.akpm@osdl.org> <20050801195426.GA17548@elte.hu> <20050802171050.GG26803@localhost> <20050802210746.GA26494@elte.hu> <20050803135646.GO26803@localhost> <20050803141529.GX10895@wotan.suse.de> <20050803142440.GQ26803@localhost> <20050803143855.GA10895@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20050803143855.GA10895@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: Ingo Molnar <mingo@elte.hu>, Linux MM <linux-mm@kvack.org>, Andrew Morton <akpm@osdl.org>, torvalds@osdl.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, Aug 03, 2005 at 04:38:55PM +0200, Andi Kleen wrote:
> On Wed, Aug 03, 2005 at 10:24:40AM -0400, Martin Hicks wrote:
> 
> > zone_reclaim() path doesn't let the memory reclaim code swap.
> 
> reclaim with bound policy should only swap on the bound nodemask
> (or at least it did when I originally implemented NUMA policy) 

Yes, it still looks like it only swaps on the bound nodemask.

mh

-- 
Martin Hicks   ||   Silicon Graphics Inc.   ||   mort@sgi.com
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
