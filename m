Message-ID: <3D73C15E.1FE79B33@zip.com.au>
Date: Mon, 02 Sep 2002 12:51:58 -0700
From: Andrew Morton <akpm@zip.com.au>
MIME-Version: 1.0
Subject: Re: slablru for 2.5.32-mm1
References: <200208261809.45568.tomlins@cam.org> <200209021100.47508.tomlins@cam.org> <3D73AF73.C8FE455@zip.com.au> <200209021509.52216.tomlins@cam.org>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ed Tomlinson <tomlins@cam.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Ed Tomlinson wrote:
> 
> ...
> I thought about doing something like your patch.  I wanted to avoid
> semi-magic numbers (why a page worth of objects?  why not two or
> three...).

Well, it's just an efficiency heuristic...

>  I would rather see something like my patch, maybe coded
> in a more stylish way, used.  If we want to get bigger batch I would
> move the kmem_do_prunes up into try_to_free_pages.  This way the
> code is simpler, vmscan changes for slablru are smaller, and nothing
> magic is involved.

Doesn't make much difference, afaict.   Generally, the first pass
through shrink_caches() frees a sufficient number of pages, so
the before- and after- code are equivalent.

And because there is only one flag, we still attempt to prune all
caches which have a pruner, when it's quite possible that just one
of them has a decent amount of stuff.  Probably a minor issue though.

I wouldn't be too fussed about the extent of changes in vmscan.c.
One day, when the kernel is perfect, all of that file will have the
inlines turned on and the whole of page reclaim becomes one big
function.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
