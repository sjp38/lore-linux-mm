Received: from lin.varel.bg (root@lin.varel.bg [212.50.6.9])
	by kvack.org (8.8.7/8.8.7) with ESMTP id HAA18492
	for <linux-mm@kvack.org>; Fri, 13 Nov 1998 07:04:30 -0500
Received: from petkan (root@petkan.varel.bg [212.50.6.17])
	by lin.varel.bg (8.8.6/8.8.6) with SMTP id QAA28004
	for <linux-mm@kvack.org>; Fri, 13 Nov 1998 16:03:49 +0200
Message-ID: <364C2049.360B6131@varel.bg>
Date: Fri, 13 Nov 1998 14:04:25 +0200
From: Petko Manolov <petkan@varel.bg>
MIME-Version: 1.0
Subject: May be stupid question ;-)
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

I'm wonder if its possible to have kernel code+data > 4M? So
pg0 won't be enough. And we have to init pg1. AFAIK the kernel don't
allocate more page tables for itself while in run. It sounds to me like
troubles in the future.  

	Petkan 
-- 
Petko Manolov - petkan@varel.bg
http://www.varel.bg/~petkan
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
