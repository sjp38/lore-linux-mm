Message-ID: <008301c1a4c1$a79f8fa0$3c00a8c0@baazee.com>
Reply-To: "Anish Srivastava" <anishs@vsnl.com>
From: "Anish Srivastava" <anishs@vsnl.com>
Subject: kernel 2.4.17 with -rmap VM patch ROCKS!!!
Date: Thu, 24 Jan 2002 15:56:54 +0530
MIME-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Andrea Arcangeli <andrea@suse.de>, Rik van Riel <riel@conectiva.com.br>, alan@lxorguk.ukuu.org.uk
List-ID: <linux-mm.kvack.org>

Hi!

I installed kernel 2.4.17 on my SMP server with 8CPU's and 8GB RAM 
and lets just say that whenever the entire physical memory was utilised
the box would topple over...with kswapd running a havoc on CPU utilization
So to avoid losing control I had to reboot every 8 hours.

But, it all changed after I applied Rik van Riels 2.4.17-rmap-11c patch
Now, the box is happily running for the past 3 days under heavy load 
without any problems. The RAM utilization is always at about 95% +
but the system doesnt swap at all.....kswapd is running all the time and 
freeing up main memory for other processes. I am quite happy with the
performance of the box........and highly recommend Rik's patches
for anyone else facing similar problems

Thanks to all you guys for helping me out....

Best regards,

Anish Srivastava

Linux Rulez!!!



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
