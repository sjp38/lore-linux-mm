Received: from f03n05e
	by ausmtp01.au.ibm.com (IBM AP 1.0) with ESMTP id UAA81630
	for <linux-mm@kvack.org>; Wed, 12 Apr 2000 20:12:05 +1000
From: pnilesh@in.ibm.com
Received: from d73mta05.au.ibm.com (f06n05s [9.185.166.67])
	by f03n05e (8.8.8m2/8.8.7) with SMTP id UAA24660
	for <linux-mm@kvack.org>; Wed, 12 Apr 2000 20:17:08 +1000
Message-ID: <CA2568BF.00387B64.00@d73mta05.au.ibm.com>
Date: Wed, 12 Apr 2000 15:37:37 +0530
Subject: page->offset
Mime-Version: 1.0
Content-type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This is related to 2.2.x


One of the comment in mm.h says that we can have more than one copy of some
page of an executable or shared lib (not normally).

Does it have to do something with offet field in page structure ?
Does it mean that it may happen becoz offset field is not guarenteed to be
PAGE_SIZE aligned  ?

Nilesh Patel


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
