Subject: Re: Oops in __free_pages_ok (pre7-1) (Long)
References: <Pine.LNX.4.21.0005022355140.1677-100000@alpha.random>
From: "Juan J. Quintela" <quintela@fi.udc.es>
In-Reply-To: Andrea Arcangeli's message of "Wed, 3 May 2000 00:02:05 +0200 (CEST)"
Date: 03 May 2000 00:13:27 +0200
Message-ID: <yttn1m8zjlk.fsf@vexeta.dc.fi.udc.es>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: Linus Torvalds <torvalds@transmeta.com>, linux-mm@kvack.org, Kanoj Sarcar <kanoj@google.engr.sgi.com>
List-ID: <linux-mm.kvack.org>

>>>>> "andrea" == Andrea Arcangeli <andrea@suse.de> writes:

Hi

>> If you want the patch for get rid of PG_swap_entry, I can do it and send
>> it to you.

andrea> The PG_swap_entry isn't going to be the problem. However if you fear about
andrea> it try out this patch on top of 2.3.99-pre6. If PG_swap_entry is the
andrea> problem you'll get your problem fixed.

Andrea, I have done basically the same patch (see my post to the list
yesterday),  I commented the line that set the PG_swap_entry bit.  (My
patch has the same net effect).  And now my systems don't crash, I
don't trigger more BUGS. 


andrea> Just a thought, do you use NFS? If so please give a try without NFS
andrea> filesystem mounted. I should have addressed the NFS troubles in my current
andrea> tree but it's still under testing.

Yes, I use NFS, but all the test has been done in ext2 local
file systems.  I had at that time mounted NFS partitions, but I was not
using them, make that any difference?

Later, Juan.


-- 
In theory, practice and theory are the same, but in practice they 
are different -- Larry McVoy
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
