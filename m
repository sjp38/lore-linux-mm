Date: Thu, 30 Jan 2003 02:24:58 +0100
From: Andi Kleen <ak@muc.de>
Subject: Re: Linus rollup
Message-ID: <20030130012458.GA7284@averell>
References: <20030129022617.62800a6e.akpm@digeo.com> <1043879752.10150.387.camel@dell_ss3.pdx.osdl.net> <20030129151206.269290ff.akpm@digeo.com> <20030129.163034.130834202.davem@redhat.com> <20030129172743.1e11d566.akpm@digeo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20030129172743.1e11d566.akpm@digeo.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: "David S. Miller" <davem@redhat.com>, shemminger@osdl.org, rmk@arm.linux.org.uk, ak@muc.de, davidm@napali.hpl.hp.com, anton@samba.org, linux-mm@kvack.org, andrea@suse.de
List-ID: <linux-mm.kvack.org>

> This is an optimisation to the ia64, ia32 and x86_64 do_gettimeofday() code
> above and beyond the base frlock work.

Hmm? No x86_64 changes in there.

> arch/i386/kernel/time.c             |    7 +++----
> arch/i386/kernel/timers/timer_pit.c |    7 +++----
> arch/ia64/kernel/time.c             |    5 ++---
> include/linux/frlock.h              |    8 ++++++--
   

-Andi
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
