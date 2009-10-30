Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 31AE16B004D
	for <linux-mm@kvack.org>; Fri, 30 Oct 2009 02:51:05 -0400 (EDT)
Date: Fri, 30 Oct 2009 07:51:02 +0100
From: Christoph Hellwig <hch@lst.de>
Subject: unconditional discard calls in the swap code
Message-ID: <20091030065102.GA2896@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: hugh.dickins@tiscali.co.uk
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Hugh,

since 6a6ba83175c029c7820765bae44692266b29e67a the swap code
unconditionally calls blkdev_issue_discard when swap clusters get freed.
So far this was harmless because only the mtd driver has discard support
wired up and it's pretty fast there (entirely done in-kernel).

We're now adding support for real UNAP/TRIM support for SCSI arrays and
SSDs, and so far all the real life ones we've dealt with have too many
performance issues to just issue the discard requests on the fly.
Because of that unconditionally enabling this code is a bad idea, it
really needs an option to disable it or even better just leave it
disabled by default for now with an option to enable it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
