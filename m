Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id 91E2F6B0044
	for <linux-mm@kvack.org>; Fri, 21 Sep 2012 15:59:34 -0400 (EDT)
Received: by pbbro12 with SMTP id ro12so9034481pbb.14
        for <linux-mm@kvack.org>; Fri, 21 Sep 2012 12:59:33 -0700 (PDT)
Date: Fri, 21 Sep 2012 12:59:29 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v3 07/16] memcg: skip memcg kmem allocations in
 specified code regions
Message-ID: <20120921195929.GL7264@google.com>
References: <1347977530-29755-1-git-send-email-glommer@parallels.com>
 <1347977530-29755-8-git-send-email-glommer@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1347977530-29755-8-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, devel@openvz.org, linux-mm@kvack.org, Suleiman Souhlal <suleiman@google.com>, Frederic Weisbecker <fweisbec@gmail.com>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>

Hello,

On Tue, Sep 18, 2012 at 06:12:01PM +0400, Glauber Costa wrote:
> +static void memcg_stop_kmem_account(void)
> +{
> +	if (!current->mm)
> +		return;
> +
> +	current->memcg_kmem_skip_account++;
> +}
> +
> +static void memcg_resume_kmem_account(void)
> +{
> +	if (!current->mm)
> +		return;
> +
> +	current->memcg_kmem_skip_account--;
> +}

I can't say I'm a big fan of this approach.  If there are enough
users, maybe but can't we just annotate the affected allocations
explicitly?  Is this gonna have many more users?

Also, in general, can we please add some comments?  I know memcg code
is dearth of comments but let's please not keep it that way.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
