Message-ID: <20030623091214.5259.qmail@web13608.mail.yahoo.com>
Date: Mon, 23 Jun 2003 02:12:14 -0700 (PDT)
From: Anthony Nicholson <nicholson_anthony@yahoo.com>
Subject: matching pages with their owner process(es)
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

anyone know how to determine, from a struct page *, which
process is the owner of the data in that frame? it doesn't
seem from what i've seen in the source, and from what i've
read that there's any easy way to do it.

i'm working on swap space encryption, but need to not 
encrypt/decrypt the swap for a few special processes that
i'm ignoring.

basically i want to be able to tell in rw_swap_page()
from the page* which processes' memory this is. any idea?

thanks
anthony

__________________________________
Do you Yahoo!?
SBC Yahoo! DSL - Now only $29.95 per month!
http://sbc.yahoo.com
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
