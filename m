Received: from gazeta.pl (unknown [195.117.141.11])
	by dgt-lab.com.pl (Postfix) with ESMTP id 22CA51B24D
	for <linux-mm@kvack.org>; Thu,  9 Oct 2003 10:58:25 +0200 (CEST)
Message-ID: <3F85232E.6090604@gazeta.pl>
Date: Thu, 09 Oct 2003 10:58:22 +0200
From: Kromer <krom@gazeta.pl>
MIME-Version: 1.0
Subject: framebuffer mmap
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

hello mm-everybody	

i'm just writing my own framebuffer driver for device acessed only via 
parallel port (there is no way to direct read/write it's memory)

i just want to use memory allocated in kernel module, and acess it 
application with mmmap (and of course flush this memory to device 
peridicaly)

q1: where is documentation of writing own mmap  functions
q2: what fields need to be set in  mmap function implementation
q3: what kind of memory allocation i should use inside driver
      (kmalloc, vmalloc, with GFP_KERNEL or FGP_USER?)
q4: how to remap (or not?) in mmap function

q5: is there any simply way to build acess for non-direct memory ?
     i mean for each byte read/write to this
     memory need to be called my own function

please answer to my priv (mailto:krom@gazeta.pl) too
thx

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
