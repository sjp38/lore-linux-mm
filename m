Message-ID: <3DA5C94A.5040508@colorfullife.com>
Date: Thu, 10 Oct 2002 20:39:06 +0200
From: Manfred Spraul <manfred@colorfullife.com>
MIME-Version: 1.0
Subject: Re: Hangs in 2.5.41-mm1
References: <3DA4A06A.B84D4C05@digeo.com> <1034264750.30975.83.camel@plars> <3DA5B077.215D7626@digeo.com> <3DA5B277.B5BFC9C0@digeo.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: Paul Larson <plars@linuxtestproject.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:
> Andrew Morton wrote:
> 
>>...
>>#0  0xc01357c7 in cache_alloc_refill (cachep=0xf7ffc740, flags=464) at mm/slab.c:1580
>>#1  0xc0135b1a in kmem_cache_alloc (cachep=0xf7ffc740, flags=464) at mm/slab.c:1670
>>#2  0xc0159c72 in alloc_inode (sb=0xf7f8a400) at fs/inode.c:99
>>#3  0xc015a3c5 in new_inode (sb=0xf7f8a400) at fs/inode.c:505
>>#4  0xc014f7ae in get_pipe_inode () at fs/pipe.c:510
>>#5  0xc014f867 in do_pipe (fd=0xf6693fb4) at fs/pipe.c:559
>>#6  0xc010ce01 in sys_pipe (fildes=0xbffff83c) at arch/i386/kernel/sys_i386.c:35
>>#7  0xc01070f3 in syscall_call () at net/sunrpc/stats.c:204
> 
> 
> Or it could be that the inode cache has been corrupted.
> Bill, can you review the handling in there?  It'd be a
> bit sad if one of the hugetlb privately-kmalloced inodes
> were put back onto the inode_cachep slab somehow.

Could you try to reproduce with slab debugging enabled? slab checks for 
foreign objects and BUG's.

--
	Manfred

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
