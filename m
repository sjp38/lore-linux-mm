Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx190.postini.com [74.125.245.190])
	by kanga.kvack.org (Postfix) with SMTP id ED55E6B0010
	for <linux-mm@kvack.org>; Tue, 29 Jan 2013 04:47:12 -0500 (EST)
Message-ID: <51079AB3.5010406@parallels.com>
Date: Tue, 29 Jan 2013 13:47:31 +0400
From: Lord Glauber Costa of Sealand <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 4/6] memcg: export nr_swap_files
References: <510658F6.4010504@oracle.com>
In-Reply-To: <510658F6.4010504@oracle.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeff Liu <jeff.liu@oracle.com>
Cc: linux-mm@kvack.org, Michal Hocko <mhocko@suse.cz>, cgroups@vger.kernel.org

On 01/28/2013 02:54 PM, Jeff Liu wrote:
> Export nr_swap_files which would be used for initializing and destorying
> swap cgroup structures in the coming patch.
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
Well, nothing fancy here.

Acked-by: Glauber Costa <glommer@parallels.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
