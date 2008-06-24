Date: Tue, 24 Jun 2008 10:55:27 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC][PATCH] putback_lru_page()/unevictable page handling
 rework v3
Message-Id: <20080624105527.d9e9eba0.akpm@linux-foundation.org>
In-Reply-To: <1214327453.6563.14.camel@lts-notebook>
References: <20080621185408.E832.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	<20080624114006.D81C.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	<1214327453.6563.14.camel@lts-notebook>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Tue, 24 Jun 2008 13:10:53 -0400 Lee Schermerhorn <Lee.Schermerhorn@hp.com> wrote:

> On Tue, 2008-06-24 at 11:43 +0900, KOSAKI Motohiro wrote:
> > Hi
> > 
> > > I merged kamezawa-san's SHMEM related fix.
> > > this patch works well >2H.
> > > and, I am going to test on stress workload during this week end.
> > > 
> > > but I hope recieve review at first.
> > > thus I post it now.
> > 
> > Unfortunately, my machine crashed last night ;-)
> > I'll dig it.
> 
> 
> I ran 26-rc5-mm3 with 5 split/unevictable lru patches that you posted on
> 19june.  I replaced patch 5 of that series with the subject patch
> [rework v3, merged SHMEM fix].  This kernel ran my 'usex' stress load
> overnight for 23+ hours on both ia64 and x86_64 platforms with no
> problems.  I evidently did not hit the problem you did.
> 
> I'm rebuilding with a patch to a small problem that I discovered along
> with your recent patch to "prevent incorrect oom...".  I'll let you know
> how that goes as well.
> 
> I'll send along two additional patches shortly.
> 

My chances of working out which patches I need to apply to -mm are
near-zero.  I'm working through my vacation backlog in reverse order
and haven't got up to this topic yet.

As you've been paying attention it would be appreciated if you could
send me some stuff, please.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
