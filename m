Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate6.de.ibm.com (8.13.8/8.13.8) with ESMTP id m089ZtcL157704
	for <linux-mm@kvack.org>; Tue, 8 Jan 2008 09:35:55 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m089Zs5Q2785454
	for <linux-mm@kvack.org>; Tue, 8 Jan 2008 10:35:54 +0100
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m089ZsUC025912
	for <linux-mm@kvack.org>; Tue, 8 Jan 2008 10:35:54 +0100
Subject: [rfc][patch 0/4] VM_MIXEDMAP patchset with s390 backend
From: Carsten Otte <cotte@de.ibm.com>
In-Reply-To: <20071221104701.GE28484@wotan.suse.de>
References: <20071214133817.GB28555@wotan.suse.de>
	 <20071214134106.GC28555@wotan.suse.de> <476A73F0.4070704@de.ibm.com>
	 <476A7D21.7070607@de.ibm.com> <20071221004556.GB31040@wotan.suse.de>
	 <476B9000.2090707@de.ibm.com> <20071221102052.GB28484@wotan.suse.de>
	 <476B96D6.2010302@de.ibm.com>  <20071221104701.GE28484@wotan.suse.de>
Content-Type: text/plain
Date: Tue, 08 Jan 2008 10:35:54 +0100
Message-Id: <1199784954.25114.27.camel@cotte.boeblingen.de.ibm.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: carsteno@de.ibm.com, Jared Hulbert <jaredeh@gmail.com>, Linux Memory Management List <linux-mm@kvack.org>, Martin Schwidefsky <martin.schwidefsky@de.ibm.com>, Heiko Carstens <h.carstens@de.ibm.com>
List-ID: <linux-mm.kvack.org>

Am Freitag, den 21.12.2007, 11:47 +0100 schrieb Nick Piggin:
> BTW. having a per-arch function sounds reasonable for a start. I'd just give
> it a long name, so that people don't start using it for weird things ;)
> mixedmap_refcount_pfn() or something.
Based on our previous discussion, and based on previous patches by Jared
and Nick, this patch series makes XIP without struct page backing usable
on s390 architecture.
This patch set includes:
1/4: mm: introduce VM_MIXEDMAP mappings from Jared Hulbert, modified to
use an arch-callback to identify whether or not a pfn needs refcounting
2/4: xip: support non-struct page memory from Nick Piggin, modified to
use an arch-callback to identify whether or not a pfn needs refcounting
3/4: s390: remove struct page entries for z/VM DCSS memory segments
4/4: s390: proof of concept implementation of mixedmap_refcount_pfn()
for s390 using list-walk

Above stack seems to work well, I did some sniff-testing applied on top
of Linus' current git tree. We do want to spend a precious pte bit to
speed up this callback, therefore patch 4/4 will get replaced.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
