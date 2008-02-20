Date: Wed, 20 Feb 2008 20:21:43 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH] Clarify mem_cgroup lock handling and avoid races.
Message-Id: <20080220202143.4cc2fc05.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <47BC0704.9010603@linux.vnet.ibm.com>
References: <20080219215431.1aa9fa8a.kamezawa.hiroyu@jp.fujitsu.com>
	<Pine.LNX.4.64.0802191449490.6254@blonde.site>
	<47BBC15E.5070405@linux.vnet.ibm.com>
	<20080220.185821.61784723.taka@valinux.co.jp>
	<6599ad830802200206w23955c9cn26bf768e790a6161@mail.gmail.com>
	<47BBFCC2.5020408@linux.vnet.ibm.com>
	<6599ad830802200218t41c70455u5d008c605e8b9762@mail.gmail.com>
	<47BC0704.9010603@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: Paul Menage <menage@google.com>, Hirokazu Takahashi <taka@valinux.co.jp>, hugh@veritas.com, linux-mm@kvack.org, yamamoto@valinux.co.jp, riel@redhat.com
List-ID: <linux-mm.kvack.org>

On Wed, 20 Feb 2008 16:25:00 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> Paul Menage wrote:
> > On Feb 20, 2008 2:11 AM, Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> >> Dynamically turning on/off the memory controller, can/will lead to accounting
> >> issues and deficiencies, since the memory controller would now have no idea of
> >> how much memory has been allocated by which cgroup.
> >>
> > 
> > A cgroups subsystem can only be unbound from its hierarchy when there
> > are no child cgroups of the root cgroup in that hierarchy. So this
> > shouldn't be too much of a problem - when this transition occurs, all
> > tasks are in the same group, and no other groups exist.
> > 
> > Paul
> 
> Yes, I agree, but then at the point of unbinding them, tasks could have already
> allocated several pages to their RSS or brought in pages into the page cache.
> Accounting from this state is not so straight forward and will lead to more
> complexity in code.

unbind -> force_empty can't work ?

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
