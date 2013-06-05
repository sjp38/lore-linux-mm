Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx184.postini.com [74.125.245.184])
	by kanga.kvack.org (Postfix) with SMTP id 1B40F6B0034
	for <linux-mm@kvack.org>; Wed,  5 Jun 2013 05:03:30 -0400 (EDT)
Received: by mail-pa0-f43.google.com with SMTP id hz11so13180pad.2
        for <linux-mm@kvack.org>; Wed, 05 Jun 2013 02:03:29 -0700 (PDT)
Date: Wed, 5 Jun 2013 02:03:26 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 3/3] memcg: simplify mem_cgroup_reclaim_iter
Message-ID: <20130605090326.GC7990@mtj.dyndns.org>
References: <1370306679-13129-4-git-send-email-tj@kernel.org>
 <20130604131843.GF31242@dhcp22.suse.cz>
 <20130604205025.GG14916@htj.dyndns.org>
 <20130604212808.GB13231@dhcp22.suse.cz>
 <20130604215535.GM14916@htj.dyndns.org>
 <20130605073023.GB15997@dhcp22.suse.cz>
 <20130605082023.GG7303@mtj.dyndns.org>
 <20130605083628.GE15997@dhcp22.suse.cz>
 <20130605084456.GA7990@mtj.dyndns.org>
 <20130605085531.GG15997@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130605085531.GG15997@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: hannes@cmpxchg.org, bsingharora@gmail.com, cgroups@vger.kernel.org, linux-mm@kvack.org, lizefan@huawei.com

Hey,

On Wed, Jun 05, 2013 at 10:55:31AM +0200, Michal Hocko wrote:
> > Yeah, that's true.  I just wanna avoid the barrier dancing.  Only one
> > of the ancestors can cache a memcg, right?
> 
> No. All of them on the way up hierarchy. Basically each parent which
> ever triggered the reclaim caches reclaimers.

Oh, I meant only the ancestors can cache a memcg, so yeap.

> > Walking up the tree scanning for cached ones and putting them should
> > work?  Is that what you were suggesting?
> 
> That was my first version of the patch I linked in the previous email.

Yeah, indeed.  Johannes, what do you think?  Between the recent cgroup
iterator update and xchg(), we don't need the weak referencing and
it's just wrong to have that level of complexity in memcg proper.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
