Subject: Re: 2.5.70-mm4
From: Felipe Alfaro Solana <felipe_alfaro@linuxmail.org>
In-Reply-To: <1054741940.8438.175.camel@plars>
References: <20030603231827.0e635332.akpm@digeo.com>
	 <1054741940.8438.175.camel@plars>
Content-Type: text/plain
Message-Id: <1054749653.699.3.camel@teapot.felipe-alfaro.com>
Mime-Version: 1.0
Date: 04 Jun 2003 20:00:53 +0200
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Larson <plars@linuxtestproject.org>
Cc: Andrew Morton <akpm@digeo.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 2003-06-04 at 17:52, Paul Larson wrote:
> On Wed, 2003-06-04 at 01:18, Andrew Morton wrote:
> > ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.5/2.5.70/2.5.70-mm4/
> A couple of issues:
> 
> Hangs on boot unless I use acpi=off, but I don't believe this is unique
> to -mm.  I've seen this on plain 2.5 kernels on and off before with this
> 8-way and others like it.  AFAIK the acpi issues are ongoing and still
> being worked, but please let me know if there's any information I can
> gather other than what's already out there that would assist in fixing
> these.

This remembers me of a pretty strange issue I'm having with ACPI on my
NEC/Packard Bell Chrom@ laptop: if I plug my 3Com CardBus NIC in the
second PCMCIA slot, the kernel hangs during boot just at the time the
NIC generates an interrupt (for example, by sending a ping or some
traffic). However, if I plug the NIC into the first slot, it works
perfectly.

Curious, isn't it? I think it's related to ACPI IRQ routing: the NIC
uses IRQ10 when plugged into the first slot, but it uses IRQ5 when
plugged into the second one (which causes the mentioned hang). IRQ5 is
being shared with my YMFPCI sound card. Don't know if this is related to
the hangs, but I thought it was worth saying.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
