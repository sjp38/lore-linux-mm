Date: Wed, 31 Jul 2002 19:32:13 -0300 (BRT)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: throttling dirtiers
In-Reply-To: <3D48639C.E0EF9B71@zip.com.au>
Message-ID: <Pine.LNX.4.44L.0207311931150.23404-100000@imladris.surriel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@zip.com.au>
Cc: Benjamin LaHaise <bcrl@redhat.com>, William Lee Irwin III <wli@holomorphy.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 31 Jul 2002, Andrew Morton wrote:

> > The most probable reason for the stalls is the fact that
> > page_launder (like shrink_cache) will try to write out
> > the complete inactive list if it's almost full of dirty
> > pages, so the system will still be stuck in __get_request_wait
> > seconds after the first few megabytes of the paged out
> > inactive pages have been cleaned already.
>
> I doubt if it's that, although it might be.
>
> It happens just during a kernel build, 768M of RAM.  And/or
> during big CVS operations.  Possibly it's due to ext3 checkpointing.

Indeed, my scenario above is unlikely to be the reason with
these workloads.

However, I have noticed the problem with fillmem, or just
when the system has the sudden urge to swapout a large
process ;)

regards,

Rik
-- 
Bravely reimplemented by the knights who say "NIH".

http://www.surriel.com/		http://distro.conectiva.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
