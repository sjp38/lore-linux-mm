Date: Mon, 2 Oct 2000 15:01:10 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: TODO list for new VM  (oct 2000)
Message-ID: <Pine.LNX.4.21.0010021447430.22539-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.redhat.com
Cc: linux-mm@kvack.org, Matthew Dillon <dillon@apollo.backplane.com>, Linus Torvalds <torvalds@transmeta.com>
List-ID: <linux-mm.kvack.org>

[MM TODO list, updated for october 2000]

---
Here is the TODO list for the new VM. The only thing
really needed for 2.4 is the OOM handler and a fix
for the highmem deadlock.

The page->mapping->flush() callback is really wanted
by the journaling filesystem folks.

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
- fix the highmem deadlock, where the swapper cannot create
  low memory bounce buffers OR swap out low memory because
  it has consumed all resources
	[old bug, already reported with 2.4.0-test6, probably before]

for kernel 2.4, really wanted:
- page->mapping->flush() callback in page_launder(),
  for easier integration with journaling filesystems
  and maybe the network filesystems
	[about 30 minutes of work on the VM side]

for kernel 2.4, wanted:
- maybe rebalance the swapper a bit ... we do page aging
  now so maybe refill_inactive_scan() / shm_swap() and
  swap_out() need to be rebalanced a bit

for kernel 2.5:    (maybe available as patch for 2.4 ???)
- physical->virtual reverse mapping, so we can do much
  better page aging with less CPU usage spikes
- better IO clustering for swap (and filesystem) IO
- move all the global VM variables, lists, etc. into
  the pgdat struct for better NUMA scalability
- (maybe) some QoS things, as far as they are major
  improvements with minor intrusion
- thrashing control, maybe process suspension with some
  forced swapping ?
- include Ben LaHaise's code, which moves readahead
  to the VMA level, this way we can do streaming swap
  IO, complete with drop_behind()

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
