Date: Thu, 22 Jun 2000 13:38:39 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [RFC] RSS guarantees and limits
In-Reply-To: <85256906.0059E21B.00@D51MTA03.pok.ibm.com>
Message-ID: <Pine.LNX.4.21.0006221330180.10785-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: frankeh@us.ibm.com
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 22 Jun 2000 frankeh@us.ibm.com wrote:

> Now I understand this much better. The RSS guarantee is a
> function of the refault-rate <clever>. This in principle
> implements a decay of the limit based on usage.... I like that
> approach.

My previous anti-hog code (it even seemed to work) was to
"push" big processes harder than small processes. If, for
example, process A is N times bigger than process B, every
page in process A would get sqrt(N) times the memory pressure
a page in process B would get. This promotes fairness between
memory hogs.

This code will adjust the guarantee and the limit to the
type of memory usage, so a process which streams over a huge
amount of data just once will be restricted to maybe a few
times its window size so it'll be unable to push other processes
out of memory by simply accessing all the data quickly (but just
once).

For a fair VM we probably want a combination of this new idea
*and* some fairness measures. Preferably in such a way that
we don't interfere too much with the strategy of global page
replacement...

> Is there a hardstop RSS limit below you will not evict pages
> from a process (e.g.  mem_size / MAX_PROCESSES ?) to give some
> interactivity for processes that haven't executed for a while,
> or you just let it go down based on the refault-rate...

There is none, but maybe we should have the RSS guarantee just
go down slower and slower depending on the size of the process?

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
