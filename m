Received: (1363 bytes) by baldur.fh-brandenburg.de
	via sendmail with P:stdio/R:match-inet-hosts/T:smtp
	(sender: <zippel@fh-brandenburg.de>)
	id <m14L7w3-000pvnC@baldur.fh-brandenburg.de>
	for <linux-mm@kvack.org>; Tue, 23 Jan 2001 19:12:51 +0100 (MET)
	(Smail-3.2.0.97 1997-Aug-19 #3 built DST-Sep-15)
Date: Tue, 23 Jan 2001 19:12:36 +0100 (MET)
From: Roman Zippel <zippel@fh-brandenburg.de>
Subject: Re: ioremap_nocache problem?
In-Reply-To: <3A6D5D28.C132D416@sangate.com>
Message-ID: <Pine.GSO.4.10.10101231903380.14027-100000@zeus.fh-brandenburg.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mark Mokryn <mark@sangate.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hi,

On Tue, 23 Jan 2001, Mark Mokryn wrote:

> ioremap_nocache does the following:
> 	return __ioremap(offset, size, _PAGE_PCD);
> 
> However, in drivers/char/mem.c (2.4.0), we see the following:
> 
> 	/* On PPro and successors, PCD alone doesn't always mean 
> 	    uncached because of interactions with the MTRRs. PCD | PWT
> 	    means definitely uncached. */ 
> 	if (boot_cpu_data.x86 > 3)
> 		prot |= _PAGE_PCD | _PAGE_PWT;
> 
> Does this mean ioremap_nocache() may not do the job?

ioremap creates a new mapping that shouldn't interfere with MTRR, whereas
you can map a MTRR mapped area into userspace. But I'm not sure if it's
correct that no flag is set for boot_cpu_data.x86 <= 3...

bye, Roman

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
