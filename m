Message-ID: <41A1D850.6090706@tebibyte.org>
Date: Mon, 22 Nov 2004 13:15:12 +0100
From: Chris Ross <chris@tebibyte.org>
MIME-Version: 1.0
Subject: Re: [PATCH] fix spurious OOM kills
References: <20041111112922.GA15948@logos.cnet>	<4193E056.6070100@tebibyte.org>	<4194EA45.90800@tebibyte.org>	<20041113233740.GA4121@x30.random>	<20041114094417.GC29267@logos.cnet>	<20041114170339.GB13733@dualathlon.random>	<20041114202155.GB2764@logos.cnet>	<419A2B3A.80702@tebibyte.org>	<419B14F9.7080204@tebibyte.org> <20041117012346.5bfdf7bc.akpm@osdl.org> <41A0E60C.605@tebibyte.org>
In-Reply-To: <41A0E60C.605@tebibyte.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: marcelo.tosatti@cyclades.com, andrea@novell.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, piggin@cyberone.com.au, riel@redhat.com, mmokrejs@ribosome.natur.cuni.cz, tglx@linutronix.de
List-ID: <linux-mm.kvack.org>

Hi Andrew,

Chris Ross escreveu:
 > Andrew Morton escreveu:
 >> Please ignore the previous patch and try the below.
 >
 > I still get OOM kills with this (well one, anyway). It does seem harder
 > to trigger though.

Turns out it's not that hard. Sorry for the slight delay, I've been away 
a few days.

root@sleepy chris # grep Killed /var/log/messages
Nov 21 22:24:22 sleepy Out of Memory: Killed process 6800 (qmgr).
Nov 21 22:24:32 sleepy Out of Memory: Killed process 6799 (pickup).
Nov 21 22:24:57 sleepy Out of Memory: Killed process 6472 (distccd).
Nov 21 22:25:00 sleepy Out of Memory: Killed process 6473 (distccd).
Nov 21 22:25:00 sleepy Out of Memory: Killed process 6582 (distccd).
Nov 21 22:25:00 sleepy Out of Memory: Killed process 6686 (distccd).
Nov 21 22:25:00 sleepy Out of Memory: Killed process 6687 (ntpd).

If you want to seem the actual oom messages just ask.

This is with 2.6.10-rc2-mm1 + your patch whilst doing an "emerge sync" 
which isn't ridiculously memory hungry and shouldn't result in oom kills.

Informally I felt I had better results from Marcelo's patch, though I 
should test both under the same conditions before I say that...

Regards,
Chris R.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
