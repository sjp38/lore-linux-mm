Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx184.postini.com [74.125.245.184])
	by kanga.kvack.org (Postfix) with SMTP id 43B866B0008
	for <linux-mm@kvack.org>; Tue,  5 Feb 2013 13:13:25 -0500 (EST)
Date: Tue, 5 Feb 2013 13:13:11 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 2/3] memcg: move memcg_stock initialization to
 mem_cgroup_init
Message-ID: <20130205181311.GB993@cmpxchg.org>
References: <1360081441-1960-1-git-send-email-mhocko@suse.cz>
 <1360081441-1960-3-git-send-email-mhocko@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1360081441-1960-3-git-send-email-mhocko@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Tejun Heo <htejun@gmail.com>

On Tue, Feb 05, 2013 at 05:24:00PM +0100, Michal Hocko wrote:
> memcg_stock are currently initialized during the root cgroup allocation
> which is OK but it pointlessly pollutes memcg allocation code with
> something that can be called when the memcg subsystem is initialized by
> mem_cgroup_init along with other controller specific parts.
> 
> This patch wrappes the current memcg_stock initialization code into a
> helper calls it from the controller subsystem initialization code.
> 
> Signed-off-by: Michal Hocko <mhocko@suse.cz>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
