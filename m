Date: Sat, 30 Dec 2000 19:16:39 +0100
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: 2.2.19pre3 and poor reponse to RT-scheduled processes?
Message-ID: <20001230191639.E9332@athlon.random>
References: <20001229161927.A560@xi.linuxpower.cx> <200012292154.QAA17527@ninigret.metatel.office>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200012292154.QAA17527@ninigret.metatel.office>; from rafal.boni@eDial.com on Fri, Dec 29, 2000 at 04:54:23PM -0500
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rafal Boni <rafal.boni@eDial.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Gregory Maxwell <greg@linuxpower.cx>
List-ID: <linux-mm.kvack.org>

On Fri, Dec 29, 2000 at 04:54:23PM -0500, Rafal Boni wrote:
> Now my box behaves much more reasonably... I'll just have to beat harder
> on it and see what happens.

Another thing: while writing to disk if you want low latency readers you can
do:

	elvtune -r 1 /dev/hd[abcd]

The 1/2 seconds stalls you see could be just because of applications that waits
I/O synchronously while the elevator is reodering I/O requests (and even if the
elevator wouldn't reorder anything the new requests would go to the end of the
I/O queue so they would have some higher latency anyways). That's normal and if
it's the case to avoid those stalls you can only decrease the I/O load or
increase disk throughput ;). The important thing is that the kernel is
not sitting in a tight kernel loop without reschedule in it during such 2
seconds.

However 2.2.19pre3aa4 includes also the lowlatency bugfixes in case you have
tons of ram and you're sending huge buffers to syscalls.

Andrea
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
