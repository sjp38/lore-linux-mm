Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate3.de.ibm.com (8.13.7/8.13.7) with ESMTP id k7OETCBS013118
	for <linux-mm@kvack.org>; Thu, 24 Aug 2006 14:29:12 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k7OEXGRu3100902
	for <linux-mm@kvack.org>; Thu, 24 Aug 2006 16:33:16 +0200
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k7OETC4T014716
	for <linux-mm@kvack.org>; Thu, 24 Aug 2006 16:29:12 +0200
Date: Thu, 24 Aug 2006 16:29:11 +0200
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: Guest page hinting patches.
Message-ID: <20060824142911.GA12127@skybase>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, akpm@osdl.org, nickpiggin@yahoo.com.au
Cc: frankeh@watson.ibm.com, rhim@cc.gatech.edu
List-ID: <linux-mm.kvack.org>

Fourth version of the guest page hinting patches. The code has been
polished and another race has been fixed (keep fingers crossed that
is has been that last one this time).

The basic idea of guest page hinting is to give a host system which
virtualizes the memory of its guest systems on a per page basis
usage information for the guest pages. The host can then use this
information to optimize the management of guest pages, in particular
the paging. This optimizations can be used for unused (free) guest
pages, for clean page cache pages, and for clean swap cache pages.
The content of free pages can be replace with zeroes and the content
of clean page cache / swap cache pages can be reloaded by the guest
from the backing store.

There are 9 patches that implement guest page hinting:

1) Guest page state changes for free pages.
2) s390 exploitation of state changes for free pages.
3) Guest page state changes for page cache pages.
4) Guest page state changes for swap cache pages.
5) Keep mlocked pages in stable state.
6) Add support for writable page table entries.
7) Optimization for minor faults.
8) Discarded page list.
9) full s390 architecture support for guest page hinting.

The first two patches are independent from the other seven. These
two just deal with unused/free vs. used/stable pages. The code
starts to get interesting with patch #03..

Any objections against pushing patch #01 and patch #02 into the
-mm tree?

The code runs well on s390 and does nothing for all other archs.
Patches are against 2.6.18-rc4-mm2.

-- 
blue skies,
  Martin.

Martin Schwidefsky
Linux for zSeries Development & Services
IBM Deutschland Entwicklung GmbH

"Reality continues to ruin my life." - Calvin.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
