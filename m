Received: from [192.168.0.105] (lin5.shipmail.org [192.168.0.105])
	by lin5.shipmail.org (Postfix) with ESMTP id 169153565B6
	for <linux-mm@kvack.org>; Mon,  9 Oct 2006 17:21:14 +0200 (CEST)
Message-ID: <452A68E9.3000707@tungstengraphics.com>
Date: Mon, 09 Oct 2006 17:21:13 +0200
From: Thomas Hellstrom <thomas@tungstengraphics.com>
MIME-Version: 1.0
Subject: Driver-driven paging?
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi!

While trying to put together an improved graphics memory manager in the 
DRM kernel module, I've identified a need to swap out backing store 
pages which haven't been in use for a while, and I was wondering if 
there is a kernel mm API to do that?

Basically when a graphics object is created, space is allocated either 
in on-card video RAM or in a backup object in system RAM. That backup 
object can optionally be flipped into the AGP aperture for fast and 
linear graphics card access.

What I want to do is to be able to release backup object pages while 
maintaining the contents. Basically hand them over to the swapping 
system and get a handle back that can be used for later retrieval. The 
driver will unmap all mappings referencing the page before handing it 
over to the swapping system.

Is there an API for this and is there any chance of getting it exported?

Regards,
Thomas

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
