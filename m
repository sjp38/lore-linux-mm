Date: Wed, 6 Feb 2002 22:07:23 -0200 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: Huge vmalloc request? Need help...
In-Reply-To: <3C617066.3DF01E66@tsl.uu.se>
Message-ID: <Pine.LNX.4.33L.0202062206230.17850-100000@imladris.surriel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 6 Feb 2002, Yuri Petukhov wrote:

>  I tried to allocate (vmalloc) huge (512MB) memory block inside my
> init_module(), but without success. It is possible to get about
> 48MB only. I work on Pentium SMP, 1GB RAM, RedHat-6.2 with kernel
> 2.2.18. Is there some restrictions on vmalloc'ed size? I need
> non-swapped memory block, of course.

Don't do this, you don't need this space.

On a 1 GB machine, the system leaves only 128 MB of space
for both highmem bounce buffers and vmalloc.

Your solution would be to keep track of which pages you're
using yourself.

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
