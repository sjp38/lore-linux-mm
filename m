Date: Sat, 3 Jun 2000 22:28:43 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: Long time spent in swap_out &co
In-Reply-To: <m2snuuz3bg.fsf@boreas.southchinaseas>
Message-ID: <Pine.LNX.4.21.0006032219070.17414-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: John Fremlin <vii@penguinpowered.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 4 Jun 2000, John Fremlin wrote:

>         (a) The entire list of processes is scanned through each time
>         at least once. (Slow, and holding a lock.)

This is not very slow, since it only looks at something like
3 or 4 numbers and flags per process.

>         (b) The biggest rss is chosen. Admittedly the swap_cnt
>         heuristics help a bit but it means that a large process that
>         is on touching its pages will keep distracting attention from
>         more smaller processes that may or may not be more wasteful.

Please look at the 'assign' variable. We will chose the process
with the biggest swap_cnt until swap_cnt for *all* processes is
0.

Then we will reassign swap_cnt. This ensures that all processes
get scanned fairly.

Also, note the counter variable, we'll only scan up to a few
processes, and we'll return after we have freed just one page.

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
