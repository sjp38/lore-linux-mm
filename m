Subject: Re: 2.5.73-mm1
References: <20030623232908.036a1bd2.akpm@digeo.com>
From: Alexander Hoogerhuis <alexh@ihatent.com>
Date: 24 Jun 2003 11:33:27 +0200
In-Reply-To: <20030623232908.036a1bd2.akpm@digeo.com>
Message-ID: <87r85jn7ko.fsf@lapper.ihatent.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andrew Morton <akpm@digeo.com> writes:

> ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.5/2.5.73/2.5.73-mm1/
> 
> 
> . PCI and PCMCIA updates
>
> [SNIP]
> 

ti113x: Routing card interrupts to PCI
Yenta IRQ list 0000, PCI irq11
Socket status: 30000006
cs: warning: no high memory space available!
cs: unable to map card memory!
cs: unable to map card memory!
cs: unable to map card memory!
cs: unable to map card memory!

This is my result from modprobing yenta_socket and inserting my
wlan-card (NetGear MA311).

mvh,
A
-- 
Alexander Hoogerhuis                               | alexh@ihatent.com
CCNP - CCDP - MCNE - CCSE                          | +47 908 21 485
"You have zero privacy anyway. Get over it."  --Scott McNealy
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
