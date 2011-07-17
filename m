Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id E969C6B007E
	for <linux-mm@kvack.org>; Sun, 17 Jul 2011 17:34:34 -0400 (EDT)
Date: Sun, 17 Jul 2011 23:34:21 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: possible recursive locking detected cache_alloc_refill() +
 cache_flusharray()
In-Reply-To: <20110716211850.GA23917@breakpoint.cc>
Message-ID: <alpine.LFD.2.02.1107172333340.2702@ionos>
References: <20110716211850.GA23917@breakpoint.cc>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sebastian Siewior <sebastian@breakpoint.cc>
Cc: Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org, Peter Zijlstra <peterz@infradead.org>

On Sat, 16 Jul 2011, Sebastian Siewior wrote:

> Hi,
> 
> just hit the following with full debuging turned on:
> 
> | =============================================
> | [ INFO: possible recursive locking detected ]
> | 3.0.0-rc7-00088-g1765a36 #64
> | ---------------------------------------------
> | udevd/1054 is trying to acquire lock:
> |  (&(&parent->list_lock)->rlock){..-...}, at: [<c00bf640>] cache_alloc_refill+0xac/0x868
> |
> | but task is already holding lock:
> |  (&(&parent->list_lock)->rlock){..-...}, at: [<c00be47c>] cache_flusharray+0x58/0x148
> |
> | other info that might help us debug this:
> |  Possible unsafe locking scenario:
> |
> |        CPU0
> |        ----
> |   lock(&(&parent->list_lock)->rlock);
> |   lock(&(&parent->list_lock)->rlock);

Known problem. Pekka is looking into it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
