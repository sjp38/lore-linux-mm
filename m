Date: Wed, 27 Aug 2008 08:41:57 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 3/14]  memcg: atomic_flags
Message-Id: <20080827084157.b435fa2c.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <48B3C3B2.3090205@linux.vnet.ibm.com>
References: <48B38CDB.1070102@linux.vnet.ibm.com>
	<20080822202720.b7977aab.kamezawa.hiroyu@jp.fujitsu.com>
	<20080822203228.98adf408.kamezawa.hiroyu@jp.fujitsu.com>
	<27319629.1219740371105.kamezawa.hiroyu@jp.fujitsu.com>
	<48B3C3B2.3090205@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: linux-mm@kvack.org, nishimura@mxp.nes.nec.co.jp
List-ID: <linux-mm.kvack.org>

On Tue, 26 Aug 2008 14:19:54 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> kamezawa.hiroyu@jp.fujitsu.com wrote:
> > ----- Original Message -----
> >> KAMEZAWA Hiroyuki wrote:
> >>> This patch makes page_cgroup->flags to be atomic_ops and define
> >>> functions (and macros) to access it.
> >>>
> >>> This patch itself makes memcg slow but this patch's final purpose is 
> >>> to remove lock_page_cgroup() and allowing fast access to page_cgroup.
> >>>
> >> That is a cause of worry, do the patches that follow help performance?
> > By applying patchs for this and RCU and removing lock_page_cgroup(), I saw sma
> > ll performance benefit.
> > 
> >> How do we
> >> benefit from faster access to page_cgroup() if the memcg controller becomes s
> > lower?
> > No slow-down on my box but. But the cpu which I'm testing on is a bit old.
> > I'd like to try newer CPU.
> > As you know, I don't like slow-down very much ;)
> 
> I see, yes, I do know that you like to make things faster. BTW, you did not
> comment on my comments below about the naming convention and using the __ variants

Sorry I missed it. will write reply.

Thanks,
-Kame

> -- 
> 	Balbir
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
