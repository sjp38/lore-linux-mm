Received: from imperial.edgeglobal.com (imperial.edgeglobal.com [208.197.226.14])
	by edgeglobal.com (8.9.1/8.9.1) with ESMTP id MAA06021
	for <linux-mm@kvack.org>; Thu, 21 Oct 1999 12:27:22 -0400
Date: Thu, 21 Oct 1999 12:31:25 -0400 (EDT)
From: James Simmons <jsimmons@edgeglobal.com>
Subject: page faults
Message-ID: <Pine.LNX.4.10.9910211229110.32615-100000@imperial.edgeglobal.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>


Quick question. If two processes are sharing the same memory but no page
fault has happened. THen process A causes a page fault. If process B tries
to access the page that process A already page fault will process B cause
another page fault. Or do page faults only happen once no matter how many
process access it. 

"We've all heard that a million monkeys banging on a million typewriters
 will eventually reproduce the entire works of Shakespeare. Now,
 thanks to the Internet, we know this is not true."

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
