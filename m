Received: from sp1n294en1.watson.ibm.com (sp1n294en1.watson.ibm.com [9.2.112.58])
	by igw3.watson.ibm.com (8.11.4/8.11.4) with ESMTP id fAKJn5O09682
	for <linux-mm@kvack.org>; Tue, 20 Nov 2001 14:49:05 -0500
Received: from watson.ibm.com (discohall.watson.ibm.com [9.2.17.22])
	by sp1n294en1.watson.ibm.com (8.11.4/8.11.4) with ESMTP id fAKJn5p28820
	for <linux-mm@kvack.org>; Tue, 20 Nov 2001 14:49:05 -0500
Message-ID: <3BFAB48D.1A772321@watson.ibm.com>
Date: Tue, 20 Nov 2001 14:52:45 -0500
From: "Raymond B. Jennings III" <raymondj@watson.ibm.com>
Reply-To: raymondj@watson.ibm.com
MIME-Version: 1.0
Subject: help with highmem
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

I was wondering why if CONFIG_HIGHMEM is NOT turned on, the vmalloc area

goes almost to the end of the 4GB boundary:

VMALLOC_END = FIXADDR_START - 2*PAGE_SIZE
- or -
VMALLOC_END = (FIXADDR_TOP - FIXADDR_SIZE) - 2*PAGE_SIZE
- or - (on my particular setup)
VMALLOC_END = (FFFFE000h - 4*PAGE_SIZE) - 2*PAGE_SIZE

In any case it is pretty close to the 4GB boundary

BUT when you have CONFIG_HIGHMEM turned on:

VMALLOC_END = PKMAP_BASE - 2*PAGE_SIZE

I realize you need room for the pkmap_count array but the array only
allows for 1024 pages.
If PKMAP_BASE = FE000000h then this fills the address space upto
FE400000.  What is being used in the remaining section of the address
space?

Couldn't PKMAP_BASE be moved up (allow for a larger vmalloc area) or
enlarge the pkmap_count array up to the point of VMALLOC_END as when
CONFIG_HIGHMEM is turned off?

Thanks for any help.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
