Message-ID: <1069943731.3fc60bb3ac896@webmail.technion.ac.il>
Date: Thu, 27 Nov 2003 16:35:31 +0200
From: sygalula@t2.technion.ac.il
Subject: compression of swap pages
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hello,

I'm working on a student's project. currently trying to modify swap file
contents (in order to try compressing them later).

I'm trying to change the pages being written to the swap file (via xor) and
change them back, after reading them (via same xor).

While writing a page to the swap, in rw_swap_page(), I mark the page with a flag
so that in rw_swap_page_base(), I would know to change it(xor).

While reading a page from the swap, in rw_swap_page(), I mark the page with a
flag, so that in end_buffer_io_async() I would know to change it back(xor).

The system crashes - so obviously, I'm missing something here...

Would really appriciate help...

Yaron Galula
sygalula@t2.technion.ac.il
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
