Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx109.postini.com [74.125.245.109])
	by kanga.kvack.org (Postfix) with SMTP id 472206B000A
	for <linux-mm@kvack.org>; Tue, 29 Jan 2013 04:15:42 -0500 (EST)
Message-ID: <5107934E.1070102@parallels.com>
Date: Tue, 29 Jan 2013 13:15:58 +0400
From: Lord Glauber Costa of Sealand <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 1/6] memcg: refactor swap_cgroup_swapon()
References: <510658E6.9030108@oracle.com>
In-Reply-To: <510658E6.9030108@oracle.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeff Liu <jeff.liu@oracle.com>
Cc: linux-mm@kvack.org, Michal Hocko <mhocko@suse.cz>, cgroups@vger.kernel.org

On 01/28/2013 02:54 PM, Jeff Liu wrote:
> Refector swap_cgroup_swapon() to setup the number of pages only, and
> move the rest to swap_cgroup_prepare(), so that the later can be used
> for allocating buffers when creating the first non-root memcg.
> 
> Signed-off-by: Jie Liu <jeff.liu@oracle.com>
> CC: Glauber Costa <glommer@parallels.com>
> CC: Michal Hocko <mhocko@suse.cz>
> CC: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> CC: Johannes Weiner <hannes@cmpxchg.org>
> CC: Mel Gorman <mgorman@suse.de>
> CC: Andrew Morton <akpm@linux-foundation.org>
> CC: Sha Zhengju <handai.szj@taobao.com>
> 

In itself seems just like a healthy reshuffling to me

So looks good.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
