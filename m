Date: Wed, 8 May 2002 10:40:44 -0300 (BRT)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [PATCH] rmap 13a
In-Reply-To: <Pine.LNX.4.33.0205080346450.31184-100000@dbear.engr.sgi.com>
Message-ID: <Pine.LNX.4.44L.0205081040260.32261-100000@imladris.surriel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Samuel Ortiz <sortiz@dbear.engr.sgi.com>
Cc: Christoph Hellwig <hch@infradead.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 8 May 2002, Samuel Ortiz wrote:

> However, I should modify my patch in order for the changes to take place
> only if (!CONFIG_HIGHMEM)&&(CONFIG_DISCONTIG_MEM)&&(!WANT_PAGE_VIRTUAL).
> I can come back with the right changes if that makes sense to you.

Please read what went into rmap 13a  ;)

Rik
-- 
Bravely reimplemented by the knights who say "NIH".

http://www.surriel.com/		http://distro.conectiva.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
