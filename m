Received: from f03n07e.au.ibm.com
	by ausmtp01.au.ibm.com (IBM AP 1.0) with ESMTP id OAA203874
	for <linux-mm@kvack.org>; Thu, 30 Mar 2000 14:42:58 +1000
From: pnilesh@in.ibm.com
Received: from d73mta05.au.ibm.com (f06n05s [9.185.166.67])
	by f03n07e.au.ibm.com (8.8.8m2/8.8.7) with SMTP id OAA58936
	for <linux-mm@kvack.org>; Thu, 30 Mar 2000 14:45:22 +1000
Message-ID: <CA2568B2.001A16BB.00@d73mta05.au.ibm.com>
Date: Thu, 30 Mar 2000 10:07:09 +0530
Subject: page fault in cli / sti safe or not
Mime-Version: 1.0
Content-type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

     I tried to page fault in cli () / sti() , but there was no deadlock. I
had perception that a deadlock would occur. However what might have I now
believe is that age fault always ocuur in any processes context , they will
panic in interrupt handler. So when a page fault occurs the page fault
handler is called and if the page is not found in the memory then a disk
read is scheduled the faulting process is put to sleep and  schedule() is
called to run new process. The schedule () implicitly calls sti() and hence
there is no deadlock.

     Please correct me if I am wrong.


Nilesh Patel
IBM Global Services India Pvt. Ltd.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
