Received: from f03n07e.au.ibm.com
	by ausmtp02.au.ibm.com (IBM AP 1.0) with ESMTP id SAA227706
	for <linux-mm@kvack.org>; Tue, 28 Mar 2000 18:59:22 +1000
From: pnilesh@in.ibm.com
Received: from d73mta05.au.ibm.com (f06n05s [9.185.166.67])
	by f03n07e.au.ibm.com (8.8.8m2/8.8.7) with SMTP id TAA38626
	for <linux-mm@kvack.org>; Tue, 28 Mar 2000 19:03:49 +1000
Message-ID: <CA2568B0.002E6B38.00@d73mta05.au.ibm.com>
Date: Tue, 28 Mar 2000 13:49:04 +0530
Subject: Re: your mail
Mime-Version: 1.0
Content-type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kanoj Sarcar <kanoj@google.engr.sgi.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>




No, if both processes have faulted in the page into their ptes, it will
be 2. The page count is normally the number of references from user
ptes, plus any long/short term holds kernel code establishes on the
page.

I was confused as Maurice Bach increases region reference count when any
region say text is shared among more than one processes, and not the page
reference count.

One more thing if the process ocurrs a page fault on text page it calls
file_no_page()
>From what you said in this case it should increment the page count but in
this function no where I could see the page count getting incremented.


>
> Q    When a page of a file is in page hash queue, does this page have
page
> table entry in any process ?

Possibly, if the file is mmaped into some other process.

> Q     Can this be discarded right away , if the need arises?
>
At the minimum, you need to write modified contents back to disk, if
the file page has not already been discarded.

The David Rusling book says when reducing page cache and buffer cache the
page table entries are not modified and the pages can be dropped directly.

Kanoj

> Nilesh Patel
>
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux.eu.org/Linux-MM/
>




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
