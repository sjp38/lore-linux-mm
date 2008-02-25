Date: Mon, 25 Feb 2008 13:02:19 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH] radix-tree based page_cgroup. [0/7] introduction
Message-Id: <20080225130219.d0d8f212.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <47C234E9.3060303@linux.vnet.ibm.com>
References: <20080225120758.27648297.kamezawa.hiroyu@jp.fujitsu.com>
	<47C234E9.3060303@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: "hugh@veritas.com" <hugh@veritas.com>, "yamamoto@valinux.co.jp" <yamamoto@valinux.co.jp>, taka@valinux.co.jp, Andi Kleen <ak@suse.de>, "nickpiggin@yahoo.com.au" <nickpiggin@yahoo.com.au>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, 25 Feb 2008 08:54:25 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> > TODO
> >  - Move to -rc3 or -mm ?
> 
> I think -mm is better, since we have been pushing all the patches through -mm
> and that way we'll get some testing before the patches go in as well.
> 
Okay,

> >  - This patch series doesn't implement page_cgroup removal.
> >    I consider it's worth tring to remove page_cgroup when the page is used for
> >    HugePage or the page is offlined. But this will incease complexity. So, do later.
> 
> Why don't we remove the page_cgroup, what is the increased complexity? I'll take
> a look into the patches.
> 
> >  - More perfomance measurement and brush codes up.
> >  - Check lock dependency...Do more test.
> 
> I think we should work this out as well. Hugh is working on cleanup for locking
> right now. I suspect that with the radix tree changes, there might a conflict
> between your and hugh's work. I think for the moment, while we stabilize and get
> the radix tree patches ready, we should get Hugh's cleanup in.
> 
I agree here.
I think Hugh-san's patch should go fast path, because it's bugfix.
This set should be tested under -mm or private tree  until enough test.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
