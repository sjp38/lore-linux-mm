Message-ID: <3DA30668.1010807@us.ibm.com>
Date: Tue, 08 Oct 2002 09:23:04 -0700
From: Dave Hansen <haveblue@us.ibm.com>
MIME-Version: 1.0
Subject: Re: 2.5.40-mm2
References: <Pine.LNX.4.44.0210081303090.29540-100000@localhost.localdomain>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Andrew Morton <akpm@digeo.com>, lkml <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Ingo Molnar wrote:
> On Sun, 6 Oct 2002, Dave Hansen wrote:
> 
>>cc'ing Ingo, because I think this might be related to the timer bh
>>removal.
> 
> could you try the attached patch against 2.5.41, does it help? It fixes
> the bugs found so far plus makes del_timer_sync() a bit more robust by
> re-checking timer pending-ness before exiting. There is one type of code
> that might have relied on this kind of behavior of the old timer code.

Well, I gave it a shot.  I haven't seen any more of the __run_timers 
oopses yet, but I haven't been able to stay up for very long before it 
freezes, so time will tell.  But, for now,  I'm pretty sure that it is 
quite a bit better.

-- 
Dave Hansen
haveblue@us.ibm.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
