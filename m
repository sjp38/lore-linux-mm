Received: from atlas.CARNet.hr (zcalusic@atlas.CARNet.hr [161.53.123.163])
	by kvack.org (8.8.7/8.8.7) with ESMTP id LAA14667
	for <linux-mm@kvack.org>; Tue, 5 Jan 1999 11:24:05 -0500
Resent-Message-Id: <199901051622.RAA01092@atlas.CARNet.hr>
Resent-To: linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
Subject: Re: [patch] arca-vm-6, killed kswapd [Re: [patch] new-vm improvement , [Re: 2.2.0 Bug summary]]
References: <Pine.LNX.3.96.990105164004.3611D-100000@laser.bogus>
Reply-To: Zlatko.Calusic@CARNet.hr
From: Zlatko Calusic <Zlatko.Calusic@CARNet.hr>
Date: 05 Jan 1999 17:16:21 +0100
In-Reply-To: Andrea Arcangeli's message of "Tue, 5 Jan 1999 16:42:35 +0100 (CET)"
Message-ID: <874sq5g0fe.fsf@atlas.CARNet.hr>
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <andrea@e-mind.com>
List-ID: <linux-mm.kvack.org>

Andrea Arcangeli <andrea@e-mind.com> writes:

> On 5 Jan 1999, Zlatko Calusic wrote:
> 
> > I tried few times, but to no avail. Looks like subtle race, bad news
> > for you, unfortunately.
> 
> Hmm, I gues it's been due the wrong order shifiting you pointed out a bit
> before...

Nope. I fixed that before compiling. :)
It's even in my PRCS tree, your patches and my parentheses. :)

linux-2.1 2204.3 Tue, 05 Jan 1999 00:15:24 +0100 by zcalusic
Parent-Version:      2204.2
Version-Log:         MM & no kswapd (andrea)

linux-2.1 2204.4 Tue, 05 Jan 1999 03:34:57 +0100 by zcalusic
Parent-Version:      2204.2
Version-Log:         arca-vm-7

> 
> The lockup could be due to one oom loop. Ingo pointed out at once that
> raid1 (if I remeber well) has one of them. Do you use raidx?
> 

Wow, that's a new variable in a story, I'm indeed using raid0 (IDE +
SCSI). That is it, then. Should I contact Ingo about that? I'm not on
linux-raid, so I never heard of a problem like that, in fact it
happened only yesterday I lost control of machine in such a strange
way.

> > Sure, just be careful. :)
> 
> Don't worry ;). Could you try if you can reproduce problems with
> arca-vm-8? 
> 

Huh, I must refuse your proposal, at least til' I get some
sleep. :(

Tomorrow is non-working day, so I'll spend some time reading stuff
(recently I bought Rubini's Device Drivers), and on the Thursday I'm
back to regular schedule, sleepless nights and arca-vm-10, at that
time, probably. :)

While at VM changes, I have one (reborn) objection. It looks like
recent kernels are once again very aggressive when it comes to copying
lots of data. That is, if you cp few hundred of MB's, you effectively
finish with cleansed memory (populated with page cache pages) and
programs are on swap. Behaviour is practicaly identical in vanilla
Linus' tree and with your changes applied. Maybe you could, when
you're at it, see if that problem can be solved. With such a
behaviour, Linux feels very slugish, feels like a NT crap.

I know it's tough job, because I spent lots of time trying, but my
conclusion is that whenever you have good swapping speed, kernel will
outswap too much. On the other side if you fix that, swapping speed
drops. Tough luck. :(

I wish you good luck with your work, anyway.
-- 
Zlatko
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
