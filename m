Received: from lin.varel.bg (root@lin.varel.bg [212.50.6.9])
	by kvack.org (8.8.7/8.8.7) with ESMTP id DAA01811
	for <linux-mm@kvack.org>; Mon, 16 Nov 1998 03:30:16 -0500
Message-ID: <364FE29E.2CF14EEA@varel.bg>
Date: Mon, 16 Nov 1998 10:30:22 +0200
From: Petko Manolov <petkan@varel.bg>
MIME-Version: 1.0
Subject: 4M kernel pages
References: <Pine.LNX.3.96.981113150452.4593A-100000@mirkwood.dummy.home>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

I red in the intel docs that it is possile to have mixed
4K and 4M pages for pentium+ machines. Also we have less
TLB misses when the kernel is in 4M page. I know Linus 
don't like the idea of mixing different page sizes but
if this a improvemet...

-- 
Petko Manolov - petkan@varel.bg
http://www.varel.bg/~petkan
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
