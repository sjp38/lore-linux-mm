Received: from f03n05e
	by ausmtp02.au.ibm.com (IBM AP 1.0) with ESMTP id VAA104100
	for <linux-mm@kvack.org>; Thu, 13 Apr 2000 21:22:45 +1000
From: pnilesh@in.ibm.com
Received: from d73mta05.au.ibm.com (f06n05s [9.185.166.67])
	by f03n05e (8.8.8m2/8.8.7) with SMTP id VAA62828
	for <linux-mm@kvack.org>; Thu, 13 Apr 2000 21:27:28 +1000
Message-ID: <CA2568C0.003EEBAF.00@d73mta05.au.ibm.com>
Date: Thu, 13 Apr 2000 16:49:11 +0530
Subject: Re: page->offset
Mime-Version: 1.0
Content-type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Odd, it should't.  Which kernel is this?
cat /proc/version shows  2.2.5-15

>         char *p = mmap (NULL,10,PROT_READ,MAP_SHARED,fd,1024);
>         char *s = mmap (NULL,10,PROT_READ,MAP_SHARED,fd,1024);

strace shows:

  old_mmap(NULL, 10, PROT_READ, MAP_SHARED, 3, 0x400) = -1 EINVAL (Invalid
argument)
  old_mmap(NULL, 10, PROT_READ, MAP_SHARED, 3, 0x400) = -1 EINVAL (Invalid
argument)

on a 1k blocksize filesystem.

> Does these virtual addresses point to only one physical page ?
> This page is in the page cache if I am not wrong with page->count = 3 ?
> (2.2.x)

Correct.

> If I do read () from 1024 offset the data I will get will be from the
above
> phyiscal page or from .... ?

read() _always_ invokes the page cache with pagesize-aligned
page offsets.  If a correctly aligned page is not present, a new one
will be created.


Nilesh


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
