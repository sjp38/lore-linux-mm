Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx103.postini.com [74.125.245.103])
	by kanga.kvack.org (Postfix) with SMTP id 0F9FB6B0006
	for <linux-mm@kvack.org>; Wed, 27 Mar 2013 12:21:03 -0400 (EDT)
Received: by mail-qa0-f52.google.com with SMTP id bs12so997806qab.18
        for <linux-mm@kvack.org>; Wed, 27 Mar 2013 09:21:03 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20130327161905.GN16579@dhcp22.suse.cz>
References: <1364373399-17397-1-git-send-email-mhocko@suse.cz>
	<20130327161527.GA7395@htj.dyndns.org>
	<20130327161905.GN16579@dhcp22.suse.cz>
Date: Wed, 27 Mar 2013 09:21:02 -0700
Message-ID: <CAOS58YPsrZNU9qDeMgJG3-Hkn0cBaigz16eTS5M57G95E8fxUQ@mail.gmail.com>
Subject: Re: [PATCH] memcg: fix memcg_cache_name() to use cgroup_name()
From: Tejun Heo <tj@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Glauber Costa <glommer@parallels.com>, Li Zefan <lizefan@huawei.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed, Mar 27, 2013 at 9:19 AM, Michal Hocko <mhocko@suse.cz> wrote:
>> Maybe the name could signify it's part of memcg?
>
> kmem_ prefix is used for all CONFIG_MEMCG_KMEM functions. I understand
> it clashes with sl?b naming but this is out of scope of this patch IMO.

Oh, it's not using kmemcg? I see. Maybe we can rename later.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
