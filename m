Received: from [212.18.232.186] (helo=caramon.arm.linux.org.uk)
	by smtp.mailbox.net.uk with esmtp (Exim 3.22 #2)
	id 15aDro-0003j4-00
	for linux-mm@kvack.org; Fri, 24 Aug 2001 11:07:08 +0100
Received: from flint.arm.linux.org.uk (IDENT:mail@flint.arm.linux.org.uk [192.168.0.4])
	by caramon.arm.linux.org.uk (8.11.2/8.11.2) with ESMTP id f7OA76212800
	for <linux-mm@kvack.org>; Fri, 24 Aug 2001 11:07:07 +0100
Received: from rmk by flint.arm.linux.org.uk with local (Exim 3.16 #1)
	id 15aDrm-0008Lh-00
	for linux-mm@kvack.org; Fri, 24 Aug 2001 11:07:06 +0100
Date: Fri, 24 Aug 2001 11:07:06 +0100
From: Russell King <rmk@arm.linux.org.uk>
Subject: Patch for review
Message-ID: <20010824110706.B31722@flint.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

Could someone please review the patch at:

   http://www.arm.linux.org.uk/developer/patches/?action=viewpatch&id=613/1

and indicate whether it is acceptable to you folks?

The problem is that on some Intel StrongARM-based machines, the address
line A20 must never be set when performing DMA accesses, otherwise the
SDRAM gets corrupted.  Therefore, we must only provide a 1MB DMA region.
As Nico Pitre says there, Linux currently expects all memory zones to be
larger than 2MB.

Thanks.

--
Russell King (rmk@arm.linux.org.uk)                The developer of ARM Linux
             http://www.arm.linux.org.uk/personal/aboutme.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
