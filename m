Message-Id: <200106251705.MAA02325@ccure.karaya.com>
Subject: Re: all processes waiting in TASK_UNINTERRUPTIBLE state 
In-Reply-To: Your message of "Mon, 25 Jun 2001 10:10:38 -0400."
             <OF7B251945.42FE908D-ON85256A76.004C34E9@pok.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Date: Mon, 25 Jun 2001 12:05:14 -0500
From: Jeff Dike <jdike@karaya.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Bulent Abali <abali@us.ibm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, James Stevenson <mistral@stev.org>
List-ID: <linux-mm.kvack.org>

abali@us.ibm.com said:
> I am running in to a problem, seemingly a deadlock situation, where
> almost all the processes end up in the TASK_UNINTERRUPTIBLE state.
> All the process eventually stop responding, including login shell, no
> screen updates, keyboard etc.  Can ping and sysrq key works.   I
> traced the tasks through sysrq-t key.  The processors are in the idle
> state.  Tasks all seem to get stuck in the __wait_on_page or
> __lock_page.

I've seen this under UML, Rik van Riel has seen it on a physical box, and we 
suspect that they're the same problem (i.e. mine isn't a UML-specific bug).

I've done some poking at the problem, but haven't really learned anything 
except that something is locking pages and not unlocking them.  Figuring out 
who that is was going to be my next step.

If anyone is interested in poking around a UML in this state (i.e. you get all 
the niceties of gdb), let me know.  I think I can probably oblige.

				Jeff


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
