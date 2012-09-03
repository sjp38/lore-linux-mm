Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx117.postini.com [74.125.245.117])
	by kanga.kvack.org (Postfix) with SMTP id 96AAC6B005D
	for <linux-mm@kvack.org>; Mon,  3 Sep 2012 12:41:59 -0400 (EDT)
Date: Mon, 3 Sep 2012 17:41:48 +0100
From: Ben Hutchings <ben@decadent.org.uk>
Message-ID: <20120903164148.GS29217@decadent.org.uk>
References: <1346687211-31848-1-git-send-email-glommer@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1346687211-31848-1-git-send-email-glommer@parallels.com>
Subject: Re: [PATCH v2] memcg: first step towards hierarchical controller
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org, Dave Jones <davej@redhat.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Turner <pjt@google.com>, Lennart Poettering <lennart@poettering.net>, Kay Sievers <kay.sievers@vrfy.org>, Michal Hocko <mhocko@suse.cz>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>

On Mon, Sep 03, 2012 at 07:46:51PM +0400, Glauber Costa wrote:
> Here is a new attempt to lay down a path that will allow us to deprecate
> the non-hierarchical mode of operation from memcg.  Unlike what I posted
> before, I am making this behavior conditional on a Kconfig option.
> Vanilla users will see no change in behavior unless they don't
> explicitly set this option to on.

There are too many negatives in this sentence - it is not only
unclear, but appears to be incorrect.  I think you should delete
'don't'.

[...]
> --- a/init/Kconfig
> +++ b/init/Kconfig
> @@ -726,6 +726,24 @@ config MEMCG_SWAP
>  	  if boot option "swapaccount=0" is set, swap will not be accounted.
>  	  Now, memory usage of swap_cgroup is 2 bytes per entry. If swap page
>  	  size is 4096bytes, 512k per 1Gbytes of swap.
> +
> +config MEMCG_HIERARCHY_DEFAULT
> +	bool "Hierarchical memcg"
> +	depends on MEMCG
> +	default n
> +	help
> +	  The memory controller has two modes of accounting: hierarchical and
> +	  flat. Hierarchical accounting will charge pages all the way towards a
> +	  group's parent while flat hierarchy will threat all groups as children

typo: 'threat' should be 'treat'

> +	  of the root memcg, regardless of their positioning in the tree.
> +
> +	  Use of flat hierarchies is highly discouraged, but has been the
> +	  default for performance reasons for quite some time. Setting this flag
> +	  to on will make hierarchical accounting the default. It is still
> +	  possible to set it back to flat by writing 0 to the file
> +	  memory.use_hierarchy, albeit discouraged. Distributors are encouraged
> +	  to set this option.
[...]

I don't think that 'default n' is effective encouragement!

Ben.

-- 
Ben Hutchings
We get into the habit of living before acquiring the habit of thinking.
                                                              - Albert Camus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
