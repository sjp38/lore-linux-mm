Received: from seoul.clic.cs.columbia.edu (IDENT:ME+r4OXvUT2jCOjpOjgobGnPDVeihDN6@seoul.clic.cs.columbia.edu [128.59.15.47])
	by cs.columbia.edu (8.12.9/8.12.9) with ESMTP id h7NH9n8J027332
	(version=TLSv1/SSLv3 cipher=EDH-RSA-DES-CBC3-SHA bits=168 verify=NOT)
	for <linux-mm@kvack.org>; Sat, 23 Aug 2003 13:09:50 -0400 (EDT)
Received: from seoul.clic.cs.columbia.edu (IDENT:Ut7EK6e3z+xpikfE9/7sJrCslLz9pwlJ@localhost [127.0.0.1])
	by seoul.clic.cs.columbia.edu (8.12.9/8.12.9) with ESMTP id h7NH9Q5Z016612
	for <linux-mm@kvack.org>; Sat, 23 Aug 2003 13:09:26 -0400
Received: from localhost (rra2002@localhost)
	by seoul.clic.cs.columbia.edu (8.12.9/8.12.9/Submit) with ESMTP id h7NH9QrL016608
	for <linux-mm@kvack.org>; Sat, 23 Aug 2003 13:09:26 -0400
Date: Sat, 23 Aug 2003 13:09:26 -0400 (EDT)
From: "Raghu R. Arur" <rra2002@cs.columbia.edu>
Subject: writepage functions
Message-ID: <Pine.LNX.4.44.0308231308420.16199-100000@seoul.clic.cs.columbia.edu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>



 Hi,

   I wanted to know whether all writepage functions of the address space
are blocking? I need to use it in a non-blocking context. When I followed
the code path of shmem_writepage, it was non-blocking, but ext2_writepage
I found to be blocking. Am I correct over here. Is there any other way of
writing a dirty page to the backing store without using writepage
function,  I mean can I use set_dirty_page() which inserts into the
dirty_list and gets written later ??

 Thanks a lot,
 Raghu

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
