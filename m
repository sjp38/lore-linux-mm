Message-ID: <3C5076C1.DDEE200B@zip.com.au>
Date: Thu, 24 Jan 2002 13:04:01 -0800
From: Andrew Morton <akpm@zip.com.au>
MIME-Version: 1.0
Subject: Re: kernel 2.4.17 with -rmap VM patch ROCKS!!!
References: <008301c1a4c1$a79f8fa0$3c00a8c0@baazee.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Anish Srivastava <anishs@vsnl.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrea Arcangeli <andrea@suse.de>, Rik van Riel <riel@conectiva.com.br>, alan@lxorguk.ukuu.org.uk
List-ID: <linux-mm.kvack.org>

Anish Srivastava wrote:
> 
> Hi!
> 
> I installed kernel 2.4.17 on my SMP server with 8CPU's and 8GB RAM
> and lets just say that whenever the entire physical memory was utilised
> the box would topple over...with kswapd running a havoc on CPU utilization
> So to avoid losing control I had to reboot every 8 hours.
> 

The fact that the current stable version of the Linux kernel
can only achieve an eight-hour uptime on this class of machine
is a fairly serious problem, don't we all agree?

We need a fix for 2.4.18.

Did you test the -aa patches?

-
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
