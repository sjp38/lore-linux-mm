Message-ID: <3A6D5D28.C132D416@sangate.com>
Date: Tue, 23 Jan 2001 12:30:00 +0200
From: Mark Mokryn <mark@sangate.com>
MIME-Version: 1.0
Subject: ioremap_nocache problem?
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

ioremap_nocache does the following:
	return __ioremap(offset, size, _PAGE_PCD);

However, in drivers/char/mem.c (2.4.0), we see the following:

	/* On PPro and successors, PCD alone doesn't always mean 
	    uncached because of interactions with the MTRRs. PCD | PWT
	    means definitely uncached. */ 
	if (boot_cpu_data.x86 > 3)
		prot |= _PAGE_PCD | _PAGE_PWT;

Does this mean ioremap_nocache() may not do the job?

-mark
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
