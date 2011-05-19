Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id D99EC6B0011
	for <linux-mm@kvack.org>; Thu, 19 May 2011 10:51:51 -0400 (EDT)
Date: Thu, 19 May 2011 22:51:47 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: Kernel falls apart under light memory pressure (i.e. linking
 vmlinux)
Message-ID: <20110519145147.GA14658@localhost>
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
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <BANLkTi=9W6-JXi94rZfTtTpAt3VUiY5fNw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Lutomirski <luto@mit.edu>, Andi Kleen <andi@firstfloor.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>

> > I had 6GB swap available, so there shouldn't have
> > been any OOM.
> 
> Yes. It's strange but we have seen such case several times, AFAIR.

I noticed that the test script mounted a "ramfs" not "tmpfs", hence
the 1.4G pages won't be swapped?

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
