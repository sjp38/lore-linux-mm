Received: from mn3 (helo=localhost)
	by os.inf.tu-dresden.de with local-esmtp (Exim 3.36)
	id 193GI8-000FfI-00
	for Linux-MM@kvack.org; Wed, 09 Apr 2003 16:11:08 +0200
Date: Wed, 9 Apr 2003 16:11:08 +0200 (DFT)
From: Mathias Noack <mn3@os.inf.tu-dresden.de>
Subject: page table entry 
Message-ID: <Pine.A41.4.10.10304091610290.113202-100000@os.inf.tu-dresden.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux-MM@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

does anybody know how i can exchange a page table entry (pte)?
the problem is i got a valid pte and i want set up a new page frame for
this pte and release the old page frame ... 
i only could find one solution for this: 
make the pte invalid and raise a pagefault with get_user_page where my
nopage function is use so i can decide which page should be mapped for
this particular pte.

is there any other maybe faster way? what about directly changing the page
table or copy one page frame into the other (very slow?) ?

thanks a lot for your help
Mathias



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
