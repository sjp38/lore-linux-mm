Received: from dyn-33.linux.theplanet.co.uk ([195.92.244.33] helo=caramon.arm.linux.org.uk)
	by www.linux.org.uk with esmtp (Exim 3.13 #1)
	id 13TnMz-0003Kx-00
	for linux-mm@kvack.org; Tue, 29 Aug 2000 16:32:14 +0100
Received: from flint.arm.linux.org.uk (root@flint [192.168.0.4])
	by caramon.arm.linux.org.uk (8.9.3/8.9.3) with ESMTP id QAA14832
	for <linux-mm@kvack.org>; Tue, 29 Aug 2000 16:32:18 +0100
Received: (from rmk@localhost)
	by flint.arm.linux.org.uk (8.9.3/8.9.3) id QAA24159
	for linux-mm@kvack.org; Tue, 29 Aug 2000 16:31:15 +0100
From: Russell King <rmk@arm.linux.org.uk>
Message-Id: <200008291531.QAA24159@flint.arm.linux.org.uk>
Subject: filemap_sync over-eager at flushing?
Date: Tue, 29 Aug 2000 16:31:15 +0100 (BST)
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

I've been looking at the TLB/Cache code in 2.4.0-test7 (prompted by
Dave Millers description in test8-pre1), and have come across something
odd:

filemap_sync() calls flush_{cache,tlb}_range().  In between, it
eventually calls filemap_sync_pte(), which uses flush_{cache,tlb}_page().
But hang on, we've already done flush_cache_range(), and are going to do
flush_tlb_range() in filemap_sync(), so isn't the flush_{cache,tlb}_page
rather unnecessary?
   _____
  |_____| ------------------------------------------------- ---+---+-
  |   |         Russell King        rmk@arm.linux.org.uk      --- ---
  | | | | http://www.arm.linux.org.uk/personal/aboutme.html   /  /  |
  | +-+-+                                                     --- -+-
  /   |               THE developer of ARM Linux              |+| /|\
 /  | | |                                                     ---  |
    +-+-+ -------------------------------------------------  /\\\  |
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
