Message-ID: <384EFFD3.8DDCEF8D@mandrakesoft.com>
Date: Wed, 08 Dec 1999 20:03:15 -0500
From: Jeff Garzik <jgarzik@mandrakesoft.com>
MIME-Version: 1.0
Subject: Getting big areas of memory, in 2.3.x?
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Linux Kernel List <linux-kernel@vger.rutgers.edu>
List-ID: <linux-mm.kvack.org>

Guys,

What's the best way to get a large region of DMA'able memory for use
with framegrabbers and other greedy drivers?

Per a thread on glx-dev, Andi Kleen mentions that the new 2.3.x MM stuff
still doesn't allieviate the need for bigphysarea and similar patches.

Is there there any way a driver can improve its chance of getting a
large region of memory?  ie. can it tell the system to force out user
pages to make memory available, etc.

Thanks,

	Jeff




-- 
Jeff Garzik              | Just once, I wish we would encounter
Building 1024            | an alien menace that wasn't immune to
MandrakeSoft, Inc.       | bullets.   -- The Brigadier, "Dr. Who"
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
