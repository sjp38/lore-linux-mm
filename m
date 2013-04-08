Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx111.postini.com [74.125.245.111])
	by kanga.kvack.org (Postfix) with SMTP id ED60F8D0001
	for <linux-mm@kvack.org>; Mon,  8 Apr 2013 11:57:33 -0400 (EDT)
Received: by mail-pa0-f47.google.com with SMTP id bj3so3331122pad.20
        for <linux-mm@kvack.org>; Mon, 08 Apr 2013 08:57:33 -0700 (PDT)
Date: Mon, 8 Apr 2013 08:57:26 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 1/8] cgroup: implement cgroup_is_ancestor()
Message-ID: <20130408155726.GG3021@htj.dyndns.org>
References: <51627DA9.7020507@huawei.com>
 <51627DBB.5050005@huawei.com>
 <20130408144750.GK17178@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130408144750.GK17178@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Li Zefan <lizefan@huawei.com>, Andrew Morton <akpm@linux-foundation.org>, Glauber Costa <glommer@parallels.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, Cgroups <cgroups@vger.kernel.org>, linux-mm@kvack.org

Hello,

On Mon, Apr 08, 2013 at 04:47:50PM +0200, Michal Hocko wrote:
> On Mon 08-04-13 16:20:11, Li Zefan wrote:
> [...]
> > @@ -5299,6 +5300,26 @@ struct cgroup_subsys_state *cgroup_css_from_dir(struct file *f, int id)
> >  	return css ? css : ERR_PTR(-ENOENT);
> >  }
> >  
> > +/**
> > + * cgroup_is_ancestor - test "root" cgroup is an ancestor of "child"
> > + * @child: the cgroup to be tested.
> > + * @root: the cgroup supposed to be an ancestor of the child.
> > + *
> > + * Returns true if "root" is an ancestor of "child" in its hierarchy.
> > + */
> > +bool cgroup_is_ancestor(struct cgroup *child, struct cgroup *root)
> > +{
> > +	int depth = child->depth;
> 
> Is this functionality helpful for other controllers but memcg?
> css_is_ancestor is currently used only by memcg code AFAICS and we can
> get the same functionality easily by using something like:

It's a basic hierarchy operation.  I'd prefer it to be in cgroup and
in general let's try to avoid memcg-specific infrastructure.  It
doesn't seem to end well.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
