Date: Sat, 16 Sep 2000 06:13:27 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: TODO list for new VM
Message-ID: <Pine.LNX.4.21.0009160544000.1519-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.redhat.com, Linus Torvalds <torvalds@transmeta.com>, Matthew Dillon <dillon@apollo.backplane.com>
List-ID: <linux-mm.kvack.org>

Hi,

Here is the TODO list for the new VM. The only thing
really needed for 2.4 is the OOM handler and the
page->mapping->flush() callback is really wanted by
the journaling filesystem folks.

The rest are mostly extra's that would be nice; these
things won't be pushed for inclusion except if it turns
out to be really trivial to implement, high performance
on the cases they're supposed to affect and their influence
is highly localised...

(sorry folks, but for 2.4 I'll be really conservative)

---> TODO list for the new VM <---

for kernel 2.4, necessary:
- out of memory handling
	[integrate the OOM killer, 10 minutes work]

for kernel 2.4, really wanted:
- page->mapping->flush() callback in page_launder(),
  for easier integration with journaling filesystems
  and maybe the network filesystems
	[about 30 minutes of work on the VM side]

for kernel 2.4, wanted:
- include Ben LaHaise's code, which moves readahead
  to the VMA level, this way we can do streaming swap
  IO, complete with drop_behind()
- code to make the "knee" smoother, currently the system
  keeps eating memory from the cache up to a certain point
  and then starts to swap a lot, it would be nice to smooth
  this curve a bit
- thrashing control, maybe process suspension with some
  forced swapping ?

for kernel 2.5:
- physical->virtual reverse mapping, so we can do much
  better page aging with less CPU usage spikes
- better IO clustering for swap (and filesystem) IO
- move all the global VM variables, lists, etc. into
  the pgdat struct for better NUMA scalability
- (maybe) some QoS things, as far as they are major
  improvements with minor intrusion

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
