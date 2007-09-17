Message-ID: <46EDE401.6070300@redhat.com>
Date: Sun, 16 Sep 2007 22:18:41 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH/RFC 9/14] Reclaim Scalability: SHM_LOCKED pages are nonreclaimable
References: <20070914205359.6536.98017.sendpatchset@localhost> <20070914205457.6536.41479.sendpatchset@localhost>
In-Reply-To: <20070914205457.6536.41479.sendpatchset@localhost>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <lee.schermerhorn@hp.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, mel@csn.ul.ie, clameter@sgi.com, balbir@linux.vnet.ibm.com, andrea@suse.de, a.p.zijlstra@chello.nl, eric.whitney@hp.com, npiggin@suse.de
List-ID: <linux-mm.kvack.org>

Lee Schermerhorn wrote:
> PATCH/RFC 09/14 Reclaim Scalability: SHM_LOCKED pages are nonreclaimable
> 
> Against:  2.6.23-rc4-mm1
> 
> While working with Nick Piggin's mlock patches, I noticed that
> shmem segments locked via shmctl(SHM_LOCKED) were not being handled.
> SHM_LOCKed pages work like ramdisk pages--the writeback function
> just redirties the page so that it can't be reclaimed.  Deal with
> these using the same approach as for ram disk pages.

Agreed, that needs to be done.

> TODO:  patch currently splices all zones' noreclaim lists back
> onto normal LRU lists when shmem region unlocked.  Could just
> putback pages from this region/file--e.g., by scanning the
> address space's radix tree using find_get_pages().

Yeah, I guess we'll want this :)

-- 
Politics is the struggle between those who want to make their country
the best in the world, and those who believe it already is.  Each group
calls the other unpatriotic.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
