Date: Sat, 6 Jul 2002 13:11:19 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: [PATCH][RFT](2) minimal rmap for 2.5 - akpm tested
In-Reply-To: <3D274C6A.C6E23CAA@zip.com.au>
Message-ID: <Pine.LNX.4.44.0207061301570.893-100000@home.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@zip.com.au>
Cc: Rik van Riel <riel@conectiva.com.br>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Sat, 6 Jul 2002, Andrew Morton wrote:
>
> That is basically what do_munmap() does.  But I'm quite unfamiliar
> with the locking in there.

The only major user of i_shared is really vmtruncate, I think, and it's
quite ok to unmap the file before removing the mapping from the shared
list - if vmtruncate finds a unmapped area, it just won't be doing
anything (zap_page_range, but that won't do anything without any page
tables).

Together with the fact that unmap() already does it this way anyway, it
looks like the obvious fix..

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
