Date: Tue, 15 Apr 2008 12:22:20 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] use vmalloc for mem_cgroup allocation. v2
Message-Id: <20080415122220.748834b7.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <48041D90.2040702@cn.fujitsu.com>
References: <20080415105434.3044afb6.kamezawa.hiroyu@jp.fujitsu.com>
	<20080415111038.ffac0e12.kamezawa.hiroyu@jp.fujitsu.com>
	<20080414191730.7d13e619.akpm@linux-foundation.org>
	<20080415121617.16127623.kamezawa.hiroyu@jp.fujitsu.com>
	<48041D90.2040702@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Li Zefan <lizf@cn.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "xemul@openvz.org" <xemul@openvz.org>, menage@google.com, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Tue, 15 Apr 2008 11:14:24 +0800
Li Zefan <lizf@cn.fujitsu.com> wrote:

> KAMEZAWA Hiroyuki wrote:
> > On Mon, 14 Apr 2008 19:17:30 -0700
> > Andrew Morton <akpm@linux-foundation.org> wrote:
> >> Well...  vmalloced memory is of course a little slower to use - additional
> >> TLB pressure.
> >>
> >> Do you think the memcgroup is accessed frequently enough to use vmalloc()
> >> only on those architectures which actually need it?
> >>
> >> Because it'd be pretty simple to implement:
> >>
> >> 	if (sizeof(struct mem_group) > PAGE_SIZE)
> >> 		vmalloc()
> >> 	else
> >> 		kmalloc()
> >>
> >> 	...
> >>
> >> 	if (sizeof(struct mem_group) > PAGE_SIZE)
> >> 		vfree()
> >> 	else
> >> 		kfree()
> >>
> >> the compiler will optimise away the `if'.
> >>
> > 
> > Hmm, ok. I'll rewrite one to do that.
> > 
> 
> It will be better to use wrappers for these: mem_cgroup_alloc() and mem_cgroup_free()
> 
yes. will do

-Kame
> > Thanks,
> > -Kame
> > 
> > 
> > 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
