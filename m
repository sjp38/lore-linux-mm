Date: Sat, 3 Jun 2000 17:47:37 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [PATCH] VM kswapd autotuning vs. -ac7
In-Reply-To: <qwwhfbbw31s.fsf@sap.com>
Message-ID: <Pine.LNX.4.21.0006031746410.5754-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Rohland <cr@sap.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 3 Jun 2000, Christoph Rohland wrote:
> Rik van Riel <riel@conectiva.com.br> writes:
> > On 2 Jun 2000, Christoph Rohland wrote:
> > 
> > > This patch still does not allow swapping with shm. Instead it
> > > kills all runnable processes without message.
> 
> Simply by running 
> 
> ./ipctst 10 666000000 10 31 20&
> ./ipctst 16 666000000 2 31 20&     
> 
> But I have to correct me. It does not kill all runnable
> processes, but all I am using like ipctst, vmstat and xterm.

Patch #2 indeed had a big bug that made all systems crash instead
of use swap (missing braces next to a goto), does patch #3 give you
the same behaviour?

regards,

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
