Date: Wed, 28 Aug 2002 19:23:51 -0300 (BRT)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: slablru for 2.5.32-mm1
In-Reply-To: <3D6D3F88.5E7A1972@zip.com.au>
Message-ID: <Pine.LNX.4.44L.0208281923190.1857-100000@imladris.surriel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@zip.com.au>
Cc: Ed Tomlinson <tomlins@cam.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 28 Aug 2002, Andrew Morton wrote:

> But we do need to slowly sift through the active list even when the
> inactive list is enormously bigger.  Otherwise, completely dead pages
> will remain in-core forever if there's a lot of pagecache activity going
> on.

Doesn't that just indicate we want to get rid of use-once
and replace it with something slightly more predictable ?

regards,

Rik
-- 
Bravely reimplemented by the knights who say "NIH".

http://www.surriel.com/		http://distro.conectiva.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
