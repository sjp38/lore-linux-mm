Date: Fri, 18 May 2001 19:32:03 -0700
From: Mike Castle <dalgoda@ix.netcom.com>
Subject: Re: Linux 2.4.4-ac10
Message-ID: <20010518193203.C29686@thune.mrc-home.com>
Reply-To: Mike Castle <dalgoda@ix.netcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.21.0105182310580.5531-100000@imladris.rielhome.conectiva>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, May 18, 2001 at 11:12:32PM -0300, Rik van Riel wrote:
> Basic rule for VM: once you start swapping, you cannot
> win;  All you can do is make sure no situation loses
> really badly and most situations perform reasonably.

Do you mean paging in general or thrashing?

I always thought: paging good, thrashing bad.

A good effecient paging system, always moving data between memory and disk,
is great.  It's when you have the greater than physical memory working set
that things go to hell in a hand basket.

Did Linux ever do the old trick of "We've too much going on!  You!
(randomly points to a process) take a seat!  You're not running for a
while!" and the process gets totatlly swapped out for a "while," not even
scheduled?

mrc
-- 
       Mike Castle       Life is like a clock:  You can work constantly
  dalgoda@ix.netcom.com  and be right all the time, or not work at all
www.netcom.com/~dalgoda/ and be right at least twice a day.  -- mrc
    We are all of us living in the shadow of Manhattan.  -- Watchmen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
