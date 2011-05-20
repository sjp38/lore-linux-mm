Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id C00B46B0011
	for <linux-mm@kvack.org>; Thu, 19 May 2011 20:20:08 -0400 (EDT)
Received: by qwa26 with SMTP id 26so2335903qwa.14
        for <linux-mm@kvack.org>; Thu, 19 May 2011 17:20:07 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110519145147.GA14658@localhost>
References: <BANLkTikofp5rHRdW5dXfqJXb8VCAqPQ_7A@mail.gmail.com>
	<20110514165346.GV6008@one.firstfloor.org>
	<BANLkTik6SS9NH7XVSRBoCR16_5veY0MKBw@mail.gmail.com>
	<20110514174333.GW6008@one.firstfloor.org>
	<BANLkTinst+Ryox9VZ-s7gdXKa574XXqt5w@mail.gmail.com>
	<20110515152747.GA25905@localhost>
	<BANLkTim-AnEeL=z1sYm=iN7sMnG0+m0SHw@mail.gmail.com>
	<20110517060001.GC24069@localhost>
	<BANLkTi=TOm3aLQCD6j=4va6B+Jn2nSfwAg@mail.gmail.com>
	<BANLkTi=9W6-JXi94rZfTtTpAt3VUiY5fNw@mail.gmail.com>
	<20110519145147.GA14658@localhost>
Date: Fri, 20 May 2011 09:20:07 +0900
Message-ID: <BANLkTi=cPRffdaPO9tOfgpLe7W_W3V71tg@mail.gmail.com>
Subject: Re: Kernel falls apart under light memory pressure (i.e. linking vmlinux)
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Lutomirski <luto@mit.edu>, Andi Kleen <andi@firstfloor.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>

On Thu, May 19, 2011 at 11:51 PM, Wu Fengguang <fengguang.wu@intel.com> wrote:
>> > I had 6GB swap available, so there shouldn't have
>> > been any OOM.
>>
>> Yes. It's strange but we have seen such case several times, AFAIR.
>
> I noticed that the test script mounted a "ramfs" not "tmpfs", hence
> the 1.4G pages won't be swapped?

Right. ramfs pages can not be swapped out.
But in log, anon 200M in DMA32 doesn't include unevictable 1.4GB.
So we can swap out 200M, still.

>
> Thanks,
> Fengguang
>



-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
