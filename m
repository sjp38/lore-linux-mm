Subject: Re: RFC: vmalloc improvements
Date: Sat, 24 Feb 2001 01:09:28 +0000 (GMT)
In-Reply-To: <200102240026.QAA09446@k2.llnl.gov> from "Reto Baettig" at Feb 23, 2001 04:26:56 PM
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-Id: <E14WTDH-0007UQ-00@the-village.bc.nu>
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: baettig@scs.ch
Cc: MM Linux <linux-mm@kvack.org>, Kernel Linux <linux-kernel@vger.kernel.org>, Martin Frey <frey@scs.ch>
List-ID: <linux-mm.kvack.org>

> We have an application that makes extensive use of vmalloc (we need
> lots of large virtual contiguous buffers. The buffers don't have to be
> physically contiguous).

So you could actually code around that. If you have them virtually contiguous
for mmap for example then you can actually mmap arbitary page arrays

> We would volounteer to improve vmalloc if there is any chance of
> getting it into the main kernel tree. We also have an idea how we
> Could do that (quite similar to the process address space management):

Im not the one to call the shots, but it seems if you need an AVL for the
vmalloc tables then vmalloc is possibly being overused, or people are not
allocating buffers just occasionally as anticipated
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
