Date: Fri, 15 Feb 2008 14:29:58 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC] [PATCH 3/4] Reclaim from groups over their soft limit
 under memory pressure
Message-Id: <20080215142958.511a2732.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <6599ad830802142116r1c942d78y7002d90c2690a498@mail.gmail.com>
References: <20080213151201.7529.53642.sendpatchset@localhost.localdomain>
	<20080213151242.7529.79924.sendpatchset@localhost.localdomain>
	<20080214163054.81deaf27.kamezawa.hiroyu@jp.fujitsu.com>
	<47B3F073.1070804@linux.vnet.ibm.com>
	<20080214174236.aa2aae9b.kamezawa.hiroyu@jp.fujitsu.com>
	<47B406E4.9060109@linux.vnet.ibm.com>
	<6599ad830802142017g7cdb1b9cid8bbc8cb97e2df68@mail.gmail.com>
	<47B51430.4090009@linux.vnet.ibm.com>
	<20080215140732.8b2dc04e.kamezawa.hiroyu@jp.fujitsu.com>
	<6599ad830802142116r1c942d78y7002d90c2690a498@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Menage <menage@google.com>
Cc: balbir@linux.vnet.ibm.com, linux-mm@kvack.org, Hugh Dickins <hugh@veritas.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Herbert Poetzl <herbert@13thfloor.at>, "Eric W. Biederman" <ebiederm@xmission.com>, David Rientjes <rientjes@google.com>, Pavel Emelianov <xemul@openvz.org>, Nick Piggin <nickpiggin@yahoo.com.au>, Rik Van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Thu, 14 Feb 2008 21:16:48 -0800
"Paul Menage" <menage@google.com> wrote:

> On Thu, Feb 14, 2008 at 9:07 PM, KAMEZAWA Hiroyuki
> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> >  We can free memory by just making memory.limit to smaller number.
> >  (This may cause OOM. If we added high-low watermark, making memory.high smaller
> >   can works well for memory freeing to some extent.)
> >
> 
> What about if we want to apply memory pressure to a cgroup to push out
> unused memory, but not push out memory that it's actively using?
> 
Generally, only way to avoid pageout is mlock() because actively-used is just
determeined by reference-bit and heavy pressure can do page-scanning too much.
I hope that RvR's LRU improvement may change things better.


Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
