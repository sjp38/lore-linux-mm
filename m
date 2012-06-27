Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx176.postini.com [74.125.245.176])
	by kanga.kvack.org (Postfix) with SMTP id CF3AD6B005A
	for <linux-mm@kvack.org>; Wed, 27 Jun 2012 16:24:35 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so2501736pbb.14
        for <linux-mm@kvack.org>; Wed, 27 Jun 2012 13:24:35 -0700 (PDT)
Date: Wed, 27 Jun 2012 13:24:30 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: memcg: cat: memory.memsw.* : Operation not supported
Message-ID: <20120627202430.GS15811@google.com>
References: <2a1a74bf-fbb5-4a6e-b958-44fff8debff2@zmail13.collab.prod.int.phx2.redhat.com>
 <34bb8049-8007-496c-8ffb-11118c587124@zmail13.collab.prod.int.phx2.redhat.com>
 <20120627154827.GA4420@tiehlicka.suse.cz>
 <alpine.DEB.2.00.1206271256120.22162@chino.kir.corp.google.com>
 <20120627200926.GR15811@google.com>
 <alpine.DEB.2.00.1206271316070.22162@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1206271316070.22162@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Michal Hocko <mhocko@suse.cz>, Zhouping Liu <zliu@redhat.com>, linux-mm@kvack.org, Li Zefan <lizefan@huawei.com>, CAI Qian <caiqian@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Hello,

On Wed, Jun 27, 2012 at 01:21:27PM -0700, David Rientjes wrote:
> Well it also has a prerequisite that memcg doesn't have: CONFIG_SWAP, so 

Right.

> even if CONFIG_CGROUP_MEM_RES_CTLR_SWAP is folded into 
> CONFIG_CGROUP_MEM_RES_CTLR, then these should still depend on CONFIG_SWAP 
> since configuring them would imply there is some limit to be enforced.
> 
> But to answer your question:
> 
>    text	   data	    bss	    dec	    hex	filename
>   25777	   3644	   4128	  33549	   830d	memcontrol.o.swap_disabled
>   27294	   4476	   4128	  35898	   8c3a	memcontrol.o.swap_enabled

I still wish it's folded into CONFIG_MEMCG and conditionalized just on
CONFIG_SWAP tho.

> Is it really too painful to not create these files when 
> CONFIG_CGROUP_MEM_RES_CTLR_SWAP is disabled?  If so, can we at least allow 
> them to be opened but return -EINVAL if memory.memsw.limit_in_bytes is 
> written?

Not at all, that was the first version anyway, which (IIRC) KAME
didn't like and suggested always creating those files.  KAME, what do
you think?

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
