Received: from issun5.hti.com ([130.210.202.3]) by issun6.hti.com
          (Netscape Messaging Server 3.6)  with ESMTP id AAA51D9
          for <linux-mm@kvack.org>; Mon, 30 Apr 2001 12:50:22 -0500
Received: from link.com ([130.210.5.51]) by issun5.hti.com
          (Netscape Messaging Server 3.6)  with ESMTP id AAA6531
          for <linux-mm@kvack.org>; Mon, 30 Apr 2001 13:17:27 -0500
Message-ID: <3AEDAC29.40309@link.com>
Date: Mon, 30 Apr 2001 14:17:13 -0400
From: "Richard F Weber" <rfweber@link.com>
MIME-Version: 1.0
Subject: Hopefully a simple question on /proc/pid/mem
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hopefully this is a simple question.  I'm trying to work on an external 
debugger that can bind to an external process, and open up memory 
locations on the heap to allow reading of data.

Now I've tried using ptrace(), mmap() & lseek/read all with no success.  
The closest I've been able to get is to use ptrace() to do an attach to 
the target process, but couldn't read much of anything from it.  Plus 
I've seen tons of conflicting reports saying that each on is the best, 
and the other two are deprecated.

So what I'd appreciate help in is:

1) Which approach to use?
2) Maybe a sample program that lets me read address 0x8000000 from 
another process.  I know this address is an integer, but I can't ever 
mmap, read or do a PEEKDATA on it.


Thanks in Advance to any pointers or help you can provide.I can provide 
sample code to stuff I've tried, or any other information if it will 
help.  Thanks.

--Rich

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
