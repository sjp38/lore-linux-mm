Date: Tue, 19 Feb 2002 10:10:28 -0300 (BRT)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [PATCH] reduce struct_page size
In-Reply-To: <Pine.LNX.4.33.0202181806340.24597-100000@home.transmeta.com>
Message-ID: <Pine.LNX.4.33L.0202191009260.1930-100000@imladris.surriel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 18 Feb 2002, Linus Torvalds wrote:
> On Mon, 18 Feb 2002, Rik van Riel wrote:
> >
> > o page->zone is shrunk from a pointer to an index into a small
> >   array of zones ... this means we have space for 3 more chars
> >   in the struct page to other stuff (say, page->age)
>
> Why not put "page->zone" into the page flags instead?

Done.  I'll resubmit the patch with this change once I've
tested the thing, in an hour or two.

regards,

Rik
-- 
"Linux holds advantages over the single-vendor commercial OS"
    -- Microsoft's "Competing with Linux" document

http://www.surriel.com/		http://distro.conectiva.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
