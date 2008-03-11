Date: Tue, 11 Mar 2008 18:39:40 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 2/2] Make res_counter hierarchical
Message-Id: <20080311183940.11695e41.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <47D64E0A.3090907@linux.vnet.ibm.com>
References: <47D16004.7050204@openvz.org>
	<20080308134514.434f38f4.kamezawa.hiroyu@jp.fujitsu.com>
	<47D63FBC.1010805@openvz.org>
	<6599ad830803110157u71fe6c3cse125d0202610413b@mail.gmail.com>
	<20080311181325.c0bf6b90.kamezawa.hiroyu@jp.fujitsu.com>
	<6599ad830803110211u1cb48874l30aa75d21dc2b23@mail.gmail.com>
	<47D64E0A.3090907@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: Paul Menage <menage@google.com>, Pavel Emelyanov <xemul@openvz.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Linux Containers <containers@lists.osdl.org>, Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 11 Mar 2008 14:46:58 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> Paul Menage wrote:
> > On Tue, Mar 11, 2008 at 2:13 AM, KAMEZAWA Hiroyuki
> > <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> >>  or remove all relationship among counters of *different* type of resources.
> >>  user-land-daemon will do enough jobs.
> >>
> > 
> > Yes, that would be my preferred choice, if people agree that
> > hierarchically limiting overall virtual memory isn't useful. (I don't
> > think I have a use for it myself).
> > 
> 
> Virtual limits are very useful. I have a patch ready to send out.
> They limit the amount of paging a cgroup can do (virtual limit - RSS limit).
> Some times end users want to set virtual limit == RSS limit, so that the cgroup
> OOMs on cross the RSS limit.
> 
I have no objection to adding virtual limit itself.
(It can be considered as extended ulimit.)

But if you'd like to add relationship between virtual-limit/memory-usage-limit,
please take care to make it clear that relationship is reaseonable.

- memory-usage includes page-cache.
- memory-usage doesn't include hugepages.
- How to treat MAP_NORESERVE is depends on over-commit-memory type.
  how cgroup does ?
- shared memory will be conuted per mmap.


Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
