Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id BAA27599
	for <linux-mm@kvack.org>; Sun, 15 Dec 2002 01:03:29 -0800 (PST)
Message-ID: <3DFC455E.1FD92CBC@digeo.com>
Date: Sun, 15 Dec 2002 01:03:26 -0800
From: Andrew Morton <akpm@digeo.com>
MIME-Version: 1.0
Subject: Re: freemaps
References: <3DFBF26B.47C04A6@digeo.com> <Pine.LNX.4.44.0212150926130.1831-100000@localhost.localdomain>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: "Frederic Rossi (LMC)" <Frederic.Rossi@ericsson.ca>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Ingo Molnar wrote:
> 
> ...
> another approach might be to maintain some sort of tree of holes.

This one, I'd suggest.  If we're going to fix this we may as
well fix it right.  Otherwise there will always be whacky failure
modes.

Trees are tricky, because we don't like to recur.

I expect this could be solved with two trees:

- For searching, a radix-tree indexed by hole size.  A list
  of same-sized holes at each leaf.

- For insertion (where we must perform merging) an rbtree.

But:

- Do we need to keep the lists of same-sized holes sorted by
  virtual address, to avoid fragmentation?

- Do all mm's incur all this stuff, or do we build it all when
  some threshold is crossed?

- How does it play with non-linear mappings?
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
