Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id B23746B004A
	for <linux-mm@kvack.org>; Wed, 20 Jul 2011 09:22:11 -0400 (EDT)
Received: by ewy9 with SMTP id 9so746447ewy.14
        for <linux-mm@kvack.org>; Wed, 20 Jul 2011 06:22:08 -0700 (PDT)
Date: Wed, 20 Jul 2011 16:21:56 +0300 (EEST)
From: Pekka Enberg <penberg@kernel.org>
Subject: Re: possible recursive locking detected cache_alloc_refill() +
 cache_flusharray()
In-Reply-To: <alpine.LFD.2.02.1107172333340.2702@ionos>
Message-ID: <alpine.DEB.2.00.1107201619540.3528@tiger>
References: <20110716211850.GA23917@breakpoint.cc> <alpine.LFD.2.02.1107172333340.2702@ionos>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: Sebastian Siewior <sebastian@breakpoint.cc>, Christoph Lameter <cl@linux-foundation.org>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org, Peter Zijlstra <peterz@infradead.org>

On Sat, 16 Jul 2011, Sebastian Siewior wrote:
>> just hit the following with full debuging turned on:
>>
>> | =============================================
>> | [ INFO: possible recursive locking detected ]
>> | 3.0.0-rc7-00088-g1765a36 #64
>> | ---------------------------------------------
>> | udevd/1054 is trying to acquire lock:
>> |  (&(&parent->list_lock)->rlock){..-...}, at: [<c00bf640>] cache_alloc_refill+0xac/0x868
>> |
>> | but task is already holding lock:
>> |  (&(&parent->list_lock)->rlock){..-...}, at: [<c00be47c>] cache_flusharray+0x58/0x148
>> |
>> | other info that might help us debug this:
>> |  Possible unsafe locking scenario:
>> |
>> |        CPU0
>> |        ----
>> |   lock(&(&parent->list_lock)->rlock);
>> |   lock(&(&parent->list_lock)->rlock);

On Sun, 17 Jul 2011, Thomas Gleixner wrote:
> Known problem. Pekka is looking into it.

Actually, I kinda was hoping Peter would make it go away. ;-)

Looking at the lockdep report, it's l3->list_lock and I really don't quite 
understand why it started to happen now. There hasn't been any major 
changes in mm/slab.c for a while. Did lockdep become more strict recently?

 			Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
