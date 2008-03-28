Date: Fri, 28 Mar 2008 20:06:11 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [-mm] Add an owner to the mm_struct (v2)
Message-Id: <20080328200611.71200768.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <47ECCDA4.3050909@linux.vnet.ibm.com>
References: <20080328082316.6961.29044.sendpatchset@localhost.localdomain>
	<20080328194839.fe6ffa52.kamezawa.hiroyu@jp.fujitsu.com>
	<47ECCDA4.3050909@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: Paul Menage <menage@google.com>, Pavel Emelianov <xemul@openvz.org>, Hugh Dickins <hugh@veritas.com>, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, taka@valinux.co.jp, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Fri, 28 Mar 2008 16:21:16 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> > -a bit off topic-
> > BTW, could you move mem_cgroup_from_task() to include/linux/memcontrol.h ?
> > 
> 
> Yes, that can be done
> 
> > Then, I'll add an interface like
> > mem_cgroup_charge_xxx(struct page *page, struct mem_cgroup *mem, gfp_mask mask)
> > 
> > This can be called in following way:
> > mem_cgroup_charge_xxx(page, mem_cgroup_from_task(current), GFP_XXX);
> > and I don't have to access mm_struct's member in this case.
> > 
> 
> OK. Will do. Can that wait until Andrew picks up these patches. Then I'll put
> that as an add-on?
> 
Of course, I can wait.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
