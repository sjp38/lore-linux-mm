Received: from mandrakesoft.com (adsl-77-228-233.atl.bellsouth.net [216.77.228.233])
	by mail1.atl.bellsouth.net (3.3.4alt/0.75.2) with ESMTP id EAA06239
	for <linux-mm@kvack.org>; Wed, 20 Oct 1999 04:19:32 -0400 (EDT)
Message-ID: <380D7C24.AA10E463@mandrakesoft.com>
Date: Wed, 20 Oct 1999 04:24:04 -0400
From: Jeff Garzik <jgarzik@mandrakesoft.com>
MIME-Version: 1.0
Subject: Paging out sleepy processes?
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

I have a simple app that I run locally that allocates and randomly
dirties a lot of memory all at once, with the intention of forcing Linux
to swap out processes.

How possible/reasonable would it be to add a feature which will swap out
processes that have been asleep for a long time?

IMHO this behavior would default to off, but can be enabled by
specifying the age at which the system should attempt to swap out
processes:

	# tell kernel to swap out processes which have been asleep
	# longer than N seconds
	echo 7200 > /proc/sys/vm/min_sleepy_swap

Is there a way to do this already?

Regards,

	Jeff
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
