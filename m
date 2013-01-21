Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx110.postini.com [74.125.245.110])
	by kanga.kvack.org (Postfix) with SMTP id AFB9A6B0004
	for <linux-mm@kvack.org>; Mon, 21 Jan 2013 05:56:28 -0500 (EST)
Date: Mon, 21 Jan 2013 11:56:24 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: memcg: cat: memory.memsw.* : Operation not supported
Message-ID: <20130121105624.GF7798@dhcp22.suse.cz>
References: <4FEE7665.6020409@jp.fujitsu.com>
 <389106003.8637801.1358757547754.JavaMail.root@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <389106003.8637801.1358757547754.JavaMail.root@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zhouping Liu <zliu@redhat.com>
Cc: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, Li Zefan <lizefan@huawei.com>, CAI Qian <caiqian@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>

On Mon 21-01-13 03:39:07, Zhouping Liu wrote:
> 
> 
> ----- Original Message -----
> > From: "Kamezawa Hiroyuki" <kamezawa.hiroyu@jp.fujitsu.com>
> > To: "Tejun Heo" <tj@kernel.org>
> > Cc: "David Rientjes" <rientjes@google.com>, "Michal Hocko" <mhocko@suse.cz>, "Zhouping Liu" <zliu@redhat.com>,
> > linux-mm@kvack.org, "Li Zefan" <lizefan@huawei.com>, "CAI Qian" <caiqian@redhat.com>, "LKML"
> > <linux-kernel@vger.kernel.org>, "Andrew Morton" <akpm@linux-foundation.org>
> > Sent: Saturday, June 30, 2012 11:45:41 AM
> > Subject: Re: memcg: cat: memory.memsw.* : Operation not supported
> > 
> > (2012/06/29 3:31), Tejun Heo wrote:
> > > Hello, KAME.
> > >
> > > On Thu, Jun 28, 2012 at 01:04:16PM +0900, Kamezawa Hiroyuki wrote:
> > >>> I still wish it's folded into CONFIG_MEMCG and conditionalized
> > >>> just on
> > >>> CONFIG_SWAP tho.
> > >>>
> > >>
> > >> In old days, memsw controller was not very stable. So, we devided
> > >> the config.
> > >> And, it makes size of memory for swap-device double (adds 2bytes
> > >> per swapent.)
> > >> That is the problem.
> > >
> > > I see.  Do you think it's now reasonable to drop the separate
> > > config
> > > option?  Having memcg enabled but swap unaccounted sounds
> > > half-broken
> > > to me.
> > >
> > 
> > Hmm. Maybe it's ok if we can keep boot option. I'll cook a patch in
> > the next week.
> 
> Hello Kame and All,
> 
> Sorry for so delay to open the thread. (please open the link https://lkml.org/lkml/2012/6/26/547 if you don't remember the topic)
> 
> do you have any updates for the issue?
> 
> I checked the latest version, if we don't open CONFIG_MEMCG_SWAP_ENABLED(commit c255a458055e changed
> CONFIG_CGROUP_MEM_RES_CTLR_SWAP_ENABLED as CONFIG_MEMCG_SWAP_ENABLED), the issue still exist:
> 
> [root@dhcp-8-128 ~] cat .config  | grep -i memcg
> CONFIG_MEMCG=y
> CONFIG_MEMCG_SWAP=y
> # CONFIG_MEMCG_SWAP_ENABLED is not set
> CONFIG_MEMCG_KMEM=y
> [root@dhcp-8-128 ~] uname -r
> 3.8.0-rc4+
> [root@dhcp-8-128 ~] cat memory.memsw.*
> cat: memory.memsw.failcnt: Operation not supported
> cat: memory.memsw.limit_in_bytes: Operation not supported
> cat: memory.memsw.max_usage_in_bytes: Operation not supported
> cat: memory.memsw.usage_in_bytes: Operation not supported

Ohh, this one got lost. I thought Kame was working on that.
Anyway the patch bellow should work:
---
