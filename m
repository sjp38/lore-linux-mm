Received: from www21.ureach.com (IDENT:root@www21.ureach.com [172.16.2.49])
	by ureach.com (8.9.1/8.8.5) with ESMTP id HAA14300
	for <linux-mm@kvack.org>; Thu, 5 Jul 2001 07:57:50 -0400
Date: Thu, 5 Jul 2001 07:57:50 -0400
Message-Id: <200107051157.HAA10231@www21.ureach.com>
From: Kapish K <kapish@ureach.com>
Reply-to: <kapish@ureach.com>
Subject: on MAXMEM_PFN and VMALLOC_RESERVE
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hello,
 What does this code ( in arch/i386/kernel/setup.c ), actually 
imply?
/* 
 *Determine low and high memory ranges: 
 */

max_low_pfn=max_pfn;
if ( max_low_pfn > MAXMEM_PFN ){
      max_low_pfn = MAXMEM_PFN;
#ifndef CONFIG_HIGHMEM
    /* Maximum memory usable is what is directlt addressable */
Now here, what does this imply, and the significance of 
VMALLOC_RESERVE in the MAXMEM_PFN calculations ( as in setup.c ) 
:MAXMEM_PFN PFN_DOWN(MAXMEM)
where MAXMEM = (unsigned long) ( -PAGE_OFFSET - VMALLOC_RESERVE 
)
Also, what is the significance of this in terms of physical RAM 
sizes of 128 mb or more ( even greater than 1 GB ). I assume 
that still will not be high mem.
Any hints or pointers would be welcome.
Thanks



________________________________________________
Get your own "800" number
Voicemail, fax, email, and a lot more
http://www.ureach.com/reg/tag
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
