Date: Tue, 1 Oct 2002 15:50:46 -0700
From: "Kingsley G. Morse Jr." <change@nas.com>
Subject: Faster TCP wakeups
Message-ID: <20021001155046.A23683@debian1.loaner.com>
Reply-To: "Kingsley G. Morse Jr." <change@nas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@zip.com.au
Cc: andrea@suse.de, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hail Andrew,

I don't think we've met, but my name is Kingsley
G. Morse Jr. and first of all, I'd like to thank
you for improving the Linux kernel. I'm
benchmarking it.

I noticed in Kernel Traffic #186 that you've
converted TCP/IPV4 over to use faster wakeups.

This intrigues me, because I suspect TCP code is
degrading my computer's performance over time, and
perhaps other peoples' too.

My benchmarking found that after being up for 10
days, my computer's slowness is MOST correlated to
how often slab pages are allocated for TCP open
requests. (see "cat /proc/slabinfo")

In other words, the more often slab pages are
allocated for tcp open requests, the slower my
computer gets. 

The correlation coefficient is 0.62, which is on a
scale of -1 to 1. 

I believe it's noteworthy that 0.62 is higher than
any of the hundreds of other memory measures that
I've statistically analyzed.

It's also higher after 10 days of uptime.  Just
after booting, it's only 0.11. 

I suspect a TCP bug is causing fragmentation or
some other problem that gets worse over time.

Cheers,
Kingsley

PS: My computer has 

    64 MB or RAM
    1 GB of swap
    200 MHZ Pentium Pro
    2.4.19-aa

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
