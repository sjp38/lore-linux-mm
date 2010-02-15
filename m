Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id AB2D56B009D
	for <linux-mm@kvack.org>; Mon, 15 Feb 2010 10:30:44 -0500 (EST)
Subject: Re: [PATCH] [4/4] SLAB: Fix node add timer race in cache_reap
From: Andi Kleen <andi@firstfloor.org>
References: <20100211953.850854588@firstfloor.org>
	<20100211205404.085FEB1978@basil.firstfloor.org>
	<20100215061535.GI5723@laptop>
	<20100215103250.GD21783@one.firstfloor.org>
	<20100215104135.GM5723@laptop>
	<20100215105253.GE21783@one.firstfloor.org>
	<20100215110135.GN5723@laptop>
Date: Mon, 15 Feb 2010 16:30:38 +0100
In-Reply-To: <20100215110135.GN5723@laptop> (Nick Piggin's message of "Mon, 15 Feb 2010 22:01:36 +1100")
Message-ID: <87bpfqms81.fsf@basil.nowhere.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: penberg@cs.helsinki.fi, linux-kernel@vger.kernel.org, linux-mm@kvack.org, haicheng.li@intel.com, rientjes@google.com
List-ID: <linux-mm.kvack.org>

Nick Piggin <npiggin@suse.de> writes:
>
> Hmm, but it should, because if cpuup_prepare fails  then the
> CPU_ONLINE notifiers should never be called I think.

That's true.
  
-Andi
-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
