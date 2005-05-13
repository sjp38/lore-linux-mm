Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
        by fgwmail6.fujitsu.co.jp (Fujitsu Gateway)
        id j4D7QIQv013692 for <linux-mm@kvack.org>; Fri, 13 May 2005 16:26:18 +0900
        (envelope-from y-goto@jp.fujitsu.com)
Received: from s4.gw.fujitsu.co.jp by m3.gw.fujitsu.co.jp (8.12.10/Fujitsu Domain Master)
	id j4D7QH3N025411 for <linux-mm@kvack.org>; Fri, 13 May 2005 16:26:17 +0900
	(envelope-from y-goto@jp.fujitsu.com)
Received: from s4.gw.fujitsu.co.jp (localhost [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 3FD6215362D
	for <linux-mm@kvack.org>; Fri, 13 May 2005 16:26:17 +0900 (JST)
Received: from fjm505.ms.jp.fujitsu.com (fjm505.ms.jp.fujitsu.com [10.56.99.83])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id E3A81153632
	for <linux-mm@kvack.org>; Fri, 13 May 2005 16:26:16 +0900 (JST)
Received: from [10.124.100.220] (fjmscan501.ms.jp.fujitsu.com [10.56.99.141])by fjm505.ms.jp.fujitsu.com with ESMTP id j4D7Pujl023798
	for <linux-mm@kvack.org>; Fri, 13 May 2005 16:25:57 +0900
Date: Fri, 13 May 2005 16:25:56 +0900
From: Yasunori Goto <y-goto@jp.fujitsu.com>
Subject: [PATCH/RFC 0/2] Remove pgdat list
Message-Id: <20050513160538.5225.Y-GOTO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hello.

I wrote patches to remove pgdat list in pgdat structure, because
I think it is redundant.

In the current implementation, pgdat structure has this list.
struct pglist_data{
        :
   struct pglist_data *pgdat_next;
        :
}
This is used for searching other zones and nodes by for_each_pgdat and
for_each_zone macros. So, if a node is hot added,
the system has to not only set bit of node_online_map,
but also connect this for new node.
However, all of pgdat list user would like to know just
next (online) node. So, I think node_online_map is enough information
for them to find other nodes. 
By this patch, hot add/remove code for node will be a little simpler.

This patches is for 2.6.12-rc3-mhp1. I tested them on Tiger4 with
node emulation.

Please comment.

Thanks.

-- 
Yasunori Goto 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
