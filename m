Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e36.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m5IMXUsX019064
	for <linux-mm@kvack.org>; Wed, 18 Jun 2008 18:33:30 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m5IMXU0f176550
	for <linux-mm@kvack.org>; Wed, 18 Jun 2008 16:33:30 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m5IMXTWL018406
	for <linux-mm@kvack.org>; Wed, 18 Jun 2008 16:33:30 -0600
Message-Id: <20080618223254.966080905@linux.vnet.ibm.com>
Date: Wed, 18 Jun 2008 17:32:54 -0500
From: shaggy@linux.vnet.ibm.com
Subject: [patch 0/6] Strong Access Ordering page attributes for POWER7
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Paul Mackerras <paulus@au1.ibm.com>, linux-mm@kvack.org, Linuxppc-dev@ozlabs.org
List-ID: <linux-mm.kvack.org>

Andrew,

The first patch in this series hits architecture independent code, but the
rest is contained in the powerpc subtree.  Could you pick up the first
patch into -mm?  I can send the rest of them through the powerpc git tree.
The first patch and the rest of the set are independent and can be merged
in either order.

Changes since I posted on June 10:
- Fixed reversed logic in arch_validate_prot() in include/asm-powerpc/mman.h
- Replace binary & with logical && in arch_validate_prot()
- Got rid of HAVE_ARCH_PROT_BITS

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

Thanks,
Shaggy
-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
