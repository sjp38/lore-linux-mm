Date: Wed, 26 Apr 2000 17:41:59 +0200
From: "Andi Kleen" <ak@suse.de>
Subject: Re: [PATCH] 2.3.99-pre6-3+  VM rebalancing
Message-ID: <20000426174159.A14599@gruyere.muc.suse.de>
References: <Pine.LNX.4.21.0004261041420.16202-100000@duckman.conectiva> <200004261433.HAA13894@pizda.ninka.net> <oupbt2wombt.fsf@pigdrop.muc.suse.de> <200004261528.IAA13982@pizda.ninka.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <200004261528.IAA13982@pizda.ninka.net>; from davem@redhat.com on Wed, Apr 26, 2000 at 08:28:21AM -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "David S. Miller" <davem@redhat.com>
Cc: ak@suse.de, riel@conectiva.com.br, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 26, 2000 at 08:28:21AM -0700, David S. Miller wrote:
>    From: Andi Kleen <ak@suse.de>
>    Date: 26 Apr 2000 18:31:50 +0200
> 
>    But is that still fair ? A memory hog could rapidly allocate and
>    dirty pages, killing the small innocent daemon which just needs to
>    get some work done.
> 
> If the daemon is actually doing anything, he'll reference his
> pages which will cause us to not liberate them.  If he's not doing
> anything, why should we keep his pages around?

What is if he isn't doing stuff quickly enough compared to the 
spending significant parts of the CPU just to dirty pages memory hog ? 
I imagine that the page scanning intervals  will be too slow, if 
you age more often you eat too much CPU [at least on Intel/SMP every pte
access is a locked transfer on the bus], if you do it too seldom
the memory hog can easily kill the system.

-Andi
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
