Received: from rhino.thrillseeker.net (root@ci176196-a.grnvle1.sc.home.com [24.4.120.228])
	by kvack.org (8.8.7/8.8.7) with ESMTP id UAA01357
	for <linux-mm@kvack.org>; Mon, 7 Dec 1998 20:34:26 -0500
Message-ID: <366C8214.F58091FF@thrillseeker.net>
Date: Mon, 07 Dec 1998 20:34:12 -0500
From: Billy Harvey <Billy.Harvey@thrillseeker.net>
MIME-Version: 1.0
Subject: Re: [PATCH] swapin readahead and fixes
References: <199812041434.OAA04457@dax.scot.redhat.com>
		<Pine.LNX.3.95.981205102900.449A-100000@localhost> <199812071650.QAA05697@dax.scot.redhat.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Linux MM <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.rutgers.edu>
List-ID: <linux-mm.kvack.org>

Has anyone ever looked at the following concept?  In addition to a
swap-in read-ahead, have a swap-out write-ahead.  The idea is to use all
the avaialble swap space as a mirror of memory.  If a need for real
memory comes up, and a page has been marked as mirrored, then it can be
immediately reused without swapping out.  The trick would be in deciding
how to write-ahead without taking significant execution time and disk
access time away from other processes, that is with no impact to active
processes.  Now, if that page is needed back into memory, the
current/improved methods of reading in can also be followed.  In short,
we have information available to us that allows us to reduce time of
execution.  That information is that we have swap space available, and
disk access time avaialable (while nothing else needs it), and can make
use of that time.

Spears solicted.
-- 
Billy.Harvey@thrillseeker.net
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
