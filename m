From: kanoj@google.engr.sgi.com (Kanoj Sarcar)
Message-Id: <199906101918.MAA09371@google.engr.sgi.com>
Subject: Experiment on usefuleness of cache coloring on ia32
Date: Thu, 10 Jun 1999 12:18:32 -0700 (PDT)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

In an attempt to characterize the effects of cache coloring in 
the os for a modern Intel processor, I spent a couple of days 
hacking the Linux kernel and experimenting with a toy program. 
The kernel patch does a gross type of colored allocation by 
grabbing pages from the free list until it gets one of the right
color - the intent is not to study the os overheads of doing
colored allocations, rather the benefits a program might see from
using pages allocated in such fashion. My findings are at

        http://reality.sgi.com/kanoj_engr/ccdis.html

and it has at least one unexplained observation. If you are
interested in this sort of thing, please browse it and send me
comments about how I can improve the study. Pointers to apps which 
are suspected to benefit from cache coloring would also help.

Thanks.

Kanoj
kanoj@engr.sgi.com
--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
