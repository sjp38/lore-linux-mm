Date: Wed, 20 Nov 2002 16:31:40 -0200 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: RE: Porting to from Solaris 64bit to Linux 32B - 36B.
In-Reply-To: <C5BF7C2C6ADF24448763CC46235FB3A691C833@ulysses.neocore.com>
Message-ID: <Pine.LNX.4.44L.0211201629170.4103-100000@imladris.surriel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jon Goldberg <jgoldberg@neocore.com>
Cc: Andrew Morton <akpm@digeo.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 20 Nov 2002, Jon Goldberg wrote:

> 	Will that return a 64 bit offset pointer to the file or just let
> me map 3-4GB in a 10 BG file with a 64 bit offset pointer.  What I would
> like to do is mmap the full 10GB file and walk it with a 64 bit pointer
> knowing that not more that 2GB can be in memory.

How exactly do you think the mythical mmap64() would ever work
on 32 bit machines ?

It is impossible to map 10 GB of file into 2-3 GB of virtual
address space.

Maybe there is a userspace library to emulate things with (slow)
64 bit pointers, etc... but it is fundamentally impossible to do
in kernel space.

regards,

Rik
-- 
Bravely reimplemented by the knights who say "NIH".
http://www.surriel.com/		http://guru.conectiva.com/
Current spamtrap:  <a href=mailto:"october@surriel.com">october@surriel.com</a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
