Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx135.postini.com [74.125.245.135])
	by kanga.kvack.org (Postfix) with SMTP id E95896B005A
	for <linux-mm@kvack.org>; Wed, 27 Jun 2012 16:21:29 -0400 (EDT)
Received: by dakp5 with SMTP id p5so2279377dak.14
        for <linux-mm@kvack.org>; Wed, 27 Jun 2012 13:21:29 -0700 (PDT)
Date: Wed, 27 Jun 2012 13:21:27 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: memcg: cat: memory.memsw.* : Operation not supported
In-Reply-To: <20120627200926.GR15811@google.com>
Message-ID: <alpine.DEB.2.00.1206271316070.22162@chino.kir.corp.google.com>
References: <2a1a74bf-fbb5-4a6e-b958-44fff8debff2@zmail13.collab.prod.int.phx2.redhat.com> <34bb8049-8007-496c-8ffb-11118c587124@zmail13.collab.prod.int.phx2.redhat.com> <20120627154827.GA4420@tiehlicka.suse.cz> <alpine.DEB.2.00.1206271256120.22162@chino.kir.corp.google.com>
 <20120627200926.GR15811@google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Michal Hocko <mhocko@suse.cz>, Zhouping Liu <zliu@redhat.com>, linux-mm@kvack.org, Li Zefan <lizefan@huawei.com>, CAI Qian <caiqian@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>

On Wed, 27 Jun 2012, Tejun Heo wrote:

> Yeah, it's kinda ugly.  Taking a step back, do we really need be able
> to configure out memsw?  How much vmlinux bloat or runtime overhead
> are we talking about?  I don't think config options need to be this
> granular.
> 

Well it also has a prerequisite that memcg doesn't have: CONFIG_SWAP, so 
even if CONFIG_CGROUP_MEM_RES_CTLR_SWAP is folded into 
CONFIG_CGROUP_MEM_RES_CTLR, then these should still depend on CONFIG_SWAP 
since configuring them would imply there is some limit to be enforced.

But to answer your question:

   text	   data	    bss	    dec	    hex	filename
  25777	   3644	   4128	  33549	   830d	memcontrol.o.swap_disabled
  27294	   4476	   4128	  35898	   8c3a	memcontrol.o.swap_enabled

Is it really too painful to not create these files when 
CONFIG_CGROUP_MEM_RES_CTLR_SWAP is disabled?  If so, can we at least allow 
them to be opened but return -EINVAL if memory.memsw.limit_in_bytes is 
written?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
