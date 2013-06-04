Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id 688BA6B0032
	for <linux-mm@kvack.org>; Tue,  4 Jun 2013 16:51:28 -0400 (EDT)
Received: by mail-pa0-f53.google.com with SMTP id kq13so540337pab.26
        for <linux-mm@kvack.org>; Tue, 04 Jun 2013 13:51:27 -0700 (PDT)
Date: Tue, 4 Jun 2013 13:51:23 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 2/3] memcg: restructure mem_cgroup_iter()
Message-ID: <20130604205123.GH14916@htj.dyndns.org>
References: <1370306679-13129-1-git-send-email-tj@kernel.org>
 <1370306679-13129-3-git-send-email-tj@kernel.org>
 <20130604132120.GG31242@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130604132120.GG31242@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: hannes@cmpxchg.org, bsingharora@gmail.com, cgroups@vger.kernel.org, linux-mm@kvack.org, lizefan@huawei.com

On Tue, Jun 04, 2013 at 03:21:20PM +0200, Michal Hocko wrote:
> > +	/* non reclaim case is simple - just iterate from @prev */
> > +	if (!reclaim) {
> > +		memcg = __mem_cgroup_iter_next(root, prev);
> > +		goto out_unlock;
> > +	}
> 
> I do not have objections for pulling !reclaim case like this, but could
> you base this on top of the patch which adds predicates into the
> operators, please?

I don't really mind either ways but let's see how the other series
goes.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
