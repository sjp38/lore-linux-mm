Received: from funky.monkey.org (smtp@funky.monkey.org [152.160.231.196])
	by kvack.org (8.8.7/8.8.7) with ESMTP id RAA24745
	for <linux-mm@kvack.org>; Sun, 4 Apr 1999 17:07:39 -0400
Date: Sun, 4 Apr 1999 17:07:22 -0400 (EDT)
From: Chuck Lever <cel@monkey.org>
Subject: Re: [patch] arca-vm-2.2.5
In-Reply-To: <Pine.LNX.4.05.9904020120200.2057-100000@laser.random>
Message-ID: <Pine.BSF.4.03.9904041657210.15836-100000@funky.monkey.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <andrea@e-mind.com>
Cc: linux-kernel@vger.rutgers.edu, linux-mm@kvack.org, "Stephen C. Tweedie" <sct@redhat.com>
List-ID: <linux-mm.kvack.org>

On Fri, 2 Apr 1999, Andrea Arcangeli wrote:
> Well in the last days I had new design ideas on the VM (I mean
> shrink_mmap() and friends). I finished implementing them and the result
> looks like impressive under heavy VM load.
> 
> I would like if people that runs linux under high VM load would try it out
> my new VM code.
> 
> 	ftp://e-mind.com/pub/linux/arca-tree/2.2.5_arca2.gz

i noticed a couple of differences with your original modifications, right
off the bat.

first, i notice you've altered the page hash function and quadrupled the
size of the hash table.  do you have measurements/benchmarks that show
that the page hash was not working well?  can you say how a plain 2.2.5
kernel compares to one that has just the page hash changes without the
rest of your VM modifications? the reason i ask is because i've played
with that hash table, and found most changes to it cause undesirable
increases in system CPU utilization.  although, it *is* highly interesting
that the buffer hash table is orders of magnitude larger, yet hashes about
the same number of objects.  can someone provide history on the design of
the page hash function?

also, can you tell what improvement you expect from the additional logic
in try_to_free_buffers() ?

	- Chuck Lever
--
corporate:	<chuckl@netscape.com>
personal:	<chucklever@netscape.net> or <cel@monkey.org>

The Linux Scalability project:
	http://www.citi.umich.edu/projects/citi-netscape/

--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
