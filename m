Date: Sat, 22 Apr 2000 18:30:35 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Reply-To: riel@nl.linux.org
Subject: Re: mmap64?
In-Reply-To: <B5274D15.56A6%jason.titus@av.com>
Message-ID: <Pine.LNX.4.21.0004221830080.20850-100000@duckman.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jason Titus <jason.titus@av.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 22 Apr 2000, Jason Titus wrote:

> We have been doing some work with > 2GB files under x86 linux and have run
> into a fair number of issues (instability, non-functioning stat calls, etc).
> 
> One that just came up recently is whether it is possible to
> memory map >2GB files.  Is this a possibility, or will this
> never happen on 32 bit platforms?

Eurhmm, exactly where in the address space of your process are
you going to map this file?

Rik
--
The Internet is not a network of computers. It is a network
of people. That is its real strength.

Wanna talk about the kernel?  irc.openprojects.net / #kernelnewbies
http://www.conectiva.com/		http://www.surriel.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
