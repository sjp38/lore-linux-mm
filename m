Date: Mon, 24 Apr 2000 15:21:40 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Reply-To: riel@nl.linux.org
Subject: Re: mmap64?
In-Reply-To: <20000424190754.B1566@redhat.com>
Message-ID: <Pine.LNX.4.21.0004241520560.5572-100000@duckman.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Jason Titus <jason.titus@av.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 24 Apr 2000, Stephen C. Tweedie wrote:
> On Sat, Apr 22, 2000 at 06:30:35PM -0300, Rik van Riel wrote:
> > 
> > Eurhmm, exactly where in the address space of your process are
> > you going to map this file?
> 
> mmap64() is defined to allow you to map arbitrary regions of
> large files into your address space.  You don't have to map the
> whole file.

<nitpick>
To be more precise, you _can't_ map the whole file,
which seemed to be what the original poster was asking
for...
</nitpick>

cheers,

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
