Message-ID: <49155E45.3030704@cn.fujitsu.com>
Date: Sat, 08 Nov 2008 17:39:17 +0800
From: Li Zefan <lizf@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [RFC][mm] [PATCH 4/4] Memory cgroup hierarchy feature selector
 (v2)
References: <20081108091009.32236.26177.sendpatchset@localhost.localdomain> <20081108091113.32236.12390.sendpatchset@localhost.localdomain>
In-Reply-To: <20081108091113.32236.12390.sendpatchset@localhost.localdomain>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Paul Menage <menage@google.com>, linux-kernel@vger.kernel.org, Nick Piggin <nickpiggin@yahoo.com.au>, David Rientjes <rientjes@google.com>, Pavel Emelianov <xemul@openvz.org>, Dhaval Giani <dhaval@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

> +static int mem_cgroup_hierarchy_write(struct cgroup *cont, struct cftype *cft,
> +					u64 val)
> +{
> +	int retval = 0;
> +	struct mem_cgroup *mem = mem_cgroup_from_cont(cont);
> +
> +	if (val == 1) {
> +		if (list_empty(&cont->children))

cgroup_lock should be held before checking cont->children.

> +			mem->use_hierarchy = val;
> +		else
> +			retval = -EBUSY;
> +	} else if (val == 0) {

And code duplicate.

> +		if (list_empty(&cont->children))
> +			mem->use_hierarchy = val;
> +		else
> +			retval = -EBUSY;
> +	} else
> +		retval = -EINVAL;
> +
> +	return retval;
> +}
> +

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
