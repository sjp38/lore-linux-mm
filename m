Message-ID: <20010827145640.79597.qmail@web14201.mail.yahoo.com>
Date: Mon, 27 Aug 2001 07:56:40 -0700 (PDT)
From: PRASENJIT CHAKRABORTY <pras_chakra@yahoo.com>
Subject: can i call copy_to_user with interrupts masked
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: arund@bellatlantic.net
List-ID: <linux-mm.kvack.org>

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
