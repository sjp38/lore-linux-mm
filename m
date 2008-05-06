Message-ID: <481FB50D.1070308@cn.fujitsu.com>
Date: Tue, 06 May 2008 09:31:57 +0800
From: Li Zefan <lizf@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [-mm][PATCH 1/4] Setup the rlimit controller
References: <20080503213726.3140.68845.sendpatchset@localhost.localdomain> <20080503213736.3140.83278.sendpatchset@localhost.localdomain>
In-Reply-To: <20080503213736.3140.83278.sendpatchset@localhost.localdomain>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Paul Menage <menage@google.com>, linux-kernel@vger.kernel.org, David Rientjes <rientjes@google.com>, Pavel Emelianov <xemul@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Balbir Singh wrote:
> +struct cgroup_subsys rlimit_cgroup_subsys;
> +
> +struct rlimit_cgroup {
> +	struct cgroup_subsys_state css;
> +	struct res_counter as_res;	/* address space counter */
> +};
> +
> +static struct rlimit_cgroup init_rlimit_cgroup;
> +
> +struct rlimit_cgroup *rlimit_cgroup_from_cgrp(struct cgroup *cgrp)

It can be static if I don't miss anything.

> +{
> +	return container_of(cgroup_subsys_state(cgrp, rlimit_cgroup_subsys_id),
> +				struct rlimit_cgroup, css);
> +}
> +

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
