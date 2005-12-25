Received: from rockstar.fsl.cs.sunysb.edu (rockstar.fsl.cs.sunysb.edu [130.245.126.62])
	by filer.fsl.cs.sunysb.edu (8.12.8/8.13.1) with ESMTP id jBPFJKe3001185
	for <linux-mm@kvack.org>; Sun, 25 Dec 2005 10:19:20 -0500
Subject: Oopsing on memory returned by __get_free_pages()
From: Avishay Traeger <atraeger@cs.sunysb.edu>
Content-Type: text/plain
Date: Sun, 25 Dec 2005 10:19:20 -0500
Message-Id: <1135523960.23126.13.camel@rockstar.fsl.cs.sunysb.edu>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hello all,

I am trying to allocate 32KB of memory, and am calling:
buf = (char *)__get_free_pages(GFP_KERNEL, 3);

>From what I see in other kernel code and what I read, I thought that I
could use this chunk of memory as is.  However, it is oopsing while
trying to access the second page that was returned.  The starting
address for the memory that was returned is 0xf61c0000, and the oops
says "Unable to handle kernel paging request at virtual address
f61c1000".

Do I need to do anything special with the memory before I can use it?
Is it not correct to use it as a big 32KB buffer?  I'm sorry if this is
a bit of a noob question, but I have been stuck on the problem for a
couple days and have not found the answer anywhere.

Thanks in advance,
Avishay Traeger

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
