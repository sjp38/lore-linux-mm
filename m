Date: Wed, 31 Jul 2002 18:55:11 -0300 (BRT)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: throttling dirtiers
In-Reply-To: <3D485775.14A8B483@zip.com.au>
Message-ID: <Pine.LNX.4.44L.0207311853150.23404-100000@imladris.surriel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@zip.com.au>
Cc: Benjamin LaHaise <bcrl@redhat.com>, William Lee Irwin III <wli@holomorphy.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 31 Jul 2002, Andrew Morton wrote:

> > These ingredients are already in 2.4-rmap.
>
> It doesn't seem to work.  The -ac kernel has weird stalls on
> storms of ext3 writeback.

Maybe you shouldn't have cut off the other line from my
2-line mail ;)))

The most probable reason for the stalls is the fact that
page_launder (like shrink_cache) will try to write out
the complete inactive list if it's almost full of dirty
pages, so the system will still be stuck in __get_request_wait
seconds after the first few megabytes of the paged out
inactive pages have been cleaned already.

cheers,

Rik
-- 
Bravely reimplemented by the knights who say "NIH".

http://www.surriel.com/		http://distro.conectiva.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
