From: Kanoj Sarcar <kanoj@google.engr.sgi.com>
Message-Id: <200007230107.SAA14200@google.engr.sgi.com>
Subject: flush_icache_range 
Date: Sat, 22 Jul 2000 18:07:08 -0700 (PDT)
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
Cc: alan@lxorguk.ukuu.org.uk, torvalds@transmeta.com, Kanoj Sarcar <kanoj@google.engr.sgi.com>
List-ID: <linux-mm.kvack.org>

Can anyone point out the logic of continued existance of flush_icache_range
after the introduction of flush_icache_page()? I admit that 
flush_icache_range is still needed in the module loading code, but do we
need it anymore in the a.out loading code? That code should be incurring
page faults, which will do the flush_icache_page anyway. Seems like
double work to me to do flush_icache_range again after the loading has
been done.

This argument to delete the flush_icache_range calls from the a.out
loading code assumes that the f_op->read() code behaves sanely, ie does
not do unexpected things like touch the user address (thus allocating
the page, and doing the icache flush via the page fault handler much
earlier) before it starts reading the a.out sections in ...

Kanoj

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
