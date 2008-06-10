Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e5.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m5AM0upA020374
	for <linux-mm@kvack.org>; Tue, 10 Jun 2008 18:00:56 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m5AM0uQ3212980
	for <linux-mm@kvack.org>; Tue, 10 Jun 2008 18:00:56 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m5AM0uv9013737
	for <linux-mm@kvack.org>; Tue, 10 Jun 2008 18:00:56 -0400
Date: Tue, 10 Jun 2008 18:00:55 -0400
From: Dave Kleikamp <shaggy@linux.vnet.ibm.com>
Message-Id: <20080610220055.10257.84465.sendpatchset@norville.austin.ibm.com>
Subject: [RFC:PATCH 00/06] Strong Access Ordering page attributes for POWER7
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linuxppc-dev list <Linuxppc-dev@ozlabs.org>
Cc: linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Allow an application to enable Strong Access Ordering on specific pages of
memory on Power 7 hardware. Currently, power has a weaker memory model than
x86. Implementing a stronger memory model allows an emulator to more
efficiently translate x86 code into power code, resulting in faster code
execution.

On Power 7 hardware, storing 0b1110 in the WIMG bits of the hpte enables
strong access ordering mode for the memory page.  This patchset allows a
user to specify which pages are thus enabled by passing a new protection
bit through mmap() and mprotect().  I have tentatively defined this bit,
PROT_SAO, as 0x10.

In order to accomplish this, I had to modify the architecture-independent
code to allow the architecture to deal with additional protection bits.

Patches built against 2.6.26-rc5.

Any and all suggestions, complaints, flames, insults, etc. are appreciated.

Thanks,
Shaggy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
