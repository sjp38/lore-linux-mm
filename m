Received: from xparelay2.corp.hp.com (xparelay2.corp.hp.com [15.58.137.112])
	by palrel3.hp.com (Postfix) with ESMTP id 1FC5F9BF
	for <linux-mm@kvack.org>; Tue, 10 Apr 2001 12:34:55 -0700 (PDT)
Received: from xatlbh1.atl.hp.com (xatlbh1.atl.hp.com [15.45.89.186])
	by xparelay2.corp.hp.com (Postfix) with ESMTP id EBBAB1F508
	for <linux-mm@kvack.org>; Tue, 10 Apr 2001 15:33:18 -0400 (EDT)
Message-ID: <C78C149684DAD311B757009027AA5CDC094DA2A8@xboi02.boi.hp.com>
From: "LUTZ,TODD (HP-Boise,ex1)" <tlutz@hp.com>
Subject: Ideas for adding physically contiguous memory support to mmap()??
Date: Tue, 10 Apr 2001 15:34:17 -0400
MIME-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "'linux-mm@kvack.org'" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

I would like to be able to extend mmap() (in 2.4.2) to support returning
physically contiguous memory as shared memory.

Here are some requirements:

1. Able to specify any size that is a multiple of PAGE_SIZE (not just powers
of 2).

2. Able to specify the size when the application runs (not on the bootline
like the bigphysarea patch).

3. Able to specify sizes larger than 4MB (somewhere between 256MB and 512MB
is probably the max).

4. Preferably add another bit to the flags parameter of mmap(), like
"MAP_CONTIG".

5. It is OK for the call to fail if there isn't enough physically contiguous
memory available (even if there is enough non-contiguous memory available).

After looking at the code, I think I need to...

1. Create a function like alloc_contig_pages() similar to alloc_pages() that
takes a "numpages" parameter instead of "order".

2. Increase MAX_ORDER in mmzone.h to 17.

3. Start at do_mmap_pgoff() and change all the calls down to alloc_pages().

Any suggestions or comments?

-- Thanks,
   Todd Lutz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
