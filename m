Received: from imperial.edgeglobal.com (imperial.edgeglobal.com [208.197.226.14])
	by edgeglobal.com (8.9.1/8.9.1) with ESMTP id KAA06997
	for <linux-mm@kvack.org>; Mon, 4 Oct 1999 10:34:17 -0400
Date: Mon, 4 Oct 1999 10:38:13 -0400 (EDT)
From: James Simmons <jsimmons@edgeglobal.com>
Subject: MMIO regions
Message-ID: <Pine.LNX.4.10.9910041028350.7066-100000@imperial.edgeglobal.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Howdy again!!

   I noticed something for SMP machines with all the dicussion about
concurrent access to memory regions. What happens when you have two
processes that have both mmapped the same MMIO region for some card.
Doesn't have to be a video card,. On a SMP machine it is possible that
both processes could access the same region at the same time. This could
cause the card to go into a indeterminate state. Even lock the machine.
Does their exist a way to handle this? Also some cards have mulitple MMIO
regions. What if a process mmaps one MMIO region of this card and another
process mmaps another MMIO region of this card. Now process one could
alter the card in such a way it could effect the results that process two
is expecting. How is this dealt with? Is it dealt with? If not what would
be a good way to handle this?  

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
