Message-ID: <4518C7AD.3090507@anu.edu.au>
Date: Tue, 26 Sep 2006 16:24:45 +1000
From: Nick Piggin <u3293115@anu.edu.au>
MIME-Version: 1.0
Subject: Re: [PATCH] Make invalidate_inode_pages2() work again
References: <20060925231557.32226.66866.stgit@ingres.dsl.sfldmi.ameritech.net>	 <45186D4A.70009@yahoo.com.au> <1159233613.5442.61.camel@lade.trondhjem.org> <451884C1.8080209@yahoo.com.au>
In-Reply-To: <451884C1.8080209@yahoo.com.au>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Chuck Lever <chucklever@gmail.com>, apkm@osdl.org, linux-mm@kvack.org, steved@redhat.com
List-ID: <linux-mm.kvack.org>

Nick Piggin wrote:

> So I really dislike get_user_pages for reasons such as this. IMO it would
> be cool if get_user_pages when the caller wants to write, would return 
> with
> the page dirty and a bit set to prevent writeout from cleaning it 
> until it
> has been finished with (via put_user_pages).
>
> Actually, _ideally_, maybe keeping the mapping around (ie. holding at
> least a read lock on mmap_sem) would do the trick. The presence of the
> mapping will be seen by the invalidate routines[*], and in general things
> might be simplified.


No, I guess that isn't going to work, because it'll mean one thread can
DoS the others WRT mmap and brk. I'll look into the per-page flag bit
idea.

--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
