Date: Sun, 3 Mar 2002 21:13:10 -0800
From: Mike Fedyk <mfedyk@matchmail.com>
Subject: Re: [PATCH] radix-tree pagecache for 2.4.19-pre2-ac2
Message-ID: <20020304051310.GC1459@matchmail.com>
References: <20020303210346.A8329@caldera.de> <20020304045557.C1010BA9E@oscar.casa.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20020304045557.C1010BA9E@oscar.casa.dyndns.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ed Tomlinson <tomlins@cam.org>
Cc: Christoph Hellwig <hch@caldera.de>, reiserfs-list@namesys.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Mar 03, 2002 at 11:55:57PM -0500, Ed Tomlinson wrote:
> On March 3, 2002 03:03 pm, Christoph Hellwig wrote:
> > I have uploaded an updated version of the radix-tree pagecache patch
> > against 2.4.19-pre2-ac2.  News in this release:
> >
> > * fix a deadlock when vmtruncate takes i_shared_lock twice by introducing
> >   a new mapping->page_lock that mutexes mapping->page_tree. (akpm)
> > * move setting of page->flags back out of move_to/from_swap_cache. (akpm)
> > * put back lost page state settings in shmem_unuse_inode. (akpm)
> > * get rid of remove_page_from_inode_queue - there was only one caller. (me)
> > * replace add_page_to_inode_queue with ___add_to_page_cache. (me)
> >
> > Please give it some serious beating while I try to get 2.5 working and
> > port the patch over 8)
> 
> Got this after a couple of hours with pre2-ac2+preempth+radixtree.
> 

Can you try again without preempt?
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
