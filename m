Message-ID: <20041209105603.4725.qmail@web53908.mail.yahoo.com>
Date: Thu, 9 Dec 2004 02:56:03 -0800 (PST)
From: Fawad Lateef <fawad_lateef@yahoo.com>
Subject: Plzz help me regarding HIGHMEM (PAE) confusion in Linux-2.4 ???
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

I m confused with that how the kernel access highmem
through PAE. I know that kmap related functions do
that but when I saw what they do, I got to know that
they are just setting PTE according to already created
slot of pagetable. 

But as far as I understand from Intel's IA32 System
Programmer manual, due to linear address limit of
32bit we can't access more than 4GB from a single
process, and for above 4GB cr3 must be loaded with the
new PGD values so that the linear address of 32bits
can then access the other 4GB (4GB to 8GB) and for
every every 4GB till 64GB.

Now the kernel is using the pagetables for kmaps hav
PGD entry for accessing starting 4GB, but how it goes
beyond that ? 

Plzz explain me !!!!!


Thanks 

Fawad Lateef


		
__________________________________ 
Do you Yahoo!? 
Take Yahoo! Mail with you! Get it on your mobile phone. 
http://mobile.yahoo.com/maildemo 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
