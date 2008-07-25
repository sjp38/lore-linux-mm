Date: Fri, 25 Jul 2008 18:29:04 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 11/30] mm: __GFP_MEMALLOC
In-Reply-To: <20080724141530.060638861@chello.nl>
References: <20080724140042.408642539@chello.nl> <20080724141530.060638861@chello.nl>
Message-Id: <20080725180305.86A9.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: kosaki.motohiro@jp.fujitsu.com, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, trond.myklebust@fys.uio.no, Daniel Lezcano <dlezcano@fr.ibm.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Neil Brown <neilb@suse.de>
List-ID: <linux-mm.kvack.org>

Hi Peter,

> __GFP_MEMALLOC will allow the allocation to disregard the watermarks, 
> much like PF_MEMALLOC.
> 
> It allows one to pass along the memalloc state in object related allocation
> flags as opposed to task related flags, such as sk->sk_allocation.

Is this properly name?
page alloc is always "mem alloc".

you wrote comment as "Use emergency reserves" and 
this flag works to turn on ALLOC_NO_WATERMARKS.

then, __GFP_NO_WATERMARK or __GFP_EMERGENCY are better?




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
