Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id RAA18866
	for <linux-mm@kvack.org>; Wed, 29 Jan 2003 17:44:55 -0800 (PST)
Date: Wed, 29 Jan 2003 18:01:50 -0800
From: Andrew Morton <akpm@digeo.com>
Subject: Re: Linus rollup
Message-Id: <20030129180150.790295b9.akpm@digeo.com>
In-Reply-To: <20030130012458.GA7284@averell>
References: <20030129022617.62800a6e.akpm@digeo.com>
	<1043879752.10150.387.camel@dell_ss3.pdx.osdl.net>
	<20030129151206.269290ff.akpm@digeo.com>
	<20030129.163034.130834202.davem@redhat.com>
	<20030129172743.1e11d566.akpm@digeo.com>
	<20030130012458.GA7284@averell>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@muc.de>
Cc: davem@redhat.com, shemminger@osdl.org, rmk@arm.linux.org.uk, davidm@napali.hpl.hp.com, anton@samba.org, linux-mm@kvack.org, andrea@suse.de
List-ID: <linux-mm.kvack.org>

Andi Kleen <ak@muc.de> wrote:
>
> > This is an optimisation to the ia64, ia32 and x86_64 do_gettimeofday() code
> > above and beyond the base frlock work.
> 
> Hmm? No x86_64 changes in there.
> 
> > arch/i386/kernel/time.c             |    7 +++----
> > arch/i386/kernel/timers/timer_pit.c |    7 +++----
> > arch/ia64/kernel/time.c             |    5 ++---
> > include/linux/frlock.h              |    8 ++++++--
>    

True.  Hmm.  Maybe Stephen made some x86_64 changes, but didn't send them?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
