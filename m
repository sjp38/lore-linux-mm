Date: Wed, 25 Jun 2008 18:38:38 +0100
From: Jamie Lokier <jamie@shareable.org>
Subject: Re: [patch 1/2] mm: dont clear PG_uptodate in invalidate_complete_page2()
Message-ID: <20080625173837.GA10005@shareable.org>
References: <20080625124038.103406301@szeredi.hu> <20080625124121.839734708@szeredi.hu> <alpine.LFD.1.10.0806250757150.4733@hp.linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LFD.1.10.0806250757150.4733@hp.linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Miklos Szeredi <miklos@szeredi.hu>, jens.axboe@oracle.com, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, hugh@veritas.com, nickpiggin@yahoo.com.au
List-ID: <linux-mm.kvack.org>

Linus Torvalds wrote:
> I also really don't think this even fixes the problems you have with 
> FUSE/NFSD - because you'll still be reading zeroes for a truncated file. 
> Yes, you get the rigth counts, but you don't get the right data.
...
> That's "correct" from a splice() kind of standpoint (it's essentially a 
> temporary mmap() with MAP_PRIVATE), but the thing is, it just sounds like 
> the whole "page went away" thing is a more fundamental issue. It sounds 
> like nfds should hold a read-lock on the file while it has any IO in 
> flight, or something like that.

I'm thinking any kind of user-space server using splice() will not
want to transmit zeros either, when another process truncates the file.
E.g. Apache, Samba, etc.

Does this problem affect sendfile() users?

-- Jamie

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
