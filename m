Date: Mon, 21 Oct 2002 20:30:06 -0200 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: ZONE_NORMAL exhaustion (dcache slab)
In-Reply-To: <309670000.1035236015@flay>
Message-ID: <Pine.LNX.4.44L.0210212028100.22993-100000@imladris.surriel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@aracnet.com>
Cc: Andrew Morton <akpm@digeo.com>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm mailing list <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, 21 Oct 2002, Martin J. Bligh wrote:

> > Blockdevices only use ZONE_NORMAL for their pagecache.  That cat will
> > selectively put pressure on the normal zone (and DMA zone, of course).
>
> Ah, I recall that now. That's fundamentally screwed.

It's not too bad since the data can be reclaimed easily.

The problem in your case is that the dentry and inode cache
didn't get reclaimed. Maybe there is a leak so they can't get
reclaimed at all or maybe they just don't get reclaimed fast
enough.

I'm looking into the "can't be reclaimed fast enough" problem
right now. First on 2.4-rmap, but if it works I'll forward-port
the thing to 2.5 soon (before Linus returns from holidays).

regards,

Rik
-- 
Bravely reimplemented by the knights who say "NIH".
http://www.surriel.com/		http://distro.conectiva.com/
Current spamtrap:  <a href=mailto:"october@surriel.com">october@surriel.com</a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
