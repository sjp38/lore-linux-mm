Message-ID: <B1DF47D78E82D511832C00B0D021B520131A3D@SAKTHI>
From: Viju <viju@ctd.hcltech.com>
Subject: RE: can i call copy_to_user with interrupts masked
Date: Mon, 27 Aug 2001 20:39:18 +0530
MIME-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: PRASENJIT CHAKRABORTY <pras_chakra@yahoo.com>, linux-mm@kvack.org
Cc: arund@bellatlantic.net
List-ID: <linux-mm.kvack.org>

At a high level OS point of view that cannot be the cause
i would say.

When u access a page, the processor finds that the address is
not mapped in the page tables, it suspends the execution of the current
process and generates a page_fault. The OS is supposed to handle the
page_fault and it finds the corresponding page in the 
backing store and faults the page in. After a transaction entry is
made inthe page tables for the newly faulted in page, it returns.
The processor starts excuting the same statement at which it stopped
and the process resumes normal execution.

I would say find what do_page_fault is returning, it shud return an
error if it couldnt find the page for some reason.(Like illegal access or
couldnt swap the page in). If the page_fault is returning
error then finding out y it is retuning that error might solve ur problem.

Thnx,
Viju.

-----Original Message-----
From: PRASENJIT CHAKRABORTY [mailto:pras_chakra@yahoo.com]
Sent: Monday, August 27, 2001 8:27 PM
To: linux-mm@kvack.org
Cc: arund@bellatlantic.net
Subject: can i call copy_to_user with interrupts masked


Hello All,
     This is in continuation with my previous mail.
While debugging I've noticed that __copy_to_user()
fails when I stop the Bottom Half before the call to
__copy_to_user(), so if the page in not currently
mapped then it forbids do_page_fault() to get invoked
and hence the failure.

So I would like to know whether this hypothesis is
right or not? And if not then the possible
explanation.

Thankx

Prasenjit

__________________________________________________
Do You Yahoo!?
Make international calls for as low as $.04/minute with Yahoo! Messenger
http://phonecard.yahoo.com/
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
