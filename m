Received: from superbug.demon.co.uk ([80.176.146.252] helo=[192.168.1.10])
	by anchor-post-35.mail.demon.net with esmtp (Exim 4.42)
	id 1Ep2Jf-0008TI-Gz
	for linux-mm@kvack.org; Wed, 21 Dec 2005 11:39:31 +0000
Message-ID: <43A9409D.1010904@superbug.demon.co.uk>
Date: Wed, 21 Dec 2005 11:46:37 +0000
From: James Courtier-Dutton <James@superbug.demon.co.uk>
MIME-Version: 1.0
Subject: Possible cure for memory fragmentation.
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

There are two problems associated with memory fragmentation.
1) Identifying a memory fragment that one would really like to move if 
one could.
2) Actually moving the fragment.

This idea assumes that (1) has been identified, and this email explains 
how to do actually move the fragment (2).

I am suggesting we add a new memory allocation function into the kernel 
called kremalloc().

The purpose of any call to kremalloc() would mean that:
a) One really needs the memory already allocated, so don't loose it.
b) One does not mind if the memory location moves.

Now, the kernel driver module that has previously allocated a memory 
block, could at a time convenient to itself, allow the memory to be 
moved. It would simple call kremalloc() with the same size parameter as 
it originally called kmalloc(). The mm would then notice this, and then, 
if that location had been tagged with (1), the mm could then happily 
move it, and the kernel driver module would be happy. If it was not 
tagged with (1) the mm would simply return, so very little overhead.

I believe that this could be a very simple, yet painless way to 
implement memory defragmentation in the kernel. A similar method could 
be used for user land applications.

Any comments?

James

P.S. I though this topic was better for Linux-mm than LKML.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
