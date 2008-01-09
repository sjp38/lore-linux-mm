Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate2.de.ibm.com (8.13.8/8.13.8) with ESMTP id m09FE3cc122134
	for <linux-mm@kvack.org>; Wed, 9 Jan 2008 15:14:03 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m09FE29t2985984
	for <linux-mm@kvack.org>; Wed, 9 Jan 2008 16:14:02 +0100
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m09FE2AT028589
	for <linux-mm@kvack.org>; Wed, 9 Jan 2008 16:14:02 +0100
Subject: [rfc][patch 0/4] VM_MIXEDMAP patchset with s390 backend v2
From: Carsten Otte <cotte@de.ibm.com>
In-Reply-To: <1199784954.25114.27.camel@cotte.boeblingen.de.ibm.com>
References: <20071214133817.GB28555@wotan.suse.de>
	 <20071214134106.GC28555@wotan.suse.de> <476A73F0.4070704@de.ibm.com>
	 <476A7D21.7070607@de.ibm.com> <20071221004556.GB31040@wotan.suse.de>
	 <476B9000.2090707@de.ibm.com> <20071221102052.GB28484@wotan.suse.de>
	 <476B96D6.2010302@de.ibm.com>  <20071221104701.GE28484@wotan.suse.de>
	 <1199784954.25114.27.camel@cotte.boeblingen.de.ibm.com>
Content-Type: text/plain
Date: Wed, 09 Jan 2008 16:14:03 +0100
Message-Id: <1199891643.28689.21.camel@cotte.boeblingen.de.ibm.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: carsteno@de.ibm.com, Jared Hulbert <jaredeh@gmail.com>, Linux Memory Management List <linux-mm@kvack.org>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>
List-ID: <linux-mm.kvack.org>

This patchset is an improved version of yesterday's patchset, which does
contain the following patches:

1/4: add arch callbacks to toggle reference counting for VM_MIXEDMAP 
pages
2/4: patch from Jared Hulbert that introduces VM_MIXEDMAP
3/4: patch from Nick Piggin, which uses VM_MIXEDMAP for XIP mappings
4/4: remove struct page entries for z/VM DCSS memory segments

This patch series is tested on top of Linus' git tree with ext2 -o xip
and dcssblk on s390x.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
