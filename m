Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id QAA27141
	for <linux-mm@kvack.org>; Mon, 21 Oct 2002 16:21:12 -0700 (PDT)
Message-ID: <3DB48BE7.A044FDE0@digeo.com>
Date: Mon, 21 Oct 2002 16:21:11 -0700
From: Andrew Morton <akpm@digeo.com>
MIME-Version: 1.0
Subject: Re: 2.5.44-mm2 compile error using gcc 3.2 (gcc 2.96 works fine).
References: <3DB46C01.633299F9@digeo.com> <1035241430.9472.24.camel@localhost.localdomain>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Steven Cole <elenstev@mesatop.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Steven Cole wrote:
> 
> ..
> binutils version is 2.12.90.0.15 for Mandrake 9.0.

Thanks.
 
> BTW, I did a make mrproper on the gcc 3.2 box, retrieved the .config,
> recompiled, and got the very same "section type conflict" error as
> before.
> 
> After running the gcc 2.96 2.5.44-mm2 for a while longer, I started up
> dbench and ran some an increasing client load up to 24 clients.  I
> started a new Konsole in KDE and the system hung, not even responding to
> pings. That failure was repeatable once, but after those two hangs which
> required a hard reset, the system was able to run dbench 32 and launch
> new Konsoles without hanging.  Non-deterministic behavior is so much
> fun.

You're on SMP, yes?  Please test with Hugh's "[PATCH] mm mremap freeze"
patch applied.

But it should have responded to pings even if deadlocked there.

Are you using "nmi_watchdog=1"?
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
