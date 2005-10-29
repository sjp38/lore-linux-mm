Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e33.co.us.ibm.com (8.12.11/8.12.11) with ESMTP id j9T0aFGl030816
	for <linux-mm@kvack.org>; Fri, 28 Oct 2005 20:36:15 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.12.10/NCO/VERS6.7) with ESMTP id j9T0bFEf536708
	for <linux-mm@kvack.org>; Fri, 28 Oct 2005 18:37:15 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id j9T0aEOf012310
	for <linux-mm@kvack.org>; Fri, 28 Oct 2005 18:36:14 -0600
Subject: Re: [RFC] madvise(MADV_TRUNCATE)
From: Badari Pulavarty <pbadari@us.ibm.com>
In-Reply-To: <200510282040.29856.blaisorblade@yahoo.it>
References: <1130366995.23729.38.camel@localhost.localdomain>
	 <200510281303.56688.blaisorblade@yahoo.it> <43624EE6.8000605@us.ibm.com>
	 <200510282040.29856.blaisorblade@yahoo.it>
Content-Type: text/plain
Date: Fri, 28 Oct 2005 17:35:45 -0700
Message-Id: <1130546145.23729.170.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Blaisorblade <blaisorblade@yahoo.it>
Cc: Jeff Dike <jdike@addtoit.com>, Hugh Dickins <hugh@veritas.com>, akpm@osdl.org, andrea@suse.de, dvhltc@us.ibm.com, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, 2005-10-28 at 20:40 +0200, Blaisorblade wrote:

> 
> All ok for that, I was complaining about not using ->vm_pgoff.
> 
> I had the doubt that vm_pgoff entered the picture later, but I'm sure 
> truncate_inode_pages{_range} wants file offsets, so it wasn't something I was 
> missing.

Yep. You are right on -- Jeff's UML problem is due to not handling
vm_pgoff correctly. I was able to reproduce the problem 
(Thank you Jeff for the testcase with instructions).

call vmtruncate_range(ffff81011fec0ff8, a7e3000 a7e4000) pgoff:259

I need to think what I need to do with ->vm_pgoff, before I hack
up something.

Thanks,
Badari


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
