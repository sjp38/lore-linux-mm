Date: Tue, 5 Apr 2005 12:12:38 +0100 (BST)
From: Christian Smith <csmith@micromuse.com>
Subject: Re: The using of memory buffer/cache and free
In-Reply-To: <ea908f9e050405035024b5bcc3@mail.gmail.com>
Message-ID: <Pine.LNX.4.58.0504051208470.10247@erol>
References: <ea908f9e050405035024b5bcc3@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: RichardR <randjunk@gmail.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 5 Apr 2005, RichardR wrote:

>Hi all,
>I just want to wipe out some doubts in my knowledges about how
>processes and kernel use memory buffer/cache and memory free.
>My doubt is, when I run the first time my machine and when I run
>"free"... it shows me corrret numbers. no memory leaks on view...
>
>Now when I try to run some process, like a  simple rsync transfer
>which takes some time to finish...I just can see that my "free" goes
>down, which can be explained with the rsync activities...
>after some minutes...the rsync ended and what I can still see is this:
>
>root@4[root]# free
>             total       used       free     shared    buffers     cached
>Mem:       2075428    2051948      23480          0      10872    1965908
>-/+ buffers/cache:      75168    2000260
>Swap:            0          0          0
>--
>Memory free is not flushed out even after an "update" or "sync" and
>cached is highly stored.
>
>Now when I want to know the total load of memory used by running
>processes, I can find only 151320 bytes used! and my total memory is
>2Gb, the rest is on cached...

That's 151320K, BTW.


>
> [snip ps output]
>
>my question is: is it normal that such a process can demande such
>memory free and then cached by the kernel without being flushed after
>used?


The data in the cache will be flushed (if it is dirty) back to disc as and
when required, but will stay in memory in case it is used again, that is
the nature of a cache.

If memory pressure dictates memory reuse, the cache size will be reduced
to make memory available. But while there is no memory pressure, it might
as well be left in memory.


Christian

-- 
    /"\
    \ /    ASCII RIBBON CAMPAIGN - AGAINST HTML MAIL
     X                           - AGAINST MS ATTACHMENTS
    / \
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
