Date: Mon, 8 Jan 2001 15:36:23 -0200 (BRDT)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: MM/VM todo list
In-Reply-To: <Pine.GSO.4.05.10101081230560.23656-100000@aa.eps.jhu.edu>
Message-ID: <Pine.LNX.4.21.0101081535330.21675-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: afei@jhu.edu
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, 8 Jan 2001 afei@jhu.edu wrote:

> About the RSS ulimit proposal, have we resolved the correctness
> of counting RSS in a process?

I have not taken^Whad the time to check the kernel tree
and see if the RSS counting has indeed been made safe
everywhere.

regards,

Rik
--
Virtual memory is like a game you can't win;
However, without VM there's truly nothing to lose...

		http://www.surriel.com/
http://www.conectiva.com/	http://distro.conectiva.com.br/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
