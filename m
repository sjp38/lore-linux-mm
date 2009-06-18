Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 77B806B004F
	for <linux-mm@kvack.org>; Thu, 18 Jun 2009 02:46:37 -0400 (EDT)
Message-ID: <4A39E377.9060207@kernel.org>
Date: Thu, 18 Jun 2009 15:49:27 +0900
From: Tejun Heo <tj@kernel.org>
MIME-Version: 1.0
Subject: Re: [this_cpu_xx V2 13/19] Use this_cpu operations in slub
References: <20090617203337.399182817@gentwo.org>	 <20090617203445.302169275@gentwo.org> <84144f020906172320k39ea5132h823449abc3124b30@mail.gmail.com>
In-Reply-To: <84144f020906172320k39ea5132h823449abc3124b30@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: cl@linux-foundation.org, akpm@linux-foundation.org, linux-mm@kvack.org, mingo@elte.hu, rusty@rustcorp.com.au, davem@davemloft.net
List-ID: <linux-mm.kvack.org>

Hello,

Pekka Enberg wrote:
> So I don't think the above hunk is a good solution to this at all. We
> certainly can remove the lazy DMA slab creation (why did we add it in
> the first place?) but how hard is it to fix the per-cpu allocator to
> work in atomic contexts?

Should be possible but I wanna avoid that as long as possible.  Atomic
allocations suck anyway...  :-(

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
