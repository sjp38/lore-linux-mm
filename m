Received: from superbug.demon.co.uk ([80.176.146.252] helo=[192.168.1.10])
	by anchor-post-35.mail.demon.net with esmtp (Exim 4.42)
	id 1EdRzy-000Eyj-Hs
	for linux-mm@kvack.org; Sat, 19 Nov 2005 12:39:18 +0000
Message-ID: <437F1E7F.40504@superbug.demon.co.uk>
Date: Sat, 19 Nov 2005 12:45:51 +0000
From: James Courtier-Dutton <James@superbug.demon.co.uk>
MIME-Version: 1.0
Subject: Kernel tempory memory alloc
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

I am going to implement an IOCTL for a particular driver.
Previously I might have used the stack to store the request/response in 
while using copy_to/from_user, but with the 4K stack limit, I must 
consider other alternatives.
The IOCTL will be a simple request/response type, so the memory 
allocation will be for a very short time. Which is the correct memory 
api to use when allocating short term temporary memory in the kernel.
Alternatively, is there a way to handle this by simply moving a page 
from user space to kernel space and then back to user space again?
Thus reducing the amount of memcpy.

James

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
