Received: from ucla.edu (ts17-87.dialup.bol.ucla.edu [164.67.27.96])
	by caracal.noc.ucla.edu (8.9.1a/8.9.1) with ESMTP id KAA28082
	for <linux-mm@kvack.org>; Thu, 23 Aug 2001 10:55:29 -0700 (PDT)
Message-ID: <3B8543A6.1000904@ucla.edu>
Date: Thu, 23 Aug 2001 10:55:50 -0700
From: Benjamin Redelings I <bredelin@ucla.edu>
MIME-Version: 1.0
Subject: use-once & 'rescuing' pages from inactive-dirty
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hello Daniel and others,
	Firstly, I'd like to report that, with 2.4.9+SetPagReferenced+vma-merge, 
I can actually run mozilla on a 64Mb box while 'find' is running, which 
hasn't been true for a long time.  Previously, I could run netscape, 
somewhat, but mozilla wants an RSS of 25-35Mb as opposed to 10-15Mb so 
mozilla would just barely run.  I would get delays of minutes repainting 
pages and stuff while find was running, though mozilla worked fine when 
'find' wasn't running.
	So, maybe the use-once patch is actually working now.

	Now, this did NOT work with 2.4.9, but it requited the SetPageReferenced 
fix to work.  Daniel, you said that a SetPageReferenced, or something, 
needed to be added to a few other paths, to 'rescue' other types of 
pages before they got the end of the inactive-dirty list.
	a) if you make a patch, for these other places, I'd be glad to test it :)
	b) shouldn't the swap pages get referenced if they are used twice?  What 
makes swap pages, mmap pages, etc. different from normal file pages, so 
that they have to get 'rescued' with a SetPageReferenced?    Does the 
fact that swap pages need to be rescued imply that the inactive-dirty 
list really isn't long enough for use-once, in practice?  Does the 
performance increase perhaps come from having swapped-in pages have a 
higher PAGE_AGE_START (in a sense) than file pages?  Because that would 
give preference to 'mozilla' pages over 'find' pages, and explain why I 
can run mozilla...
	Anyway, just wondering.  Thanks!

-BenRI
-- 
"I will begin again" - U2, 'New Year's Day'
Benjamin Redelings I      <><     http://www.bol.ucla.edu/~bredelin/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
