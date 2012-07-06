Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx126.postini.com [74.125.245.126])
	by kanga.kvack.org (Postfix) with SMTP id C73586B0074
	for <linux-mm@kvack.org>; Fri,  6 Jul 2012 04:44:54 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so17221141pbb.14
        for <linux-mm@kvack.org>; Fri, 06 Jul 2012 01:44:54 -0700 (PDT)
Date: Fri, 6 Jul 2012 16:44:15 +0800
From: Wanpeng Li <liwp.linux@gmail.com>
Subject: Re: [PATCH] mm/memcg: add BUG() to mem_cgroup_reset
Message-ID: <20120706084415.GB9319@kernel>
Reply-To: Wanpeng Li <liwp.linux@gmail.com>
References: <1341546297-6223-1-git-send-email-liwp.linux@gmail.com>
 <20120706082242.GA1230@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120706082242.GA1230@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wanpeng Li <liwp.linux@gmail.com>

On Fri, Jul 06, 2012 at 10:22:42AM +0200, Johannes Weiner wrote:
>On Fri, Jul 06, 2012 at 11:44:57AM +0800, Wanpeng Li wrote:
>> From: Wanpeng Li <liwp@linux.vnet.ibm.com>
>> 
>> Branch in mem_cgroup_reset only can be RES_MAX_USAGE, RES_FAILCNT.
>
>And nobody is passing anything else.  Which is easy to prove as this
>is a private function.  And there wouldn't even be any harm passing
>something else.  Please don't add stuff like this.

Ok, thank you for your comment.

I also have another two patches, title:

clarify type in memory cgroups
return -EBUSY when oom-kill-disable modified and memcg use_hierarchy, has children

Hopefully, you can review. Thank you Johannes! :-)

Regards,
Wanpeng Li 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
