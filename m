Message-ID: <3BDC54D8.213F7003@zip.com.au>
Date: Sun, 28 Oct 2001 10:56:24 -0800
From: Andrew Morton <akpm@zip.com.au>
MIME-Version: 1.0
Subject: Re: xmm2 - monitor Linux MM active/inactive lists graphically
References: <E15xu2b-0008QL-00@the-village.bc.nu> <Pine.LNX.4.33.0110280945150.7360-100000@penguin.transmeta.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, Zlatko Calusic <zlatko.calusic@iskon.hr>, Jens Axboe <axboe@suse.de>, Marcelo Tosatti <marcelo@conectiva.com.br>, linux-mm@kvack.org, lkml <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Linus Torvalds wrote:
> 
> And it may be that the hpt366 IDE driver has always had this braindamage,
> which the -ac code hides. Or something like this.
> 

My hpt366, running stock 2.4.14-pre3 performs OK.
	time ( dd if=/dev/zero of=foo bs=10240k count=100 ; sync )
takes 35 seconds (30 megs/sec).  The same on current -ac kernels.

Maybe Zlatko's drive stopped doing DMA?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
