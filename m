Date: Tue, 23 Apr 2002 21:46:20 -0300 (BRT)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: Why *not* rmap, anyway?
In-Reply-To: <Pine.LNX.4.33.0204232317320.1968-100000@erol>
Message-ID: <Pine.LNX.4.44L.0204232145120.1960-100000@imladris.surriel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christian Smith <csmith@micromuse.com>
Cc: Joseph A Knapka <jknapka@earthlink.net>, "Martin J. Bligh" <Martin.Bligh@us.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 23 Apr 2002, Christian Smith wrote:

> The question becomes, how much work would it be to rip out the Linux MM
> piece-meal, and replace it with an implementation of UVM?

I doubt we want the Mach pmap layer.

It should be much easier to reimplement the pageout parts of
the BSD memory management on top of a simpler reverse mapping
system.

You can get that code at  http://surriel.com/patches/

cheers,

Rik
-- 
Bravely reimplemented by the knights who say "NIH".

http://www.surriel.com/		http://distro.conectiva.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
