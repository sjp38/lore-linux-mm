Received: from dyn-33.linux.theplanet.co.uk ([195.92.244.33] helo=caramon.arm.linux.org.uk)
	by www.linux.org.uk with esmtp (Exim 3.13 #1)
	id 14kpiB-0005xA-00
	for linux-mm@kvack.org; Wed, 04 Apr 2001 17:00:47 +0100
Received: from raistlin.arm.linux.org.uk (IDENT:root@raistlin.arm.linux.org.uk [192.168.0.3])
	by caramon.arm.linux.org.uk (8.11.0/8.11.0) with ESMTP id f34G0kg03209
	for <linux-mm@kvack.org>; Wed, 4 Apr 2001 17:00:46 +0100
From: rmk@arm.linux.org.uk
Received: (from rmk@localhost)
	by raistlin.arm.linux.org.uk (8.7.4/8.7.3) id RAA01119
	for linux-mm@kvack.org; Wed, 4 Apr 2001 17:00:45 +0100
Message-Id: <200104041600.RAA01119@raistlin.arm.linux.org.uk>
Subject: pte_young/pte_mkold/pte_mkyoung
Date: Wed, 4 Apr 2001 17:00:44 +0100 (BST)
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

We currently seem to have:
	2 references to pte_mkyoung()
	1 reference to pte_mkold()
	0 references to pte_young()

This tells me that we're no longer using the hardware page tables on x86
for page aging, which leads me nicely on to the following question.

Are there currently any plans to use the hardware page aging bits in the
future, and if there are, would architectures that don't have them be
required to have them?

I'm asking this question because for some time (1.3 onwards), the ARM
architecture has had some code to handle software emulation of the young
and dirty bits.  If its not required, then I'd like to get rid of this
software emulation.

--
Russell King (rmk@arm.linux.org.uk)                The developer of ARM Linux
             http://www.arm.linux.org.uk/personal/aboutme.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
