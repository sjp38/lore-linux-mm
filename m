Received: from shaolinmicro.com (localhost.localdomain [127.0.0.1])
	by host1.home.shaolinmicro.com (8.11.6/8.11.6) with ESMTP id g59Eqk409129
	for <linux-mm@kvack.org>; Sun, 9 Jun 2002 22:52:47 +0800
Message-ID: <3D036BBE.4030603@shaolinmicro.com>
Date: Sun, 09 Jun 2002 22:52:46 +0800
From: David Chow <davidchow@shaolinmicro.com>
MIME-Version: 1.0
Subject: slab cache
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Dear all,

I am trying to improve the speed of my fs code. I have a fixed sized 
buffer for my fs, I currently use kmalloc for allocation of buffers 
greater than 4k, use get_free_page for 4k buffers and vmalloc for large 
buffers. Is there any benefits using the slab cache? If so whats the 
difference of using slab cache than kmalloc? Thanks for comments.

regards,
David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
