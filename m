From: "David S. Miller" <davem@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <15002.64299.147336.376138@pizda.ninka.net>
Date: Mon, 26 Feb 2001 16:56:11 -0800 (PST)
Subject: Re: RFC: vmalloc improvements
In-Reply-To: <3A9AF9E7.D0924A4C@scs.ch>
References: <Pine.LNX.4.30.0102240129200.5327-100000@elte.hu>
	<3A9AF9E7.D0924A4C@scs.ch>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Reto Baettig <baettig@scs.ch>
Cc: mingo@elte.hu, MM Linux <linux-mm@kvack.org>, Kernel Linux <linux-kernel@vger.kernel.org>, Martin Frey <frey@scs.ch>
List-ID: <linux-mm.kvack.org>

Reto Baettig writes:
 > The RPC server needs lots of 2MB receive buffers which are
 > allocated using vmalloc because the NIC has its own pagetables.

Why not just allocate the page seperately and keep track of
where they are, since the NIC has all the page tabling facilities
on it's end, the cpu side is just a software issue.  You can keep
an array of pages how ever large you need to keep track of that.

vmalloc() was never meant to be used on this level and doing
so is asking for trouble (it's also deadly expensive on SMP due
to the cross-cpu tlb invalidates using vmalloc() causes).

Later,
David S. Miller
davem@redhat.com
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
