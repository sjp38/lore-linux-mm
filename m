Received: from ns-ca.netscreen.com (ns-ca.netscreen.com [10.100.10.21])
	by mail.netscreen.com (8.10.0/8.10.0) with ESMTP id f4IHYQA26159
	for <linux-mm@kvack.org>; Fri, 18 May 2001 10:34:26 -0700
Message-ID: <A33AEFDC2EC0D411851900D0B73EBEF766DCD9@NAPA>
From: Hua Ji <hji@netscreen.com>
Subject: About swapper_page_dir and processes' page directory
Date: Fri, 18 May 2001 10:47:48 -0700
MIME-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Folks,

Get a question today. Thanks in advance.

As we know, vmalloc and other memory allocation/de-allocation will
change/update
the swapper_page_dir maintain by the kernel. 

I am wondering when/how the kernel synchronzie the change to user level
processes' page
directory entries from the 768th to the 1023th.

Those entries get copied from swapper_page_dir when a user process get
forked/created. Does the kernel
frequently update this information every time when the swapper_page_dir get
changed?

Regards,

Mike
 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
