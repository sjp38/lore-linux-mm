From: Li Zefan <lizf@cn.fujitsu.com>
Subject: Re: [PATCH 3/4] cpuset: Fix unchecked calls to NODEMASK_ALLOC()
Date: Mon, 21 Feb 2011 13:30:30 +0800
Message-ID: <4D61F876.3040401@cn.fujitsu.com>
References: <4D5C7EA7.1030409@cn.fujitsu.com> <4D5C7ED1.2070601@cn.fujitsu.com> <alpine.DEB.2.00.1102191745180.27722@chino.kir.corp.google.com> <4D61DA04.4060007@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4D61DA04.4060007@cn.fujitsu.com>
Sender: linux-kernel-owner@vger.kernel.org
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Paul Menage <menage@google.com>, miaox@cn.fujitsu.com, linux-mm@kvack.org
List-Id: linux-mm.kvack.org

> +/*
> + * Calling cpuset_static_nodemask() should be paired with this function,
> + * so we insure the global nodemask won't be used by more than one user
> + * at the one time.
> + */
> +static void cpuset_release_static_nodemask(void)
> +{
> +	WARN_ON(!cgroup_lock_is_held());
> +
> +	cpuset_mems_ref--;
> +	WARN_ON(!cpuset_mems_ref);

WARN_ON(cpuset_mems_ref);

> +}
