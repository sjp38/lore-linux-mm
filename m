Date: Tue, 15 Aug 2006 19:17:55 +0000
From: Pavel Machek <pavel@suse.cz>
Subject: Re: [RFC][PATCH 0/9] Network receive deadlock prevention for NBD
Message-ID: <20060815191754.GH4032@ucw.cz>
References: <20060808193325.1396.58813.sendpatchset@lappy>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20060808193325.1396.58813.sendpatchset@lappy>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org, Daniel Phillips <phillips@google.com>
List-ID: <linux-mm.kvack.org>

Hi!

> Recently, Peter Zijlstra and I have been busily collaborating on a
> solution to the memory deadlock problem described here:
> 
>    http://lwn.net/Articles/144273/
>    "Kernel Summit 2005: Convergence of network and storage paths"
> 
> We believe that an approach very much like today's patch set is
> necessary for NBD, iSCSI, AoE or the like ever to work reliably. 
> We further believe that a properly working version of at least one of
> these subsystems is critical to the viability of Linux as a modern
> storage platform.
...
> Unfortunately, a particularly nasty form of memory deadlock arises from
> the fact that receive side of the network stack is also a sort of

What about transmit side? I believe you need to reply to ARPs or you
will be unable to communicate over ethernet...
-- 
Thanks for all the (sleeping) penguins.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
