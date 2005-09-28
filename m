Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e3.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id j8SGgcZr023376
	for <linux-mm@kvack.org>; Wed, 28 Sep 2005 12:42:38 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay04.pok.ibm.com (8.12.10/NCO/VERS6.7) with ESMTP id j8SGgYbd104138
	for <linux-mm@kvack.org>; Wed, 28 Sep 2005 12:42:38 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11/8.13.3) with ESMTP id j8SGgYB7020960
	for <linux-mm@kvack.org>; Wed, 28 Sep 2005 12:42:34 -0400
Subject: Re: [patch] bug of pgdat_list connection in init_bootmem()
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <20050928223844.8655.Y-GOTO@jp.fujitsu.com>
References: <20050928223844.8655.Y-GOTO@jp.fujitsu.com>
Content-Type: text/plain
Date: Wed, 28 Sep 2005 09:42:15 -0700
Message-Id: <1127925735.10315.232.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Yasunori Goto <y-goto@jp.fujitsu.com>
Cc: Andrew Morton <akpm@osdl.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 2005-09-28 at 22:50 +0900, Yasunori Goto wrote:
>   I would like to remove this pgdat_list, to simplify hot-add/remove
>   a node. and posted patch before.
>    http://marc.theaimsgroup.com/?l=linux-mm&m=111596924629564&w=2
>    http://marc.theaimsgroup.com/?l=linux-mm&m=111596953711780&w=2
> 
>   I would like to repost after getting performance impact by this.
>   But it is very hard that I can get time to use big NUMA machine now.
>   So, I don't know when I will be able to repost it.
> 
>   Anyway, this should be modified before remove pgdat_list.

Could you resync those to a current kernel and resend them?  I'll take
them into -mhp for a bit.

I'd be very skeptical that it would hurt performance.  If nothing else,
it just makes the pgdat smaller, and the likelyhood of having the next
bit in a bitmask and the NODE_DATA() entry in your cache is slightly
higher than some random pgdat->list.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
