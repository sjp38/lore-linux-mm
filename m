Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx135.postini.com [74.125.245.135])
	by kanga.kvack.org (Postfix) with SMTP id 38FD06B005C
	for <linux-mm@kvack.org>; Wed, 27 Jun 2012 11:48:32 -0400 (EDT)
Date: Wed, 27 Jun 2012 17:48:27 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: memcg: cat: memory.memsw.* : Operation not supported
Message-ID: <20120627154827.GA4420@tiehlicka.suse.cz>
References: <2a1a74bf-fbb5-4a6e-b958-44fff8debff2@zmail13.collab.prod.int.phx2.redhat.com>
 <34bb8049-8007-496c-8ffb-11118c587124@zmail13.collab.prod.int.phx2.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <34bb8049-8007-496c-8ffb-11118c587124@zmail13.collab.prod.int.phx2.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zhouping Liu <zliu@redhat.com>
Cc: linux-mm@kvack.org, Li Zefan <lizefan@huawei.com>, Tejun Heo <tj@kernel.org>, CAI Qian <caiqian@redhat.com>, LKML <linux-kernel@vger.kernel.org>

On Tue 26-06-12 23:49:15, Zhouping Liu wrote:
> hi, all
> 
> when I used memory cgroup in latest mainline, the following error occurred:
> 
> # mount -t cgroup -o memory xxx /cgroup/
> # ll /cgroup/memory.memsw.*
> -rw-r--r--. 1 root root 0 Jun 26 23:17 /cgroup/memory.memsw.failcnt
> -rw-r--r--. 1 root root 0 Jun 26 23:17 /cgroup/memory.memsw.limit_in_bytes
> -rw-r--r--. 1 root root 0 Jun 26 23:17 /cgroup/memory.memsw.max_usage_in_bytes
> -r--r--r--. 1 root root 0 Jun 26 23:17 /cgroup/memory.memsw.usage_in_bytes
> # cat /cgroup/memory.memsw.*
> cat: /cgroup/memory.memsw.failcnt: Operation not supported
> cat: /cgroup/memory.memsw.limit_in_bytes: Operation not supported
> cat: /cgroup/memory.memsw.max_usage_in_bytes: Operation not supported
> cat: /cgroup/memory.memsw.usage_in_bytes: Operation not supported
> 
> I'm confusing why it can't read memory.memsw.* files.

Those files are exported if CONFIG_CGROUP_MEM_RES_CTLR_SWAP=y even
if the feature is turned off when any attempt to open the file returns
EOPNOTSUPP which is exactly what you are seeing.
This is a deliberate decision see: b6d9270d (memcg: always create memsw
files if CONFIG_CGROUP_MEM_RES_CTLR_SWAP).

Does this help to explain your problem? Do you actually see any problem
with this behavior?

Thanks
-- 
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
