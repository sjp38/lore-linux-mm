Received: from sierra.seas.upenn.edu (root@SIERRA.SEAS.UPENN.EDU [130.91.6.63])
	by kvack.org (8.8.7/8.8.7) with ESMTP id LAA00154
	for <linux-mm@kvack.org>; Tue, 18 Aug 1998 11:31:37 -0400
Received: from blue.seas.upenn.edu (vladimid@BLUE.SEAS.UPENN.EDU [130.91.5.148])
          by sierra.seas.upenn.edu (8.8.5/8.8.4) with ESMTP
	  id LAA03084 for <linux-mm@kvack.org>; Tue, 18 Aug 1998 11:30:59 -0400 (EDT)
Received: (from vladimid@localhost)
          by blue.seas.upenn.edu (8.8.5/8.8.4)
	  id LAA23097 for linux-mm@kvack.org; Tue, 18 Aug 1998 11:30:59 -0400 (EDT)
Message-Id: <199808181530.LAA23097@blue.seas.upenn.edu>
Subject: VFS buffer monitoring 
Date: Tue, 18 Aug 1998 11:30:59 -0400 (EDT)
From: "Vladimir Dergachev" <vladimid@seas.upenn.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

   Hello all :)
    I want to write a program that lists the blocks currently in VFS buffer.
 I looked around and couldn't find anything similar, and, well, noone on IRC
 seems to know anything about it.
    So here goes :
      1) does anybody know of such a program ? 
      2) I looked around in the kernel source and it looks to me that 
         this stuff isn't visible outside of kernel.. So should I just go
         and change kernel directly or can I still get by with writing a 
         module ? (or maybe even better , just an ordinary program ? )
      
      
 I would appreciate very much any pointers (and especially commentary) on the 
 subject..
 
                        Vladimir Dergachev
 
                        http://www.math.upenn.edu/~vdergach
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
