Date: Thu, 14 Sep 2000 01:30:26 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: [PATCH *] VM patch for 2.4.0-test8
Message-ID: <Pine.LNX.4.21.0009140119560.1075-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.redhat.com, Linus Torvalds <torvalds@transmeta.com>
List-ID: <linux-mm.kvack.org>

Hi,

The new VM patch seems has received a major amount of
code cleanup, performance tuning and stability improvement
over the last few days and is now almost production
quality, with the following 4 items left for 2.4:

- improve streaming IO performance
- out of memory handling
- integrate Ben LaHaise's readahead on the VMA level
  (and make drop_behind() work for that) .. fixes kswapd cpu eating
- (maybe) make drop_behind() work better for some cases
- testing, testing, testing, testing ...

The post-2.4 TODO list contains these items:
- physical page based aging  (reduce kswapd cpu use more and
  do better/more fair page aging)
- much much better IO clustering  (neatly abstracted away?)
- page->mapping->flush() callback for journaling and network
  filesystems   (maybe later in 2.4)
- thrashing control (like process suspension?)


The new VM already seems to be more stable under load than the
old VM and tuning has taken it so far that I'm already running
into bottle necks in /other/ places (eg. the elevator code)
when putting the system under rediculously heavy load...

I haven't had much time to do things like dbench and tiobench
testing though, which is why I'm sending this email and asking
the enthousiast benchmarkers to give the patch a try and tell
me about the results.

Oh, and please don't restrict yourself to just the synthetic
benchmarks. The VM is there to give the best results for
applications that have something like a working set and has
not been tuned yet to give good performance for benchmarks
(which seem to run very much different from any application
I've ever seen).

regards,

Rik
--
"What you're running that piece of shit Gnome?!?!"
       -- Miguel de Icaza, UKUUG 2000

http://www.conectiva.com/		http://www.surriel.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
