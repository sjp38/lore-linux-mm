Subject: Re: [PATCH] VM kswapd autotuning vs. -ac7
References: <Pine.LNX.4.21.0006021259490.14259-100000@duckman.distro.conectiva>
From: Christoph Rohland <cr@sap.com>
Date: 03 Jun 2000 11:02:07 +0200
In-Reply-To: Rik van Riel's message of "Fri, 2 Jun 2000 13:01:07 -0300 (BRST)"
Message-ID: <qwwhfbbw31s.fsf@sap.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Christoph Rohland <cr@sap.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Rik van Riel <riel@conectiva.com.br> writes:

> On 2 Jun 2000, Christoph Rohland wrote:
> 
> > This patch still does not allow swapping with shm. Instead it
> > kills all runnable processes without message.
> 
> As I said before, I haven't touched the SHM code at all.
> Also, the shmtest test program runs fine here (except for
> reduced system responsiveness)...
> 
> I'm quite interested in how you make your system die by
> using SHM. I haven't succeeded in doing so here...

Simply by running 

./ipctst 10 666000000 10 31 20&
./ipctst 16 666000000 2 31 20&     

But I have to correct me. It does not kill all runnable processes, but
all I am using like ipctst, vmstat and xterm.
 
Greetings
		Christoph
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
