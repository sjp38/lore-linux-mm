Received: from mail.ccr.net (ccr@alogconduit1ag.ccr.net [208.130.159.7])
	by kvack.org (8.8.7/8.8.7) with ESMTP id EAA09938
	for <linux-mm@kvack.org>; Tue, 2 Feb 1999 04:42:04 -0500
Subject: Re: Ramdisk for > 1GB / >2 GB
References: <004401be4e29$fb998300$c80c17ac@clmsdev>
From: ebiederm+eric@ccr.net (Eric W. Biederman)
Date: 02 Feb 1999 01:54:33 -0600
In-Reply-To: "Manfred Spraul"'s message of "Mon, 1 Feb 1999 22:25:54 +0100"
Message-ID: <m1n22xqlza.fsf@flinx.ccr.net>
Sender: owner-linux-mm@kvack.org
To: Manfred Spraul <masp0008@stud.uni-sb.de>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>>>>> "MS" == Manfred Spraul <masp0008@stud.uni-sb.de> writes:

MS> I've written a ramdisk driver that can use physical, unmapped memory. I've
MS> posted a beta version this morning to linux-kernel.
MS> Basically, it is a kernel patch that manages the memory (alloc_hugemem(),
MS> free_hugemem()), and a block device driver that can use this memory.

MS> I'm new in the Linux MM, perhaps you could help me on these questions:

MS> 1) SMP:
MS> I use a spinlock for every ramdisk, and one page for each drive as a window
MS> to the physical memory. Since only 1 processor uses this page, I can use
MS> __flush_tlb_one( == INVLPG only on the local processor) without any further
MS> synchronization.

Sounds good.  But it's not my area of expertise.

MS> Is that stable on SMP, and do you think that this parallel enough?

MS> Linus suggested using one 4MB pte for each processor, but I think that this
MS> would be to much overhead.
MS> Another idea would be using a hash table (eg. 32 spinlocks, 32 pages) that
MS> is shared by all processors.

Except for quantity of address space consumed a 4MB pte should be equal to a
4k pte.

MS> 3) Is more than 2 GB memory a problem that only applies to the i386
MS> architecture, or is there demand for that on PowerPC, Sparc32?

It's a problem for 32bit architectures.  Most of the RISC processors (I believe)
have 64bit extensions so it's less of an issue there.

Eric
--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
