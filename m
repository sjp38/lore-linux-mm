Received: from garner.india.hp.com (garner.india.hp.com [15.10.45.11])
	by atlrel6.hp.com (Postfix) with ESMTP id 0CBDA949
	for <linux-mm@kvack.org>; Thu,  5 Dec 2002 08:24:36 -0500 (EST)
Received: from india.hp.com (dhcp196.india.hp.com [15.10.42.196])
	by garner.india.hp.com (8.9.3 (PHNE_18546)/8.9.3 SMKit7.02) with ESMTP id TAA17158
	for <linux-mm@kvack.org>; Thu, 5 Dec 2002 19:05:49 +0530 (IST)
Message-ID: <3DEF5294.F962BF62@india.hp.com>
Date: Thu, 05 Dec 2002 18:50:20 +0530
From: Anil Kumar Nanduri <anil@india.hp.com>
MIME-Version: 1.0
Subject: Error handling
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi All,
    While I am browsing the page_launder code, I found an interesting scenario
    which is not considered in 2.4-7 kernel, I do not know about other kernels(2.5).

    The following is the scenario....
    As page launder initiates disk transfers using submit_bh as part of cleaning
    inactive dirty pages, if that disk I/O fails, drivers generally call "buffer_IO_error"
    which will ultimately set the page_error flag for that page.

    As the page launder in its next pass or in the same pass(if the disk i/o is fast enough)
    tries to move this page into the clean list without checking page-error flag. This is fine
    with file's data, but not with swap pages.

    Incase of swap pages the ideal thing would be not to move that page to inactive list
    if the disk I/O for that block fails which is not happening currently.

    Is this a BUG?


Regards,
-anil.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
