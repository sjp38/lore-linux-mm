Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx159.postini.com [74.125.245.159])
	by kanga.kvack.org (Postfix) with SMTP id 45B2B6B0005
	for <linux-mm@kvack.org>; Wed,  3 Apr 2013 17:33:42 -0400 (EDT)
Received: by mail-pa0-f49.google.com with SMTP id kp14so1113443pab.22
        for <linux-mm@kvack.org>; Wed, 03 Apr 2013 14:33:41 -0700 (PDT)
Date: Wed, 3 Apr 2013 14:33:34 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH] memcg: fix memcg_cache_name() to use cgroup_name()
Message-ID: <20130403213334.GE3411@htj.dyndns.org>
References: <1364373399-17397-1-git-send-email-mhocko@suse.cz>
 <20130327145727.GD29052@cmpxchg.org>
 <20130327151104.GK16579@dhcp22.suse.cz>
 <51530E1E.3010100@parallels.com>
 <20130327153220.GL16579@dhcp22.suse.cz>
 <20130327173223.GQ16579@dhcp22.suse.cz>
 <20130328074814.GA3018@dhcp22.suse.cz>
 <20130402082648.GB24345@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130402082648.GB24345@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Glauber Costa <glommer@parallels.com>, Li Zefan <lizefan@huawei.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue, Apr 02, 2013 at 10:26:48AM +0200, Michal Hocko wrote:
> Tejun,
> could you take this one please?

Aye aye, applied to cgroup/for-3.10.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
