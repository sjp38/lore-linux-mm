From: kanoj@google.engr.sgi.com (Kanoj Sarcar)
Message-Id: <200004211820.LAA35028@google.engr.sgi.com>
Subject: Re: questions on having a driver pin user memory for DMA
Date: Fri, 21 Apr 2000 11:20:46 -0700 (PDT)
In-Reply-To: <38FF961B.ACF08696@giganet.com> from "Weimin Tchen" at Apr 20, 2000 07:43:23 PM
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Weimin Tchen <wtchen@giganet.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Just wanted to point out that I do have a patch for the fork/cow problem
for 2.3 (relevant only for threaded programs), and have talked to Linus 
about this. We will see if he agrees to take it in. Another thing is that 
there are races in map_user_kiobuf racing with kswapd, my patch has fixes 
for that too. 

What I haven't started looking at yet (acceptance of the above patch is
a prerequisite) is how an user program can do a system call that will
invoke map_user_kiobuf(), and then return from the call with the pages
staying pinned. (For now, the best alternative is to use mlock() for
such long lived pinning. I am not sure if anything more is needed here,
but would have to look at the fork path handling to decide). No, I 
an not going to be dragged into a discussion about this right now,
this is just an FYI if you do have a need for this support.

Oh, btw, stay away from PG_locked for your network driver pinning method, 
hangs will happen if your buffer is mapped to file pages.

Kanoj
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
