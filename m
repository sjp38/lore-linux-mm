Received: from ns-ca.netscreen.com (ns-ca.netscreen.com [10.100.10.21])
	by mail.netscreen.com (8.10.0/8.10.0) with ESMTP id f2NLLv503227
	for <Linux-MM@kvack.org>; Fri, 23 Mar 2001 13:21:57 -0800
Message-ID: <A33AEFDC2EC0D411851900D0B73EBEF72627AC@NAPA>
From: Hua Ji <hji@netscreen.com>
Subject: About page table with powerpc 750
Date: Fri, 23 Mar 2001 15:37:38 -0800
MIME-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux-MM@kvack.org
List-ID: <linux-mm.kvack.org>

  

Hi, folks,

A quick question today. Thanks in advance.

For PowerPC, say, 750 architecture, does every process ALSO maintains its
own page table, like the one under Intel x86 two level page tables?
 
>From powerpc manual, a 2M space needed to be reserved for mapping 256M
physical memory. So, if every process maintain its own page table, that
would be cost too much.

If every process, at initial time, only holds a small size page table, how
does the kernel extend the page table area? My thought is: With powerpc, the
page table area is not a two level pointer, so, we need a contigeous
physical memory.

What the mechanism for linux with powerpc when handling the page table
issue?

Thanks a lot,

Nike
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
