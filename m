Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx186.postini.com [74.125.245.186])
	by kanga.kvack.org (Postfix) with SMTP id 599AA6B003B
	for <linux-mm@kvack.org>; Mon,  8 Apr 2013 14:03:49 -0400 (EDT)
Received: by mail-we0-f171.google.com with SMTP id d46so4818366wer.30
        for <linux-mm@kvack.org>; Mon, 08 Apr 2013 11:03:47 -0700 (PDT)
Date: Mon, 8 Apr 2013 20:03:44 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 1/8] cgroup: implement cgroup_is_ancestor()
Message-ID: <20130408180335.GA22512@dhcp22.suse.cz>
References: <51627DA9.7020507@huawei.com>
 <51627DBB.5050005@huawei.com>
 <20130408144750.GK17178@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130408144750.GK17178@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li Zefan <lizefan@huawei.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Glauber Costa <glommer@parallels.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, Cgroups <cgroups@vger.kernel.org>, linux-mm@kvack.org

On Mon 08-04-13 16:47:50, Michal Hocko wrote:
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

And as it turned out using css_is_ancestor is not correct. Here
is a patch to fix the issue. I will leave the decision whether
cgroup_is_ancestor makes sense even without users to you.
Would you be willing to take this into your current series so that we to
not clash over that code?
---
