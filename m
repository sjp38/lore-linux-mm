Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id E9C936B0033
	for <linux-mm@kvack.org>; Tue,  4 Jun 2013 17:55:38 -0400 (EDT)
Received: by mail-pb0-f42.google.com with SMTP id uo1so836524pbc.15
        for <linux-mm@kvack.org>; Tue, 04 Jun 2013 14:55:38 -0700 (PDT)
Date: Tue, 4 Jun 2013 14:55:35 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 3/3] memcg: simplify mem_cgroup_reclaim_iter
Message-ID: <20130604215535.GM14916@htj.dyndns.org>
References: <1370306679-13129-1-git-send-email-tj@kernel.org>
 <1370306679-13129-4-git-send-email-tj@kernel.org>
 <20130604131843.GF31242@dhcp22.suse.cz>
 <20130604205025.GG14916@htj.dyndns.org>
 <20130604212808.GB13231@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130604212808.GB13231@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: hannes@cmpxchg.org, bsingharora@gmail.com, cgroups@vger.kernel.org, linux-mm@kvack.org, lizefan@huawei.com

Hello, Michal.

On Tue, Jun 04, 2013 at 11:28:08PM +0200, Michal Hocko wrote:
> Well, I do not mind pinning when I know that somebody releases the
> reference in a predictable future (ideally almost immediately). But the
> cached iter represents time unbounded pinning because nobody can
> guarantee that priority 3 at zone Normal at node 3 will be ever scanned
> again and the pointer in the last_visited node will be stuck there for

I don't really get that.  As long as the amount is bound and the
overhead negligible / acceptable, why does it matter how long the
pinning persists?  We aren't talking about something gigantic or can
leak continuously.  It will only matter iff cgroups are continuously
created and destroyed and each live memcg will be able to pin one
memcg (BTW, I think I forgot to unpin on memcg destruction).

> eternity. Can we free memcg with only css elevated and safely check that
> the cached pointer can be used without similar dances we have now?
> I am open to any suggestions.

I really think this is worrying too much about something which doesn't
really matter and then coming up with an over-engineered solution for
the imagined problem.  This isn't a real problem.  No solution is
necessary.

In the off chance that this is a real problem, which I strongly doubt,
as I wrote to Johannes, we can implement extremely dumb cleanup
routine rather than this weak reference beast.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
