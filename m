Received: from user-112077u.dsl.mindspring.com ([66.32.28.254] helo=dublin)
	by blount.mail.mindspring.net with esmtp (Exim 3.33 #1)
	id 16tFNH-0003g2-00
	for linux-mm@kvack.org; Thu, 04 Apr 2002 17:06:31 -0500
Message-Id: <4.2.0.58.20020404140237.00b6c390@london.rubylane.com>
Date: Thu, 04 Apr 2002 14:06:20 -0800
From: Jim Wilcoxson <jim@rubylane.com>
Subject: 2.2.20 suspends everything then recovers during heavy I/O
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; format=flowed
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

I'm setting up a new system with 2.2.20, Ingo's raid patches, plus 
Hedrick's IDE patches.

When doing heavy I/O, like copying partitions between drives using tar in a 
pipeline, I've noticed that things will just stop for long periods of time, 
presumably while buffers are written out to the destination disk.  The 
destination drive light is on and the system is not exactly hung, because I 
can switch consoles and stuff, but a running vmstat totally suspends for 
10-15 seconds.

Any tips or patches that will avoid this?  If our server hangs for 15 
seconds, we're going to have tons of web requests piled up for it when it 
decides to wakeup...

Thanks for any advice you may have.  (I'm not on the mailing list BTW).

Jim
___________________________________________
Jim Wilcoxson, Owner
Ruby Lane Antiques, Collectibles & Fine Art
1.313.274.0788
http://www.rubylane.com 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
