Received: from taynzmail03.nz-tay.cpqcorp.net (taynzmail03.nz-tay.cpqcorp.net [16.47.4.103])
	by zmamail04.zma.compaq.com (Postfix) with ESMTP id E4935498E
	for <linux-mm@kvack.org>; Wed,  8 Aug 2001 13:29:58 -0400 (EDT)
Received: from src-mail.pa.dec.com (src-mail.pa.dec.com [16.4.16.35])
	by taynzmail03.nz-tay.cpqcorp.net (Postfix) with ESMTP id 360A578E
	for <linux-mm@kvack.org>; Wed,  8 Aug 2001 13:29:58 -0400 (EDT)
Message-Id: <200108081729.f78HTvY06100@srcintern6.pa.dec.com>
Subject: Swapping anonymous pages
Date: Wed, 08 Aug 2001 10:29:57 -0700
From: Keir Fraser <fraser@pa.dec.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: fraser@pa.dec.com
List-ID: <linux-mm.kvack.org>

Hi,

Having spent some time reading the Linux VM code, I have a question
about the swap_out algorithm in vmscan.c. It seems to me that the outer
loop there is "backwards" -- the page tables of each address space are
scanned and mapped to physical pages, rather than scanning physical
pages and having a list of mappings of that page to be invalidated
when the page is swapped. 

This seems particularly strange when there is already infrastructure
for scanning physical pages in the LRU cache: why do extra work to
scan virtual address spaces as well? Seems to defeat one of the main
reasons for moving to a unified paging mechanism :)

The only reasons I can see for doing the current way are:
 * keeping the reverse (physical -> virtual) mappings would eat too
   much memory. 
 * since it's old (pre-2.4) code, perhaps noone has yet got round to
   rewriting it for the new design.

So, I'm curious to know which of the two it is (or whether the current
way was found to be "good enough").

 Best wishes,
 Keir Fraser
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
