Received: from pbn-computer (k1ms075.dial.kabelfoon.nl [212.136.90.75])
	by maillist.kabelfoon.nl (Postfix) with SMTP id CA6A93AB2
	for <linux-mm@kvack.org>; Tue, 20 Jul 1999 12:24:18 +0200 (CEST)
Message-ID: <006501bed29a$dd39c5a0$4b5a88d4@pbn-computer>
From: "Lennert Buytenhek" <buytenh@dsv.nl>
Subject: some dumb questions
Date: Tue, 20 Jul 1999 12:30:17 +0200
MIME-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi all,

Some dumb questions from a dumb person..

In vm_operations_struct there are pointers for (*advise), (*nopage),
(*wppage), et cetera. wppage is never used or called by any code
(copy-on-write is the default behaviour). Why is this? What if I want
my own wppage handler? Having the fn ptr member but not using it
doesn't make sense, IMHO. Also, I believe (*advise) isn't used
either.

Some other small things:
1. struct vm_area_struct -> struct vm_area ?
2. struct vm_operations_struct -> struct vm_area_operations ?
3. /dev/sysvipc/shm/1234 or /proc/sysvipc/shm/1234 ??

(This last suggestion just might start a holy war.... :-)

Thanks,

Lennert Buytenhek
<buytenh@dsv.nl>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
