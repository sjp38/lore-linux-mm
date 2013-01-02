Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id 414166B0074
	for <linux-mm@kvack.org>; Wed,  2 Jan 2013 11:02:47 -0500 (EST)
Date: Wed, 2 Jan 2013 17:02:39 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCHSET cgroup/for-3.8] cpuset: decouple cpuset locking from
 cgroup core
Message-ID: <20130102160239.GI22160@dhcp22.suse.cz>
References: <1354138460-19286-1-git-send-email-tj@kernel.org>
 <50DAD696.8050400@huawei.com>
 <20130102085355.GA22160@dhcp22.suse.cz>
 <20130102153605.GB11220@mtj.dyndns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130102153605.GB11220@mtj.dyndns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Li Zefan <lizefan@huawei.com>, paul@paulmenage.org, glommer@parallels.com, containers@lists.linux-foundation.org, cgroups@vger.kernel.org, peterz@infradead.org, bsingharora@gmail.com, hannes@cmpxchg.org, kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed 02-01-13 10:36:05, Tejun Heo wrote:
> Hey, Michal.
> 
> On Wed, Jan 02, 2013 at 09:53:55AM +0100, Michal Hocko wrote:
> > Hi Li,
> > 
> > On Wed 26-12-12 18:51:02, Li Zefan wrote:
> > > I reverted 38d7bee9d24adf4c95676a3dc902827c72930ebb ("cpuset: use N_MEMORY instead N_HIGH_MEMORY")
> > > and applied this patchset against 3.8-rc1.
> > 
> > I didn't find any patch in this email.
> > Anyway I am wondering how the above patch could cause the stuck you
> > mention below? The patch just renames N_HIGH_MEMORY -> N_MEMORY which
> > should map to the very same constant so there are no functional changes
> > AFAIU.
> 
> Li needed to revert the said patch only to apply the patchset on top
> of 3.8-rc1.  The N_MEMORY patch doesn't have anything to do with the
> problem Li is seeing.

Ohh, ok
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
