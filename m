Received: from sp1n293en1.watson.ibm.com (sp1n293en1.watson.ibm.com [9.2.112.57])
	by igw3.watson.ibm.com (8.11.4/8.11.4) with ESMTP id g07IXRn19758
	for <linux-mm@kvack.org>; Mon, 7 Jan 2002 13:33:27 -0500
Received: from watson.ibm.com (discohall.watson.ibm.com [9.2.17.22])
	by sp1n293en1.watson.ibm.com (8.11.4/8.11.4) with ESMTP id g07IXRn41278
	for <linux-mm@kvack.org>; Mon, 7 Jan 2002 13:33:27 -0500
Message-ID: <3C39EAD1.20CDF9CE@watson.ibm.com>
Date: Mon, 07 Jan 2002 13:37:05 -0500
From: "Raymond B. Jennings III" <raymondj@watson.ibm.com>
Reply-To: raymondj@watson.ibm.com
MIME-Version: 1.0
Subject: Hole in kernel virtual address space.
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

I've asked this question in the past but have yet to get any insight to
it.

Basically there appears to be a hole when HIGHMEM is turned on in the
kernel.

With HIGHMEM turned off:
VMALLOC_END = FIXADDR_START - 2*PAGE_SIZE
VMALLOC_END = (FFFFE000h - 4*PAGE_SIZE) - 2*PAGE_SIZE
(Pretty close to the 4GB boundary)

With HIGHMEM turned on:

VMALLOC_END = PKMAP_BASE - 2*PAGE_SIZE

I realize you need room for the pkmap_count array but the array only
allows for 1024 pages.  If PKMAP_BASE = FE000000h then this fills the
address space upto
FE400000.  What is being used in the remaining section of the address
space?  Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
