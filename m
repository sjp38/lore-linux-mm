Date: Sun, 7 May 2000 17:16:49 -0600 (MDT)
From: jgg@debian.org
Reply-To: Jason Gunthorpe <jgg@ualberta.ca>
Subject: UltraSPARC MM issue
Message-ID: <Pine.LNX.3.96.1000507164922.25185c-100000@wakko.deltatee.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux-MM@kvack.org
Cc: "David S. Miller" <davem@redhat.com>
List-ID: <linux-mm.kvack.org>

Hi,

I had a chat with Rik van Riel on IRC today, and he suggested making
a posting about my findings to the linux-mm list.

There is a problem with the UltraSPARC port of linux. The basic issue is
that the Ultra port uses order 2 pages when allocating PTEs (see
./arch/sparc64/mm/init.c:get_pte_slow). It is quite easy to cause enough
memory fragmentation that these allocations begin to fail which leads to
either an OOM-type situation or an Oops. Either way the machine pretty
much goes down.

I hope someone will feel inspired to work on this sometime over the 2.5
release cycle..

A little background: Sun donated to Debian a rather large UltraSPARC with
a really big RAID for use as our root archive server. It turns out that
our archive maint scripts cause severe memory fragmentation and show this
problem really easially.. 

Thanks,
Jason
Debian

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
