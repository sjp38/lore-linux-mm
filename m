Received: from htec.demon.co.uk ([62.252.183.12]) by mta05-svc.ntlworld.com
          (InterMail vM.4.01.03.00 201-229-121) with ESMTP
          id <20011018155428.FBPX28993.mta05-svc.ntlworld.com@htec.demon.co.uk>
          for <linux-mm@kvack.org>; Thu, 18 Oct 2001 16:54:28 +0100
Message-ID: <3BCEFC46.9E8FEF7A@htec.demon.co.uk>
Date: Thu, 18 Oct 2001 16:59:02 +0100
From: Christopher Quinn <cq@htec.demon.co.uk>
MIME-Version: 1.0
Subject: mmap and raw disk devices...
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hello list,

I tried to mmap a disk partition raw device which failed.
Can anyone tell me the reason mmap does not support such a
device? 
I would have thought a mmap/raw-device combination to be ideal as
a basis for a high performance database system.
I know there is the option of managing memory<->disk movements
oneself, but my understanding is that handling page-faults via
signal trap handling is *very* expensive. Far better to leave
such matters in the hands of the OS.

I suspect there is some fundamental reason for not mmap'ing raw
devices that is patently obvious to everyone but me! 

Thanks,
Chris Quinn
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
