Message-ID: <4920F70D.9030100@cn.fujitsu.com>
Date: Mon, 17 Nov 2008 12:46:05 +0800
From: Li Zefan <lizf@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [mm] [PATCH 4/4] Memory cgroup hierarchy feature selector (v4)
References: <20081116081034.25166.7586.sendpatchset@balbir-laptop> <20081116081105.25166.54820.sendpatchset@balbir-laptop>
In-Reply-To: <20081116081105.25166.54820.sendpatchset@balbir-laptop>
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Paul Menage <menage@google.com>, linux-kernel@vger.kernel.org, Nick Piggin <nickpiggin@yahoo.com.au>, David Rientjes <rientjes@google.com>, Pavel Emelianov <xemul@openvz.org>, Dhaval Giani <dhaval@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

> +	/*
> +	 * If parent's use_hiearchy is set, we can't make any modifications
> +	 * in the child subtrees. If it is unset, then the change can
> +	 * occur, provided the current cgroup has no children.
> +	 *
> +	 * For the root cgroup, parent_mem is NULL, we allow value to be
> +	 * set if there are no children.
> +	 */
> +	if (!parent_mem || (!parent_mem->use_hierarchy &&
> +				(val == 1 || val == 0))) {

Should be :

if ((!parent_mem || !parent_mem->use_hierarchy) &&
    (val == 1 || val == 0)) {

> +		if (list_empty(&cont->children))
> +			mem->use_hierarchy = val;
> +		else
> +			retval = -EBUSY;
> +	} else
> +		retval = -EINVAL;
> +	cgroup_unlock();
> +
> +	return retval;
> +}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
