Date: Thu, 19 Sep 2002 22:03:31 -0300 (BRT)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: memory allocation on linux
In-Reply-To: <20020920002137.72873.qmail@mail.com>
Message-ID: <Pine.LNX.4.44L.0209192202110.1857-100000@imladris.surriel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Chin <leechin@mail.com>
Cc: "Cannizzaro, Emanuele" <ecannizzaro@mtc.ricardo.com>, ebiederm+eric@ccr.net, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 19 Sep 2002, Lee Chin wrote:

> I have a process trying to allocate a large amount of memory.
> I have 4 GB physical memory in the system and more with swap space.

> However, I am unable to allocate more than 2GB for my process.
> How can I acheive this?

Switch to a 64-bit CPU.  If you link your program statically
you might be able to get up to nearly 3 GB of memory for your
process, but that's the limit...

Rik
-- 
Bravely reimplemented by the knights who say "NIH".

http://www.surriel.com/		http://distro.conectiva.com/

Spamtraps of the month:  september@surriel.com trac@trac.org

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
