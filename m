Date: Mon, 9 Sep 2002 19:41:32 -0300 (BRT)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [PATCH] modified segq for 2.5
In-Reply-To: <3D7D182D.3514E0AD@digeo.com>
Message-ID: <Pine.LNX.4.44L.0209091938500.1857-100000@imladris.surriel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: William Lee Irwin III <wli@holomorphy.com>, sfkaplan@cs.amherst.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 9 Sep 2002, Andrew Morton wrote:

> > generic_file_write, once that function moves beyond the last
> > byte of the page, onto the next page, we can be pretty sure
> > it's done writing to this page
>
> Oh.  So why don't we just start those new pages out on the
> inactive list?

I guess that should work, combined with a re-dropping of
pages when we're doing sequential writes.

> I fear that this change will result in us encountering more dirty
> pages on the inactive list.

If that's a problem, something is seriously fucked with
the VM ;)

> Do we remove the SetPageReferenced() in generic_file_write?

Good question, I think we'll want to SetPageReferenced() when
we do a partial write but ClearPageReferenced() when we've
"written past the end" of the page.

regards,

Rik
-- 
Bravely reimplemented by the knights who say "NIH".

http://www.surriel.com/		http://distro.conectiva.com/

Spamtraps of the month:  september@surriel.com trac@trac.org

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
