Message-ID: <46EDEC2D.9070004@redhat.com>
Date: Sun, 16 Sep 2007 22:53:33 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH/RFC 11/14] Reclaim Scalability: swap backed pages are
 nonreclaimable when no swap space available
References: <20070914205359.6536.98017.sendpatchset@localhost> <20070914205512.6536.89432.sendpatchset@localhost>
In-Reply-To: <20070914205512.6536.89432.sendpatchset@localhost>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <lee.schermerhorn@hp.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, mel@csn.ul.ie, clameter@sgi.com, balbir@linux.vnet.ibm.com, andrea@suse.de, a.p.zijlstra@chello.nl, eric.whitney@hp.com, npiggin@suse.de
List-ID: <linux-mm.kvack.org>

Lee Schermerhorn wrote:
> PATCH/RFC  11/14 Reclaim Scalability: treat swap backed pages as
> 	non-reclaimable when no swap space is available.
> 
> Against:  2.6.23-rc4-mm1
> 
> Move swap backed pages [anon, shmem/tmpfs] to noreclaim list when
> nr_swap_pages goes to zero.   Use Rik van Riel's page_anon() 
> function in page_reclaimable() to detect swap backed pages.
> 
> Depends on NORECLAIM_NO_SWAP Kconfig sub-option of NORECLAIM
> 
> TODO:   Splice zones' noreclaim list when "sufficient" swap becomes
> available--either by being freed by other pages or by additional 
> swap being added.  How much is "sufficient" swap?  Don't want to
> splice huge noreclaim lists every time a swap page gets freed.

Yet another reason for my LRU list split between filesystem
backed and swap backed pages: we can simply stop scanning the
anon lists when swap space is full and resume scanning when
swap space becomes available.

-- 
Politics is the struggle between those who want to make their country
the best in the world, and those who believe it already is.  Each group
calls the other unpatriotic.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
