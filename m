Received: from penguin.e-mind.com (penguin.e-mind.com [195.223.140.120])
	by kvack.org (8.8.7/8.8.7) with ESMTP id SAA25375
	for <linux-mm@kvack.org>; Thu, 1 Apr 1999 18:54:42 -0500
Date: Fri, 2 Apr 1999 01:32:00 +0200 (CEST)
From: Andrea Arcangeli <andrea@e-mind.com>
Subject: [patch] arca-vm-2.2.5
Message-ID: <Pine.LNX.4.05.9904020120200.2057-100000@laser.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
Cc: Chuck Lever <cel@monkey.org>, "Stephen C. Tweedie" <sct@redhat.com>
List-ID: <linux-mm.kvack.org>

Well in the last days I had new design ideas on the VM (I mean
shrink_mmap() and friends). I finished implementing them and the result
looks like impressive under heavy VM load.

I would like if people that runs linux under high VM load would try it out
my new VM code.

	ftp://e-mind.com/pub/linux/arca-tree/2.2.5_arca2.gz

If you try it out please feedback...

Thanks!

Andrea Arcangeli

--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
