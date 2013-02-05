Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx172.postini.com [74.125.245.172])
	by kanga.kvack.org (Postfix) with SMTP id EA4B96B0005
	for <linux-mm@kvack.org>; Tue,  5 Feb 2013 13:16:27 -0500 (EST)
Date: Tue, 5 Feb 2013 13:16:17 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 3/3] memcg: cleanup mem_cgroup_init comment
Message-ID: <20130205181617.GC993@cmpxchg.org>
References: <1360081441-1960-1-git-send-email-mhocko@suse.cz>
 <1360081441-1960-4-git-send-email-mhocko@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1360081441-1960-4-git-send-email-mhocko@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Tejun Heo <htejun@gmail.com>

On Tue, Feb 05, 2013 at 05:24:01PM +0100, Michal Hocko wrote:
> We should encourage all memcg controller initialization independent on
> a specific mem_cgroup to be done here rather than exploit css_alloc
> callback and assume that nothing happens before root cgroup is created.
> 
> Signed-off-by: Michal Hocko <mhocko@suse.cz>

It seems a little strange to document that the subsystem init function
should be used for initializing the subsystem.  But your new comment
is better than the old comment :-)

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
