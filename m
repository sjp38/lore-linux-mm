Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id NAA04843
	for <linux-mm@kvack.org>; Wed, 9 Oct 2002 13:17:47 -0700 (PDT)
Message-ID: <3DA48EEA.8100302C@digeo.com>
Date: Wed, 09 Oct 2002 13:17:46 -0700
From: Andrew Morton <akpm@digeo.com>
MIME-Version: 1.0
Subject: Re: Hangs in 2.5.41-mm1
References: <1034188573.30975.40.camel@plars>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Larson <plars@linuxtestproject.org>
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Paul Larson wrote:
> 
> I'm able to generate a lot of hangs with 2.5.41-mm1.
> This is on a 8-way PIII-700, 16 GB ram (PAE enabled)
> 
> The first one, I got by running ltp for a while, then the attached test
> for a bit, then, at the suggestion of Bill Irwin to increase the amount
> of ram I could be using for huge pages:
> echo 768 > /proc/sys/vm/nr_hugepages

Paul, this is not very clear to me, sorry.

You don't state at which point it hung.  Could you please
carefully spell out the precise sequence of steps which led to
the hang?

> Doing that (and the corresponding echo 1610612736 >
> /proc/sys/kernel/shmmax) after a cold boot gave me no problems though.
> 
> I also got it to hang after runnging the attached test with -s
> 1610612736 and then running another one with no options.

With what settings in /proc, etc?

 
> There was no output on the serial console when it hung, and it was
> unresponsive to ping, vc switch, and sysrq.
> 
> The attached test is an ltp shmem test modified by Bill Irwin to support
> the shm huge pages in 2.5.41-mm1.  Compile it with --static.

OK, great.  I'll try to reproduce this but I would appreciate
some help in understanding what I need to do.  Usually it just
ends up with "it works for me" :(

There is a locks-up-for-ages bug in refill_inactive_zone() - could
be that.  Dunno.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
