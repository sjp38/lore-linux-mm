Received: by rproxy.gmail.com with SMTP id a36so119962rnf
        for <linux-mm@kvack.org>; Wed, 02 Feb 2005 11:13:16 -0800 (PST)
Message-ID: <89c400ad05020211131c62ccc6@mail.gmail.com>
Date: Thu, 3 Feb 2005 00:43:16 +0530
From: Krishnakumar R <rkrishnakumar@gmail.com>
Reply-To: Krishnakumar R <rkrishnakumar@gmail.com>
Subject: Query on vma and User mode Stack
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi All,

I was trying to figure out the connections between vma's and user stack
segment.

I compiled  a C program in which I printed the address of a local variable
(under the assumption that it fall into the stack segment address).
The address which got printed was '0x9ffffc74'. (this is 386 based machine).

I printed out the start_stack from the mm_struct of the process.
I got the value: '0x9ffffec0'. There were 5 vmas for the process of which
the 5th vma started at 0x9ffff000 and ended at 0xa0000000.

Considering the vma address, I feel that stack segment falls into
this area. Also 0x9ffffec0 >0x9ffffc74, means that the stack grew down.
But then shouldn't the stack segment start from the end of the vma (near
0xa0000000 ?

I have heard that user stack growth happens dynamically. Is this the 
manifestation of such a case (when the the space fully is required
stack will start from the end of the vma) ?

Thanks and Regards,
KK.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
