Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx181.postini.com [74.125.245.181])
	by kanga.kvack.org (Postfix) with SMTP id 940416B0069
	for <linux-mm@kvack.org>; Wed, 27 Jun 2012 16:09:31 -0400 (EDT)
Received: by dakp5 with SMTP id p5so2263643dak.14
        for <linux-mm@kvack.org>; Wed, 27 Jun 2012 13:09:30 -0700 (PDT)
Date: Wed, 27 Jun 2012 13:09:26 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: memcg: cat: memory.memsw.* : Operation not supported
Message-ID: <20120627200926.GR15811@google.com>
References: <2a1a74bf-fbb5-4a6e-b958-44fff8debff2@zmail13.collab.prod.int.phx2.redhat.com>
 <34bb8049-8007-496c-8ffb-11118c587124@zmail13.collab.prod.int.phx2.redhat.com>
 <20120627154827.GA4420@tiehlicka.suse.cz>
 <alpine.DEB.2.00.1206271256120.22162@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1206271256120.22162@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Michal Hocko <mhocko@suse.cz>, Zhouping Liu <zliu@redhat.com>, linux-mm@kvack.org, Li Zefan <lizefan@huawei.com>, CAI Qian <caiqian@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>

Hello, Michal, David.

On Wed, Jun 27, 2012 at 01:04:51PM -0700, David Rientjes wrote:
> I think it's a crappy solution and one that is undocumented in 
> Documentation/cgroups/memory.txt.  If you can only enable swap accounting 
> at boot either via .config or the command line then these files should 
> never be added for CONFIG_CGROUP_MEM_RES_CTLR_SWAP=n or when 
> do_swap_account is 0.  It's much easier to test if the feature is enabled 
> by checking for the presence of these files at the memcg mount point 
> rather than doing an open(2) and checking for -EOPNOTSUPP, which isn't 
> even a listed error code.  I don't care how much cleaner it makes the 
> internal memcg code.

Yeah, it's kinda ugly.  Taking a step back, do we really need be able
to configure out memsw?  How much vmlinux bloat or runtime overhead
are we talking about?  I don't think config options need to be this
granular.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
