Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx196.postini.com [74.125.245.196])
	by kanga.kvack.org (Postfix) with SMTP id 6FA8C6B0070
	for <linux-mm@kvack.org>; Wed, 14 Nov 2012 03:40:17 -0500 (EST)
Date: Wed, 14 Nov 2012 09:40:14 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [RFC] rework mem_cgroup iterator
Message-ID: <20121114084014.GB17111@dhcp22.suse.cz>
References: <1352820639-13521-1-git-send-email-mhocko@suse.cz>
 <50A3C42F.9020901@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <50A3C42F.9020901@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Ying Han <yinghan@google.com>, Tejun Heo <htejun@gmail.com>

On Wed 14-11-12 17:17:51, Glauber Costa wrote:
[...]
> Why can't we reuse the scheduler iterator and move it to kernel/cgroup.c?

I do not care much about the internal implementation of the core
iterators. Those implemented by Tejun make sense to me. I just want to
get rid of css->id based ones.

Memcg iterator, however, still needs its own iterator on top because we
have to handle the parallel reclaimers.
[...]
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
