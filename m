Received: from earthlink.net (Joe@rosen.localdomain.private [192.168.81.122])
	by orado.localdomain.private (8.11.4/8.10.2) with ESMTP id g3LMRmI03129
	for <linux-mm@kvack.org>; Sun, 21 Apr 2002 16:27:49 -0600
Message-ID: <3CC33CDF.7F48A5B3@earthlink.net>
Date: Sun, 21 Apr 2002 16:27:43 -0600
From: Joseph A Knapka <jknapka@earthlink.net>
MIME-Version: 1.0
Subject: Why *not* rmap, anyway?
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi folks,

I was just reading Bill's reply regaring rmap, and it
seems to me that rmap is the most obvious and clean
way to handle unmapping pages. So now I wonder why
it wasn't done that way from the beginning?

It took me a while to figure out all the complicated
interactions between virtual and physical scanning
in the Linux mm system. If I were writing a VM system
and I got to the point where I wanted to be able to
unmap a possibly-shared page, I would say to myself,
"Hmm, this will require a map of physical pages
to all their virtual addresses. Ick. But on the
other hand, the alternatives are probably a lot more
complicated," and I would just go ahead and implement
physical-to-virtual mappings. So why did Linus and/or
the MM hackers of ages past implement the parallel
virtual-and-physical-scanning thing? What are the
advantages, besides less data overhead? It seems
to me that the old method really complicates the
code a lot, and gives the CPU more work to do to
boot.

Thanks,

-- Joe
  Using open-source software: free.
  Pissing Bill Gates off: priceless.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
