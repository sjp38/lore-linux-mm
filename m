Date: Fri, 22 Feb 2008 19:50:33 +0900 (JST)
Message-Id: <20080222.195033.49823053.taka@valinux.co.jp>
Subject: Re: [RFC][PATCH] Clarify mem_cgroup lock handling and avoid races.
From: Hirokazu Takahashi <taka@valinux.co.jp>
In-Reply-To: <Pine.LNX.4.64.0802220916290.18145@blonde.site>
References: <20080220.152753.98212356.taka@valinux.co.jp>
	<20080220155049.094056ac.kamezawa.hiroyu@jp.fujitsu.com>
	<Pine.LNX.4.64.0802220916290.18145@blonde.site>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: hugh@veritas.com
Cc: kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org, balbir@linux.vnet.ibm.com, yamamoto@valinux.co.jp, riel@redhat.com
List-ID: <linux-mm.kvack.org>

Hi,

> > > > Unlike the unsafeties of force_empty, this is liable to hit anyone
> > > > running with MEM_CONT compiled in, they don't have to be consciously
> > > > using mem_cgroups at all.
> > > 
> > > As for force_empty, though this may not be the main topic here,
> > > mem_cgroup_force_empty_list() can be implemented simpler.
> > > It is possible to make the function just call mem_cgroup_uncharge_page()
> > > instead of releasing page_cgroups by itself. The tips is to call get_page()
> > > before invoking mem_cgroup_uncharge_page() so the page won't be released
> > > during this function.
> > > 
> > > Kamezawa-san, you may want look into the attached patch.
> > > I think you will be free from the weired complexity here.
> > > 
> > > This code can be optimized but it will be enough since this function
> > > isn't critical.
> > > 
> > > Thanks.
> > > 
> > > 
> > > Signed-off-by: Hirokazu Takahashi <taka@vallinux.co.jp>
> 
> Hirokazu-san, may I change that to <taka@valinux.co.jp>?

Oops! You can change it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
