Message-ID: <20030527214157.31893.qmail@web41501.mail.yahoo.com>
Date: Tue, 27 May 2003 14:41:57 -0700 (PDT)
From: Carl Spalletta <cspalletta@yahoo.com>
Subject: hard question re: swap cache
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Assume a shared, anonymous page is referenced by a set of
processes a,b,c,d,e and the page is marked present in the
page tables of each process.  Assume then that the page is
marked for swapout in the pagetables of 'a'. A swap slot is
filled with a copy of the page, but it is still present in
memory. As I understand it, it may still possible for b,c,d,e
to modify the page (since it is shared) and this is no problem
since there is no need to co-ordinate with the swapped out
page while the page usage counter is positive(if the system
decides to make the page present for a, it should simply
decrement the page slot counter but not bother with swapping
back since the page in memory is either an exact duplicate
or is newer than what is in the swap slot).

Then say b,c,d and e in that order have the page swapped out.
Either the page is copied to the page slot for each swapout
or it _must_ be copied on the last swap (when the page usage
counter goes to zero) else the modifications made by b,c,d,e
will be lost.

I can't decide which method is used and I can't find where in
the 2.5 code it occurs - can anyone help?
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
