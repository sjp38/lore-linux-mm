Message-ID: <46EDDF0F.2080800@redhat.com>
Date: Sun, 16 Sep 2007 21:57:35 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH/RFC 8/14] Reclaim Scalability:  Ram Disk Pages are non-reclaimable
References: <20070914205359.6536.98017.sendpatchset@localhost> <20070914205451.6536.39585.sendpatchset@localhost>
In-Reply-To: <20070914205451.6536.39585.sendpatchset@localhost>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <lee.schermerhorn@hp.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, mel@csn.ul.ie, clameter@sgi.com, balbir@linux.vnet.ibm.com, andrea@suse.de, a.p.zijlstra@chello.nl, eric.whitney@hp.com, npiggin@suse.de
List-ID: <linux-mm.kvack.org>

Lee Schermerhorn wrote:
> PATCH/RFC 08/14 Reclaim Scalability:  Ram Disk Pages are non-reclaimable
> 
> Against:  2.6.23-rc4-mm1
> 
> Christoph Lameter pointed out that ram disk pages also clutter the
> LRU lists. 

Agreed, these should be moved out of the way to a nonreclaimable
list.

-- 
Politics is the struggle between those who want to make their country
the best in the world, and those who believe it already is.  Each group
calls the other unpatriotic.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
