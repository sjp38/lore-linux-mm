Received: from lectura.CS.Arizona.EDU (lectura.cs.arizona.edu [192.12.69.186])
	by cheltenham.cs.arizona.edu (8.12.8p2/8.12.8) with ESMTP id hA80Zk4J034588
	for <linux-mm@kvack.org>; Fri, 7 Nov 2003 17:35:46 -0700 (MST)
	(envelope-from sku@CS.Arizona.EDU)
Received: from lectura.CS.Arizona.EDU (localhost [127.0.0.1])
	by lectura.CS.Arizona.EDU (8.12.8+Sun/8.12.2) with ESMTP id hA80ZkNJ008173
	for <linux-mm@kvack.org>; Fri, 7 Nov 2003 17:35:46 -0700 (MST)
Received: from localhost (sku@localhost)
	by lectura.CS.Arizona.EDU (8.12.8+Sun/8.12.2/Submit) with ESMTP id hA80ZkSe008170
	for <linux-mm@kvack.org>; Fri, 7 Nov 2003 17:35:46 -0700 (MST)
Date: Fri, 7 Nov 2003 17:35:46 -0700 (MST)
From: Sharath Kodi Udupa <sku@CS.Arizona.EDU>
Subject: linux vm page sharing
Message-ID: <Pine.GSO.4.58.0311071728220.12831@lectura.CS.Arizona.EDU>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

hi,

i am trying to implement a system where different processes can share
pages, this means that not only same executables, but different
executables , but when the pages required are same.
but i see in the linux page structure, it keeps a pointer to the
address_space mapping, but now since if the second process also needs to
share the page,this wont be the same mapping. so i am planning to add the
page table entry to the second process, but to leave the
struct address_space *mapping pointer to whatever it was earlier. I plan
to do this since, i dont really understand how this is used and also have
gone through the code to understand it. What significance does this hold?

any pointers is greatly appreciated

regards,

Sharath K Udupa
Graduate Student,
Dept. of Computer Science,
University of Arizona.
sku@cs.arizona.edu
http://www.cs.arizona.edu/~sku

"Sometimes I think the surest sign that intelligent life exists
elsewhere in the universe is that none of it has tried to contact us."
--Calvin, The Indispensable Calvin and Hobbes


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
