Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id C0A056B004D
	for <linux-mm@kvack.org>; Tue, 26 Jun 2012 14:08:13 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so492045pbb.14
        for <linux-mm@kvack.org>; Tue, 26 Jun 2012 11:08:13 -0700 (PDT)
Date: Tue, 26 Jun 2012 11:08:05 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 06/11] memcg: kmem controller infrastructure
Message-ID: <20120626180805.GQ3869@google.com>
References: <1340633728-12785-1-git-send-email-glommer@parallels.com>
 <1340633728-12785-7-git-send-email-glommer@parallels.com>
 <20120625161720.ae13ae90.akpm@linux-foundation.org>
 <4FE9CEBB.80108@parallels.com>
 <20120626110142.b7cf6d7c.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120626110142.b7cf6d7c.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Glauber Costa <glommer@parallels.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Frederic Weisbecker <fweisbec@gmail.com>, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Lameter <cl@linux.com>, devel@openvz.org, kamezawa.hiroyu@jp.fujitsu.com, Pekka Enberg <penberg@cs.helsinki.fi>

On Tue, Jun 26, 2012 at 11:01:42AM -0700, Andrew Morton wrote:
> On Tue, 26 Jun 2012 19:01:15 +0400 Glauber Costa <glommer@parallels.com> wrote:
> 
> > On 06/26/2012 03:17 AM, Andrew Morton wrote:
> > >> +	memcg_uncharge_kmem(memcg, size);
> > >> >+	mem_cgroup_put(memcg);
> > >> >+}
> > >> >+EXPORT_SYMBOL(__mem_cgroup_free_kmem_page);
> > >> >  #endif /* CONFIG_CGROUP_MEM_RES_CTLR_KMEM */
> > >> >
> > >> >  #if defined(CONFIG_INET) && defined(CONFIG_CGROUP_MEM_RES_CTLR_KMEM)
> > >> >@@ -5645,3 +5751,69 @@ static int __init enable_swap_account(char *s)
> > >> >  __setup("swapaccount=", enable_swap_account);
> > >> >
> > >> >  #endif
> > >> >+
> > >> >+#ifdef CONFIG_CGROUP_MEM_RES_CTLR_KMEM
> > > gargh.  CONFIG_MEMCG_KMEM, please!
> > >
> > 
> > Here too. I like it as much as you do.
> > 
> > But that is consistent with the rest of the file, and I'd rather have
> > it this way.
> 
> There's not much point in being consistent with something which is so
> unpleasant.  I'm on a little campaign to rename
> CONFIG_CGROUP_MEM_RES_CTLR to CONFIG_MEMCG, only nobody has taken my
> bait yet.  Be first!

+1.

Block cgroup recently did blkio / blkiocg / blkio_cgroup -> blkcg.
Join the cool crowd!  :P

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
