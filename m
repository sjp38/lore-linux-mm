Message-ID: <3BCA2015.5080306@ucla.edu>
Date: Sun, 14 Oct 2001 16:30:29 -0700
From: Benjamin Redelings I <bredelin@ucla.edu>
MIME-Version: 1.0
Subject: VM question: side effect of not scanning Active pages?
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hello,
	In both Andrea and Rik's VM, I have tried modifying try_to_swap_out so
that a page would be skipped if it is "active".  For example, I have
currently modified 2.4.13-pre2 by adding:

          if (PageActive(page))
                  return 0;

after testing the hardware referenced bit.  This was motivated by
sections of VM-improvement patches written by both Rik and Andrea.
	This SEEMS to increase performance, but it has another side effect.  The
RSS of unused daemons no longer EVER drops to 4k, which it does without
this modification.  The RSS does decrease (usually) to the value of
shared memory, but the amount of shared memory only gets down to about
200-300k instead of decreasing to 4k.
	Can anyone tell me why not scanning Active page for swapout would have
this effect?  Thanks!

-BenRI
-- 
"I will begin again" - U2, 'New Year's Day'
Benjamin Redelings I      <><     http://www.bol.ucla.edu/~bredelin/


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
