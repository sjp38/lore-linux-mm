Received: from lin.varel.bg (root@lin.varel.bg [212.50.6.9])
	by kvack.org (8.8.7/8.8.7) with ESMTP id CAA01591
	for <linux-mm@kvack.org>; Mon, 16 Nov 1998 02:44:44 -0500
Message-ID: <364FD7E1.1D5DA034@varel.bg>
Date: Mon, 16 Nov 1998 09:44:33 +0200
From: Petko Manolov <petkan@varel.bg>
MIME-Version: 1.0
Subject: Re: May be stupid question ;-)
References: <Pine.LNX.3.96.981113150452.4593A-100000@mirkwood.dummy.home>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Rik van Riel wrote:
> 
> Currently not, unless you compile in all sorts of useless
> drivers (or you have a machine with 30+ different kinds of
> extension cards)...

;-) No, i'm currently trying to make the kernel as small as possible
to fit in 2M of RAM (for embeded system) without any driver.

> Most of the runtime tables are allocated after the memory
> stuff has been taken care off. Then we have the infrastructure
> to allocate as much memory as we want without problems.

Yes, but all page tables are for user level code/data. I mean
we're in trouble when not all of the kernel code is paged.

-- 
Petko Manolov - petkan@varel.bg
http://www.varel.bg/~petkan
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
