Date: Wed, 16 Jun 1999 22:37:01 +0200 (CEST)
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: filecache/swapcache questions
In-Reply-To: <199906151551.IAA74604@google.engr.sgi.com>
Message-ID: <Pine.LNX.4.10.9906162234180.23012-100000@laser.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kanoj Sarcar <kanoj@google.engr.sgi.com>
Cc: Rik van Riel <riel@nl.linux.org>, linux-mm@kvack.org, sct@redhat.com
List-ID: <linux-mm.kvack.org>

On Tue, 15 Jun 1999, Kanoj Sarcar wrote:

>What I am trying to find out is if it is enough to put these pages
>in the hash queue for swapper_inode, without really also putting
>them in the inode queue for swapper_inode. Its not like we ever 
>"truncate" swapper_inode, that we will need to go thru its i_pages
>list ...

Yes, it's useless taking them into the swapper inode queue too. It's this
way only because it uses a common interface.

>PS: Q4: who uses rw_swap_page_nolock, and what is shmfs? Note that
>rw_swap_page_nolock is the only caller that passes in non PageSwapCache
>pages into rw_swap_page_base(), which otherwise could assume that
>all pages passed into it are PageSwapCache, which would eliminate
>the need for a seperate PG_swap_unlock_after bit.

Please look at:

	ftp://ftp.suse.com/pub/people/andrea/kernel-patches/2.2.10_andrea-VM5.gz

Andrea Arcangeli

--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
