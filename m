Received: from f03n07e
	by ausmtp01.au.ibm.com (IBM AP 1.0) with ESMTP id XAA155476
	for <linux-mm@kvack.org>; Wed, 12 Apr 2000 23:08:11 +1000
From: pnilesh@in.ibm.com
Received: from d73mta05.au.ibm.com (f06n05s [9.185.166.67])
	by f03n07e (8.8.8m2/8.8.7) with SMTP id XAA27898
	for <linux-mm@kvack.org>; Wed, 12 Apr 2000 23:13:15 +1000
Message-ID: <CA2568BF.00489645.00@d73mta05.au.ibm.com>
Date: Wed, 12 Apr 2000 18:34:21 +0530
Subject: Re: page->offset
Mime-Version: 1.0
Content-type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>



To have your views,

If a file is opened and from an offset which is not page aligned say from
offset 10.
When we read this file into the memory page ,where the first byte will be
loaded into the memory ?
In 2.2 the first byte of the page will be the 10th byte of the file.
In 2.3 the first byte will be first byte in the file and 10th byte is the
10th in the file.

This is what I feel.

Nilesh

Correct.  There are some very old binary formats in which the pages
of the executable are not page-aligned.  2.2 still supports them
and allows such binaries to be non-aligned in cache, but there is
no guarantee of cache coherency on such mappings and they are no
longer supported in 2.3.

--Stephen



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
