Date: Wed, 27 Feb 2008 14:00:42 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH] page reclaim throttle take2
Message-Id: <20080227140042.66abb805.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080227133850.4249.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <20080227131939.4244.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	<47C4E6CD.6090401@linux.vnet.ibm.com>
	<20080227133850.4249.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: balbir@linux.vnet.ibm.com, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On Wed, 27 Feb 2008 13:45:18 +0900
KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

> Hi
> 
> > One more thing, I would request you to add default heuristics (number of
> > reclaimers), based on the number of cpus in the system. Letting people tuning it
> > is fine, but defaults should be related to number of cpus, nodes and zones on
> > the system. Zones can be reaped in parallel per node and cpus allow threads to
> > run in parallel. So please use that to come up with good defaults, instead of a
> > number like "3".
> 
> I don't think so.
> all modern many cpu machine stand on NUMA.
> it mean following,
>  - if cpu increases, then zone increases, too.
> 
> if default value increase by #cpus, lock contension dramatically increase
> on large numa.
> 
> Have I overlooked anything?
> 
> 
How about adding something like..
== 
CONFIG_SIMULTANEOUS_PAGE_RECLAIMERS 
int
default 3
depends on DEBUG
help
  This value determines the number of threads which can do page reclaim
  in a zone simultaneously. If this is too big, performance under heavy memory
  pressure will decrease.
  If unsure, use default.
==

Then, you can get performance reports from people interested in this
feature in test cycle.

Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
