Received: from root by main.gmane.org with local (Exim 3.35 #1 (Debian))
	id 1BZDuC-0000fB-00
	for <linux-mm@kvack.org>; Sat, 12 Jun 2004 21:11:04 +0200
Received: from arennes-303-1-34-114.w81-250.abo.wanadoo.fr ([81.250.16.114])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-mm@kvack.org>; Sat, 12 Jun 2004 21:11:04 +0200
Received: from tyler by arennes-303-1-34-114.w81-250.abo.wanadoo.fr with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-mm@kvack.org>; Sat, 12 Jun 2004 21:11:04 +0200
From: Tyler <tyler@agat.net>
Subject: Memory management questions
Date: Sat, 12 Jun 2004 21:02:16 +0200
Message-ID: <cafjtv$76d$2@sea.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi all,

I've always thinked that paging or virtual memory was practical to avoid 
memory fragmentation. I thinked that you can map contiguous virtual 
pages to non contiguous physical page frames.
But let's take a look at the macros __va(x) and __pa(x) :
#define __pa(x) ((unsigned long)x-PAGE_OFFSET)
#define __va(x) ((unsigned long)x+PAGE_OFFSET)
PAGE_OFFSET is a constant. For me, this means that virtual contiguous 
adresses have to be mapped to contiguous physical adresses. Am I wrong ?:)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
