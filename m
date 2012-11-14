Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id 3839E6B0070
	for <linux-mm@kvack.org>; Wed, 14 Nov 2012 13:30:13 -0500 (EST)
Received: by mail-da0-f41.google.com with SMTP id i14so327640dad.14
        for <linux-mm@kvack.org>; Wed, 14 Nov 2012 10:30:12 -0800 (PST)
Date: Wed, 14 Nov 2012 10:30:07 -0800
From: Tejun Heo <htejun@gmail.com>
Subject: Re: [RFC] rework mem_cgroup iterator
Message-ID: <20121114183007.GC21185@mtj.dyndns.org>
References: <1352820639-13521-1-git-send-email-mhocko@suse.cz>
 <50A2F9FC.5050303@huawei.com>
 <20121114083653.GA17111@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121114083653.GA17111@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Li Zefan <lizefan@huawei.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Ying Han <yinghan@google.com>, Glauber Costa <glommer@parallels.com>

Hello, Michal.

On Wed, Nov 14, 2012 at 09:36:53AM +0100, Michal Hocko wrote:
> > So memcg won't use css id at all, right?
> 
> Unfortunately we still use it for the swap accounting but that one could
> be replaced by something else, probably. Have to think about it.

I have a patch to add cgrp->id pending.  From what I can see, memcg
should be able to use that for swap accounting.

> > Then we can remove the whole css_id stuff, and that's quite a bunch of
> > code.

Yeap, that's the plan.

> Is memcg the only user of css_id? Quick grep shows that yes but I
> haven't checked all the callers of the exported functions. I would be
> happy if more code goes away.

Yeap, memcg is the only user and I really wanna remove it once memcg
moves onto saner stuff.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
