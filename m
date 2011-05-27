Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 9B4AC6B0011
	for <linux-mm@kvack.org>; Fri, 27 May 2011 02:08:44 -0400 (EDT)
Date: Fri, 27 May 2011 08:08:26 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH] mm: don't access vm_flags as 'int'
Message-ID: <20110527060826.GA9260@elte.hu>
References: <4DDE2873.7060409@jp.fujitsu.com>
 <BANLkTi=znC18PAbpDfeVO+=Pat_EeXddjw@mail.gmail.com>
 <BANLkTikgXhmgzQYfSWKDoxVyNuCzSM7Qxw@mail.gmail.com>
 <BANLkTin3vHzUu-p654jvkG4R1Td261b3Aw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <BANLkTin3vHzUu-p654jvkG4R1Td261b3Aw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: richard -rw- weinberger <richard.weinberger@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, benh@kernel.crashing.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, hughd@google.com, akpm@linux-foundation.org, dave@linux.vnet.ibm.com, kamezawa.hiroyu@jp.fujitsu.com


* Linus Torvalds <torvalds@linux-foundation.org> wrote:

> On Thu, May 26, 2011 at 11:50 AM, richard -rw- weinberger
> <richard.weinberger@gmail.com> wrote:
> >
> > This breaks kernel builds with CONFIG_HUGETLBFS=n. :-(
> 
> Grr. I did the "allyesconfig" build to find any problems, but that
> obviously also sets HUGETLBFS.
> 
> But "allnoconfig" does find this.

Yeah, my experience is that [all[yes|no|mod]|def]config covers about 
95% of the build bugs and the remaining 5% are rarely showstopper 
problems (they generally don't show up in configs that people use).

Given how fast allnoconfig and defconfig builds i've got allnoconfig 
and defconfig scripted to always execute together with allyesconfig.

So if you go the trouble to build allyesconfig manually, it costs 
almost no time to tack on the allnoconfig and defconfig as well (and 
stick this all into a script), while it increases the efficiency of 
the build test remarkably.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
