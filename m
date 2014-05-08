Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f44.google.com (mail-ee0-f44.google.com [74.125.83.44])
	by kanga.kvack.org (Postfix) with ESMTP id 008C86B0117
	for <linux-mm@kvack.org>; Thu,  8 May 2014 14:30:07 -0400 (EDT)
Received: by mail-ee0-f44.google.com with SMTP id c41so1941242eek.31
        for <linux-mm@kvack.org>; Thu, 08 May 2014 11:30:07 -0700 (PDT)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id v2si2250531eel.136.2014.05.08.11.30.06
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 08 May 2014 11:30:06 -0700 (PDT)
Date: Thu, 8 May 2014 14:30:04 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 4/9] mm: memcontrol: catch root bypass in move precharge
Message-ID: <20140508183004.GQ19914@cmpxchg.org>
References: <1398889543-23671-1-git-send-email-hannes@cmpxchg.org>
 <1398889543-23671-5-git-send-email-hannes@cmpxchg.org>
 <20140507145553.GJ9489@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140507145553.GJ9489@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, Hugh Dickins <hughd@google.com>, Tejun Heo <tj@kernel.org>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed, May 07, 2014 at 04:55:53PM +0200, Michal Hocko wrote:
> On Wed 30-04-14 16:25:38, Johannes Weiner wrote:
> [...]
> > @@ -6546,8 +6546,9 @@ one_by_one:
> >  			cond_resched();
> >  		}
> >  		ret = mem_cgroup_try_charge(memcg, GFP_KERNEL, 1, false);
> > +		if (ret == -EINTR)
> > +			__mem_cgroup_cancel_charge(root_mem_cgroup, 1);
> >  		if (ret)
> > -			/* mem_cgroup_clear_mc() will do uncharge later */
> 
> I would prefer to keep the comment and explain that we will loose return
> code on the way and that is why cancel on root has to be done here.

That makes sense, I'll add an explanation of who is (un)charged when
and where.  Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
