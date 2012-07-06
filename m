Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx190.postini.com [74.125.245.190])
	by kanga.kvack.org (Postfix) with SMTP id 63D706B0074
	for <linux-mm@kvack.org>; Fri,  6 Jul 2012 04:22:55 -0400 (EDT)
Date: Fri, 6 Jul 2012 10:22:42 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] mm/memcg: add BUG() to mem_cgroup_reset
Message-ID: <20120706082242.GA1230@cmpxchg.org>
References: <1341546297-6223-1-git-send-email-liwp.linux@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1341546297-6223-1-git-send-email-liwp.linux@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwp.linux@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Jul 06, 2012 at 11:44:57AM +0800, Wanpeng Li wrote:
> From: Wanpeng Li <liwp@linux.vnet.ibm.com>
> 
> Branch in mem_cgroup_reset only can be RES_MAX_USAGE, RES_FAILCNT.

And nobody is passing anything else.  Which is easy to prove as this
is a private function.  And there wouldn't even be any harm passing
something else.  Please don't add stuff like this.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
