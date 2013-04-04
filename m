Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx178.postini.com [74.125.245.178])
	by kanga.kvack.org (Postfix) with SMTP id CEFF46B008C
	for <linux-mm@kvack.org>; Thu,  4 Apr 2013 03:07:01 -0400 (EDT)
Date: Thu, 4 Apr 2013 09:06:57 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] memcg: fix memcg_cache_name() to use cgroup_name()
Message-ID: <20130404070657.GA29911@dhcp22.suse.cz>
References: <1364373399-17397-1-git-send-email-mhocko@suse.cz>
 <20130327145727.GD29052@cmpxchg.org>
 <20130327151104.GK16579@dhcp22.suse.cz>
 <51530E1E.3010100@parallels.com>
 <20130327153220.GL16579@dhcp22.suse.cz>
 <20130327173223.GQ16579@dhcp22.suse.cz>
 <20130328074814.GA3018@dhcp22.suse.cz>
 <20130402082648.GB24345@dhcp22.suse.cz>
 <20130403213334.GE3411@htj.dyndns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130403213334.GE3411@htj.dyndns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Glauber Costa <glommer@parallels.com>, Li Zefan <lizefan@huawei.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed 03-04-13 14:33:34, Tejun Heo wrote:
> On Tue, Apr 02, 2013 at 10:26:48AM +0200, Michal Hocko wrote:
> > Tejun,
> > could you take this one please?
> 
> Aye aye, applied to cgroup/for-3.10.

Thanks!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
