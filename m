Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx178.postini.com [74.125.245.178])
	by kanga.kvack.org (Postfix) with SMTP id 6E57D6B006C
	for <linux-mm@kvack.org>; Wed,  2 Jan 2013 10:36:09 -0500 (EST)
Received: by mail-qa0-f48.google.com with SMTP id l8so8872678qaq.7
        for <linux-mm@kvack.org>; Wed, 02 Jan 2013 07:36:08 -0800 (PST)
Date: Wed, 2 Jan 2013 10:36:05 -0500
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCHSET cgroup/for-3.8] cpuset: decouple cpuset locking from
 cgroup core
Message-ID: <20130102153605.GB11220@mtj.dyndns.org>
References: <1354138460-19286-1-git-send-email-tj@kernel.org>
 <50DAD696.8050400@huawei.com>
 <20130102085355.GA22160@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130102085355.GA22160@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Li Zefan <lizefan@huawei.com>, paul@paulmenage.org, glommer@parallels.com, containers@lists.linux-foundation.org, cgroups@vger.kernel.org, peterz@infradead.org, bsingharora@gmail.com, hannes@cmpxchg.org, kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hey, Michal.

On Wed, Jan 02, 2013 at 09:53:55AM +0100, Michal Hocko wrote:
> Hi Li,
> 
> On Wed 26-12-12 18:51:02, Li Zefan wrote:
> > I reverted 38d7bee9d24adf4c95676a3dc902827c72930ebb ("cpuset: use N_MEMORY instead N_HIGH_MEMORY")
> > and applied this patchset against 3.8-rc1.
> 
> I didn't find any patch in this email.
> Anyway I am wondering how the above patch could cause the stuck you
> mention below? The patch just renames N_HIGH_MEMORY -> N_MEMORY which
> should map to the very same constant so there are no functional changes
> AFAIU.

Li needed to revert the said patch only to apply the patchset on top
of 3.8-rc1.  The N_MEMORY patch doesn't have anything to do with the
problem Li is seeing.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
