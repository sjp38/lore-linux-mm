Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 6D4336B0011
	for <linux-mm@kvack.org>; Thu, 19 May 2011 11:03:05 -0400 (EDT)
Received: by pwi12 with SMTP id 12so1681768pwi.14
        for <linux-mm@kvack.org>; Thu, 19 May 2011 08:00:44 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110519145147.GA14658@localhost>
References: <BANLkTikofp5rHRdW5dXfqJXb8VCAqPQ_7A@mail.gmail.com>
 <20110514165346.GV6008@one.firstfloor.org> <BANLkTik6SS9NH7XVSRBoCR16_5veY0MKBw@mail.gmail.com>
 <20110514174333.GW6008@one.firstfloor.org> <BANLkTinst+Ryox9VZ-s7gdXKa574XXqt5w@mail.gmail.com>
 <20110515152747.GA25905@localhost> <BANLkTim-AnEeL=z1sYm=iN7sMnG0+m0SHw@mail.gmail.com>
 <20110517060001.GC24069@localhost> <BANLkTi=TOm3aLQCD6j=4va6B+Jn2nSfwAg@mail.gmail.com>
 <BANLkTi=9W6-JXi94rZfTtTpAt3VUiY5fNw@mail.gmail.com> <20110519145147.GA14658@localhost>
From: Andrew Lutomirski <luto@mit.edu>
Date: Thu, 19 May 2011 11:00:24 -0400
Message-ID: <BANLkTim4caSU_uRY1GLMh9D=8gctp34jMA@mail.gmail.com>
Subject: Re: Kernel falls apart under light memory pressure (i.e. linking vmlinux)
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, Andi Kleen <andi@firstfloor.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>

On Thu, May 19, 2011 at 10:51 AM, Wu Fengguang <fengguang.wu@intel.com> wrote:
>> > I had 6GB swap available, so there shouldn't have
>> > been any OOM.
>>
>> Yes. It's strange but we have seen such case several times, AFAIR.
>
> I noticed that the test script mounted a "ramfs" not "tmpfs", hence
> the 1.4G pages won't be swapped?

That's intentional.

I run LVM over dm-crypt on an SSD, and I thought that might be part of
the problem.  I wanted a script that would see if I could reproduce
the problem without stressing that system too much, so I created a
second backing store on dm-crypt over ramfs so that no real I/O will
happen.  The script is quite effective at bringing down my system, so
I haven't changed it.

(I have 6GB of "real" swap on the LVM, so pinning 1500MB into RAM
ought to cause some thrashing but not take the system down.  And this
script with a larger ramfs does not take down my desktop, which is an
8GB Sandy Bridge box.  But whatever the underlying bug is seems to
mainly affect Sandy Bridge *laptops*, so maybe that's expected.)

--Andy

>
> Thanks,
> Fengguang
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
