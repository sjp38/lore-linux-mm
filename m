Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id JAA16784
	for <linux-mm@kvack.org>; Tue, 8 Oct 2002 09:56:45 -0700 (PDT)
Message-ID: <3DA30E4D.CADFFB4D@digeo.com>
Date: Tue, 08 Oct 2002 09:56:45 -0700
From: Andrew Morton <akpm@digeo.com>
MIME-Version: 1.0
Subject: Re: 2.5.40-mm2
References: <Pine.LNX.4.44.0210081303090.29540-100000@localhost.localdomain> <3DA30B28.8070504@us.ibm.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: Ingo Molnar <mingo@elte.hu>, lkml <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Dave Hansen wrote:
> 
> Ingo Molnar wrote:
> > On Sun, 6 Oct 2002, Dave Hansen wrote:
> >
> >>cc'ing Ingo, because I think this might be related to the timer bh
> >>removal.
> >
> > could you try the attached patch against 2.5.41, does it help? It fixes
> > the bugs found so far plus makes del_timer_sync() a bit more robust by
> > re-checking timer pending-ness before exiting. There is one type of code
> > that might have relied on this kind of behavior of the old timer code.
> 
> Hehe.  That'll teach me to be optimistic.  This is unprocessed, but
> the EIP in tvec_bases should tell the whole story.  Something _nasty_
> is going on.
> 
> addr2line on the run_timer_tasklet call: kernel/timer.c:359
> This is with the patch that Ingo sent me about 6 hours ago.  Andrew,
> should I still test the one that you sent me this morning?

No; I think Ingo covered everything there, and more.


> Dave Hansen
> haveblue@us.ibm.com
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
