Date: Fri, 2 Jun 2000 13:01:07 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [PATCH] VM kswapd autotuning vs. -ac7
In-Reply-To: <qwwln0ow02r.fsf@sap.com>
Message-ID: <Pine.LNX.4.21.0006021259490.14259-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Rohland <cr@sap.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 2 Jun 2000, Christoph Rohland wrote:

> This patch still does not allow swapping with shm. Instead it
> kills all runnable processes without message.

As I said before, I haven't touched the SHM code at all.
Also, the shmtest test program runs fine here (except for
reduced system responsiveness)...

I'm quite interested in how you make your system die by
using SHM. I haven't succeeded in doing so here...

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
