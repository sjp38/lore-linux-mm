Date: Mon, 9 Sep 2002 18:09:43 -0300 (BRT)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [PATCH] modified segq for 2.5
In-Reply-To: <3D7D09D7.2AE5AD71@digeo.com>
Message-ID: <Pine.LNX.4.44L.0209091808160.1857-100000@imladris.surriel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: William Lee Irwin III <wli@holomorphy.com>, sfkaplan@cs.amherst.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 9 Sep 2002, Andrew Morton wrote:
> Rik van Riel wrote:

> > Move them to the inactive list the moment we're done writing
> > them, that is, the moment we move on to the next page. We
>
> The moment "who" has done writing them?  Some writeout
> comes in via shrink_foo() and a ton of writeout comes in
> via balance_dirty_pages(), pdflush, etc.

generic_file_write, once that function moves beyond the last
byte of the page, onto the next page, we can be pretty sure
it's done writing to this page

pages where it always does partial writes, like buffer cache,
database indices, etc... will stay in memory for a longer time.

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
