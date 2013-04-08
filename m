Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx132.postini.com [74.125.245.132])
	by kanga.kvack.org (Postfix) with SMTP id C3D346B010B
	for <linux-mm@kvack.org>; Mon,  8 Apr 2013 11:39:47 -0400 (EDT)
Received: by mail-da0-f42.google.com with SMTP id n15so2660648dad.15
        for <linux-mm@kvack.org>; Mon, 08 Apr 2013 08:39:47 -0700 (PDT)
Date: Mon, 8 Apr 2013 08:39:42 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 1/8] cgroup: implement cgroup_is_ancestor()
Message-ID: <20130408153942.GC3021@htj.dyndns.org>
References: <51627DA9.7020507@huawei.com>
 <51627DBB.5050005@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <51627DBB.5050005@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li Zefan <lizefan@huawei.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Glauber Costa <glommer@parallels.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, Cgroups <cgroups@vger.kernel.org>, linux-mm@kvack.org

Hello, Li.

On Mon, Apr 08, 2013 at 04:20:11PM +0800, Li Zefan wrote:
> +/**
> + * cgroup_is_ancestor - test "root" cgroup is an ancestor of "child"
> + * @child: the cgroup to be tested.
> + * @root: the cgroup supposed to be an ancestor of the child.

Please explain locking in the comment.  (I know it only requires both
cgroups to be accessible but being explicit is nice.)

> + * Returns true if "root" is an ancestor of "child" in its hierarchy.
> + */
> +bool cgroup_is_ancestor(struct cgroup *child, struct cgroup *root)

s/root/ancestor/

> +{
> +	int depth = child->depth;
> +
> +	if (depth < root->depth)
> +		return false;
> +
> +	while (depth-- != root->depth)
> +		child = child->parent;

Just walk up till it meets the ancestor or reaches root.  Why bother
with depth?

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
