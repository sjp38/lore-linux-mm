Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx200.postini.com [74.125.245.200])
	by kanga.kvack.org (Postfix) with SMTP id 9E0596B0031
	for <linux-mm@kvack.org>; Wed,  5 Jun 2013 05:07:42 -0400 (EDT)
Date: Wed, 5 Jun 2013 11:07:39 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch -v4 4/8] memcg: enhance memcg iterator to support
 predicates
Message-ID: <20130605090739.GH15997@dhcp22.suse.cz>
References: <1370254735-13012-5-git-send-email-mhocko@suse.cz>
 <20130604010737.GF29989@mtj.dyndns.org>
 <20130604134523.GH31242@dhcp22.suse.cz>
 <20130604193619.GA14916@htj.dyndns.org>
 <20130604204807.GA13231@dhcp22.suse.cz>
 <20130604205426.GI14916@htj.dyndns.org>
 <20130605073728.GC15997@dhcp22.suse.cz>
 <20130605080545.GF7303@mtj.dyndns.org>
 <20130605085239.GF15997@dhcp22.suse.cz>
 <20130605085849.GB7990@mtj.dyndns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130605085849.GB7990@mtj.dyndns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, Ying Han <yinghan@google.com>, Hugh Dickins <hughd@google.com>, Glauber Costa <glommer@parallels.com>, Michel Lespinasse <walken@google.com>, Greg Thelen <gthelen@google.com>, Balbir Singh <bsingharora@gmail.com>

On Wed 05-06-13 01:58:49, Tejun Heo wrote:
[...]
> Anyways, so you aren't gonna try the skipping thing?

As I said. I do not consider this a priority for the said reasons (i
will not repeat them).
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
