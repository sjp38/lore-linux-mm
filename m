Subject: Re: MM question
References: <Pine.LNX.3.95.990224120401.25235C-100000@as200.spellcast.com>
From: Magnus Ahltorp <map@stacken.kth.se>
Date: 24 Feb 1999 18:55:33 +0100
In-Reply-To: "Benjamin C.R. LaHaise"'s message of "Wed, 24 Feb 1999 12:36:11 -0500 (EST)"
Message-ID: <ixdbtij8z56.fsf@turbot.pdc.kth.se>
Sender: owner-linux-mm@kvack.org
To: "Benjamin C.R. LaHaise" <blah@kvack.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> Okay, you probably don't want to implement readpage, just read and write,
> so your read will look like:
> 
> This will make your inodes relatively lightweight, and avoid having in
> memory pages attached to your inode which would be duplicates of those
> attached to the ext2 inode.

Doesn't this mean that the read functions will be called every time
something has to be read? What about mmap?

> Readpage is called by generic_file_read and page fault handlers to pull
> the page into the page cache.  In the case of writing, you need to update
> the page cache, as well as commit the write to whatever backstore is used. 
> Since you've got the entire file cached (right?), just making use of the
> ext2 inode's read & write will keep the cache coherent and reduce the
> amount work you need to do. 

At the moment, we do whole file caching, but that might change in the
future.

/Magnus
--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
