Date: Wed, 27 Feb 2008 14:13:22 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [RFC][PATCH] page reclaim throttle take2
In-Reply-To: <47C4EF2D.90508@linux.vnet.ibm.com>
References: <20080227140221.424C.KOSAKI.MOTOHIRO@jp.fujitsu.com> <47C4EF2D.90508@linux.vnet.ibm.com>
Message-Id: <20080227141227.424F.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: kosaki.motohiro@jp.fujitsu.com, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

Hi balbir-san,

> >> CONFIG_SIMULTANEOUS_PAGE_RECLAIMERS 
> >> int
> >> default 3
> >> depends on DEBUG
> >> help
> >>   This value determines the number of threads which can do page reclaim
> >>   in a zone simultaneously. If this is too big, performance under heavy memory
> >>   pressure will decrease.
> >>   If unsure, use default.
> >> ==
> >>
> >> Then, you can get performance reports from people interested in this
> >> feature in test cycle.
> > 
> > hm, intersting.
> > but sysctl parameter is more better, i think.
> > 
> > OK, I'll add it at next post.
> 
> I think sysctl should be interesting. The config option provides good
> documentation, but it is static in nature (requires reboot to change). I wish we
> could have the best of both worlds.

OK, I obey your opinion.


- kosaki


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
