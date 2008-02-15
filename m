Date: Fri, 15 Feb 2008 14:07:32 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC] [PATCH 3/4] Reclaim from groups over their soft limit
 under memory pressure
Message-Id: <20080215140732.8b2dc04e.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <47B51430.4090009@linux.vnet.ibm.com>
References: <20080213151201.7529.53642.sendpatchset@localhost.localdomain>
	<20080213151242.7529.79924.sendpatchset@localhost.localdomain>
	<20080214163054.81deaf27.kamezawa.hiroyu@jp.fujitsu.com>
	<47B3F073.1070804@linux.vnet.ibm.com>
	<20080214174236.aa2aae9b.kamezawa.hiroyu@jp.fujitsu.com>
	<47B406E4.9060109@linux.vnet.ibm.com>
	<6599ad830802142017g7cdb1b9cid8bbc8cb97e2df68@mail.gmail.com>
	<47B51430.4090009@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: Paul Menage <menage@google.com>, linux-mm@kvack.org, Hugh Dickins <hugh@veritas.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Herbert Poetzl <herbert@13thfloor.at>, "Eric W. Biederman" <ebiederm@xmission.com>, David Rientjes <rientjes@google.com>, Pavel Emelianov <xemul@openvz.org>, Nick Piggin <nickpiggin@yahoo.com.au>, Rik Van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Fri, 15 Feb 2008 09:55:20 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> Paul Menage wrote:
> > On Thu, Feb 14, 2008 at 1:16 AM, Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> >>  > Probably backgound-reclaim patch will be able to help this soft-limit situation,
> >>  > if a daemon can know it should reclaim or not.
> >>  >
> >>
> >>  Yes, I agree. I might just need to schedule the daemon under memory pressure.
> >>
> > 
> > Can we also have a way to trigger a one-off reclaim (of a configurable
> > magnitude) from userspace? Having a background daemon doing it may be
> > fine as a default, but there will be cases when a userspace machine
> > manager knows better than the kernel how frequently/hard to try to
> > reclaim on a given cgroup.
> > 
> > Paul
> 
> We have that capability, but we cannot specify how much to reclaim.
> There is a force_empty file that when written to, tries to reclaim all pages
> from the cgroup. Depending on the need, it can be extended so that the number of
> pages to be reclaimed can be specified.
> 
Note:
Now, force_empty doesn't try to free memory but just drops charges.

We can free memory by just making memory.limit to smaller number.
(This may cause OOM. If we added high-low watermark, making memory.high smaller
 can works well for memory freeing to some extent.)

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
