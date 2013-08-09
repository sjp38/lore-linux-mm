Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id EBCC06B0033
	for <linux-mm@kvack.org>; Fri,  9 Aug 2013 10:19:39 -0400 (EDT)
Received: by mail-qc0-f177.google.com with SMTP id e11so2176701qcx.22
        for <linux-mm@kvack.org>; Fri, 09 Aug 2013 07:19:38 -0700 (PDT)
Date: Fri, 9 Aug 2013 10:19:33 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [HEADSUP] conflicts between cgroup/for-3.12 and memcg
Message-ID: <20130809141933.GG20515@mtj.dyndns.org>
References: <20130809003402.GC13427@mtj.dyndns.org>
 <20130809072207.GA16531@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130809072207.GA16531@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, sfr@canb.auug.org.au, linux-next@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Balbir Singh <bsingharora@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, cgroups@vger.kernel.org, linux-mm@kvack.org

Hello, Michal.

On Fri, Aug 09, 2013 at 09:22:07AM +0200, Michal Hocko wrote:
> I have just tried to merge cgroups/for-3.12 into my memcg tree and there
> were some conflicts indeed. They are attached for reference. The
> resolving is trivial. I've just picked up HEAD as all the conflicts are
> for added resp. removed code in mmotm.

Oops, that's me messing up the branches.  I was trying to reset
for-next but instead reset for-3.12 so that it didn't include the API
updates.  Can you please try to rebase on top of the current for-3.12
bd8815a6d802fc16a7a106e170593aa05dc17e72 ("cgroup: make
css_for_each_descendant() and friends include the origin css in the
iteration")?  At least the iterator update wouldn't be trivial, I
think.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
