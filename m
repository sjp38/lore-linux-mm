Message-ID: <20030527230406.4286.qmail@web41505.mail.yahoo.com>
Date: Tue, 27 May 2003 16:04:06 -0700 (PDT)
From: Carl Spalletta <cspalletta@yahoo.com>
Subject: Re: hard question re: swap cache
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

I thought of a simple example. Suppose processes a,b,c
have a shared, anonymous page.  All processes have this page
present.  Then the page for a is swapped out.  Then b and c
exit unexpectedly, after making changes to the page.  When
and if 'a' has the page swapped back in, what mechanism
guarantees that it will see the changes made by b and c?
Where specifically in the code, in what functions, does it
reside for kernel 2.5?
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
