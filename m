Received: from f03n07e.au.ibm.com
	by ausmtp02.au.ibm.com (IBM AP 1.0) with ESMTP id SAA184538
	for <linux-mm@kvack.org>; Tue, 18 Apr 2000 18:23:48 +1000
From: pnilesh@in.ibm.com
Received: from d73mta05.au.ibm.com (f06n05s [9.185.166.67])
	by f03n07e.au.ibm.com (8.8.8m2/8.8.7) with SMTP id SAA36240
	for <linux-mm@kvack.org>; Tue, 18 Apr 2000 18:28:21 +1000
Message-ID: <CA2568C5.002E89C4.00@d73mta05.au.ibm.com>
Date: Tue, 18 Apr 2000 13:50:20 +0530
Subject: Re: preemp / nonpreemp
Mime-Version: 1.0
Content-type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Eric W. Biederman" <"ebiederm+eric"@ccr.net>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

  Using the architecture it is also possible
to prempt kernel threads that don't hold the big kernel lock on
non-SMP systems as well.

 Does it mean that I can go and write schedule () in the kernel and it
should             not create any problems ?/* not in handler */

  non-SMP premption probably won't appear until
early 2.5 however as it may have a few complications.

Can you tell me any complication ?

Nilesh


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
