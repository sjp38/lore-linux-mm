Message-ID: <3A9AF9E7.D0924A4C@scs.ch>
Date: Mon, 26 Feb 2001 16:50:47 -0800
From: Reto Baettig <baettig@scs.ch>
MIME-Version: 1.0
Subject: Re: RFC: vmalloc improvements
References: <Pine.LNX.4.30.0102240129200.5327-100000@elte.hu>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: mingo@elte.hu
Cc: MM Linux <linux-mm@kvack.org>, Kernel Linux <linux-kernel@vger.kernel.org>, Martin Frey <frey@scs.ch>
List-ID: <linux-mm.kvack.org>

Ingo Molnar wrote:
> question: what is this application, and why does it need so much virtual
> memory? vmalloc()-able memory is maximized to 128 MB right now, and
> increasing it conflicts with directly mapping RAM, so generally it's a
> good idea to avoid vmalloc() as much as possible.

We implemented a RPC mechanism over a fast network in the kernel. The
end application is a distributed filesystem. The RPC server needs lots
of 2MB receive buffers which are allocated using vmalloc because the NIC
has its own pagetables.
The buffers then get handed to the consumer (lots of threads) which
eventually frees them. This way, we have a performance on the RPC layer
of 200MBytes/s.

The 128MB limit is probably an Intel limitation since we don't see it on
our Alpha Machines (Linux 2.2.18 Alpha SMP)

Reto
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
