Date: Mon, 28 Nov 2005 20:36:01 +0900
From: Yasunori Goto <y-goto@jp.fujitsu.com>
Subject: [Patch] New zone ZONE_EASY_RECLAIM take 2[0/5]
Message-Id: <20051128195854.5D78.Y-GOTO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>, Linux Hotplug Memory Support <lhms-devel@lists.sourceforge.net>
Cc: Joel Schopp <jschopp@austin.ibm.com>, linux-ia64@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hello.

I rewrote ZONE_EASY_RECLAIM patches.
It aimed to collect the page which was difficult for removing on a few nodes,
and it made other nodes this zone to be removed easier.


In -mm tree, ZONE_DMA32 is already included. So, I recreate 
ZONE_EASY_RECLAIM as 5th zone against 2.6.14-mm1. It is difference of
previous one.

And, I'll post another patch to solve how to allocate ZONE_EASY_RECLAIM
after these patch. But, it is not direct way for it. So, I would like
to divide from these patche.

Please comment.

-- 
Yasunori Goto 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
