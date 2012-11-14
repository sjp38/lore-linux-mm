Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id ACAED6B0092
	for <linux-mm@kvack.org>; Wed, 14 Nov 2012 13:52:50 -0500 (EST)
Received: by mail-da0-f41.google.com with SMTP id i14so336144dad.14
        for <linux-mm@kvack.org>; Wed, 14 Nov 2012 10:52:50 -0800 (PST)
Date: Wed, 14 Nov 2012 10:52:45 -0800
From: Tejun Heo <htejun@gmail.com>
Subject: Re: [RFC 2/5] memcg: rework mem_cgroup_iter to use cgroup iterators
Message-ID: <20121114185245.GF21185@mtj.dyndns.org>
References: <1352820639-13521-1-git-send-email-mhocko@suse.cz>
 <1352820639-13521-3-git-send-email-mhocko@suse.cz>
 <20121113161442.GA18227@mtj.dyndns.org>
 <20121114085129.GC17111@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121114085129.GC17111@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Ying Han <yinghan@google.com>, Glauber Costa <glommer@parallels.com>

Hello, Michal.

On Wed, Nov 14, 2012 at 09:51:29AM +0100, Michal Hocko wrote:
> > 	reclaim(root);
> > 	for_each_descendent_pre()
> > 		reclaim(descendant);
> 
> We cannot do for_each_descendent_pre here because we do not iterate
> through the whole hierarchy all the time. Check shrink_zone.

I'm a bit confused.  Why would that make any difference?  Shouldn't it
be just able to test the condition and continue?

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
