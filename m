Received: from UNIX43.andrew.cmu.edu (UNIX43.andrew.cmu.edu [128.2.13.173])
	(user=aeswaran mech=GSSAPI (0 bits))
	by smtp3.andrew.cmu.edu (8.12.10/8.12.10) with ESMTP id i21KRHir013511
	for <linux-mm@kvack.org>; Mon, 1 Mar 2004 15:27:17 -0500
Date: Mon, 1 Mar 2004 15:27:15 -0500 (EST)
From: Anand Eswaran <aeswaran@andrew.cmu.edu>
Subject: writepage  
Message-ID: <Pine.LNX.4.58-035.0403011136250.2281@unix43.andrew.cmu.edu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi :

  I have quick question reg Linux 2.4.18, Ive tried to understand the code
but am pretty confused:

  In the typical malloc execution-path,  the page is added to swap and it's
pte_chain is unmapped  after which the writepage() is executed.  However I
notice that *after* the writepage(), the page->buffers is NON_NULL.

  Is this supposed to happen? I thought the writepage function flushed the
page to swap, so why are there residual buffers?

Thanks,
----
Anand.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
