Received: from f03n07e.au.ibm.com
	by ausmtp01.au.ibm.com (IBM AP 1.0) with ESMTP id NAA76890
	for <linux-mm@kvack.org>; Tue, 28 Mar 2000 13:54:05 +1000
From: pnilesh@in.ibm.com
Received: from d73mta05.au.ibm.com (f06n05s [9.185.166.67])
	by f03n07e.au.ibm.com (8.8.8m2/8.8.7) with SMTP id NAA25152
	for <linux-mm@kvack.org>; Tue, 28 Mar 2000 13:58:57 +1000
Message-ID: <CA2568B0.0015D747.00@d73mta05.au.ibm.com>
Date: Tue, 28 Mar 2000 09:20:57 +0530
Mime-Version: 1.0
Content-type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

     When a executable file runs there is only one copy of the text part in
the memory. But I have some doubts as I am not able to figure how exactly
this is done.

Suppose a text page of an executable is mapped in the address space of 2
processes. The page count will be one.
The page table entries of both the process will have entry for this page.
But when the page is discarded only the page entry of only one process get
cleared , this is what I have understood from the swap_out () function .
But the page table entry of the other process is still pointing to the page
which has been discarded.


Can any body please clear my doubt.


Q    When a page of a file is in page hash queue, does this page have page
table entry in any process ?
Q     Can this be discarded right away , if the need arises?


Nilesh Patel


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
