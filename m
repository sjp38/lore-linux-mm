Received: from sd0208e0.au.ibm.com (d23rh904.au.ibm.com [202.81.18.202])
	by ausmtp02.au.ibm.com (8.12.10/8.12.9) with ESMTP id hB93wZfH075960
	for <linux-mm@kvack.org>; Tue, 9 Dec 2003 14:58:38 +1100
Received: from d23m0178.in.ibm.com (d23av02.au.ibm.com [9.190.250.243])
	by sd0208e0.au.ibm.com (8.12.9/NCO/VER6.6) with ESMTP id hB93wXtY056198
	for <linux-mm@kvack.org>; Tue, 9 Dec 2003 14:58:37 +1100
Subject: page->virtual is null
Message-ID: <OF5E202F35.C2DE075B-ON65256DF7.0015AF55@in.ibm.com>
From: Vinod K Suryan <visuryan@in.ibm.com>
Date: Tue, 9 Dec 2003 09:29:12 +0530
MIME-Version: 1.0
Content-type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>




Hi,
      I am using SMP machine with 256 MB Ram. I am using kmap function in
my application it is returning NULL value.

      Here is some log

      highmem_start_page = c13bf8ac
      page address is =    c132a194

      but after kmap i am getting readpage:kmap address is NULL=0

      here kmap is returning page->virtual which value is NULL

      after that i am getting badaddress error.

      but same code is working fine in uni-processor. i am getting

      i am using 2.4.21-4.EL kernel ..

      please help me..
      i am not geting wht to do..?

Thanks
Vinod Suryan

_________________________
IBM India Software Labs, Pune.
Ph:91-20-4041385
Email: visuryan@in.ibm.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
