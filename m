Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id CAA17554
	for <linux-mm@kvack.org>; Wed, 29 Jan 2003 02:25:55 -0800 (PST)
Date: Wed, 29 Jan 2003 02:26:17 -0800
From: Andrew Morton <akpm@digeo.com>
Subject: Re: Linus rollup
Message-Id: <20030129022617.62800a6e.akpm@digeo.com>
In-Reply-To: <20030129.015134.19663914.davem@redhat.com>
References: <20030128220729.1f61edfe.akpm@digeo.com>
	<20030129095949.A24161@flint.arm.linux.org.uk>
	<20030129.015134.19663914.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "David S. Miller" <davem@redhat.com>
Cc: rmk@arm.linux.org.uk, ak@muc.de, davidm@napali.hpl.hp.com, anton@samba.org, linux-mm@kvack.org, Andrea Arcangeli <andrea@suse.de>
List-ID: <linux-mm.kvack.org>

"David S. Miller" <davem@redhat.com> wrote:
>
>    From: Russell King <rmk@arm.linux.org.uk>
>    Date: Wed, 29 Jan 2003 09:59:49 +0000
>    
>    	/* This function must be called with interrupts disabled
>    
>    which hasn't been true for some time, and is even less true now that
>    local IRQs don't get disabled.  Does this matter... for UP?
> 
> I disable local IRQs during gettimeofday() on sparc.
> 
> These locks definitely need to be taken with IRQs disabled.
> Why isn't x86 doing that?

Darned if I know.  Looks like Andrea's kernel will deadlock if
arch/i386/kernel/time.c:timer_interrupt() takes i8253_lock
while that cpu is holding the same lock in do_slow_gettimeoffset().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
