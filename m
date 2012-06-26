Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx170.postini.com [74.125.245.170])
	by kanga.kvack.org (Postfix) with SMTP id ABA426B005A
	for <linux-mm@kvack.org>; Tue, 26 Jun 2012 15:57:06 -0400 (EDT)
Date: Tue, 26 Jun 2012 21:56:47 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: + memcg-rename-config-variables.patch added to -mm tree
Message-ID: <20120626195647.GG27816@cmpxchg.org>
References: <20120626192108.2BB7FA0329@akpm.mtv.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120626192108.2BB7FA0329@akpm.mtv.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mm-commits@vger.kernel.org, aneesh.kumar@linux.vnet.ibm.com, glommer@parallels.com, hughd@google.com, kamezawa.hiroyu@jp.fujitsu.com, kosaki.motohiro@jp.fujitsu.com, mhocko@suse.cz, rientjes@google.com, tj@kernel.org, linux-mm@kvack.org

On Tue, Jun 26, 2012 at 12:21:07PM -0700, akpm@linux-foundation.org wrote:
> 
> The patch titled
>      Subject: memcg: rename config variables
> has been added to the -mm tree.  Its filename is
>      memcg-rename-config-variables.patch
> 
> Before you just go and hit "reply", please:
>    a) Consider who else should be cc'ed
>    b) Prefer to cc a suitable mailing list as well
>    c) Ideally: find the original patch on the mailing list and do a
>       reply-to-all to that, adding suitable additional cc's
> 
> *** Remember to use Documentation/SubmitChecklist when testing your code ***
> 
> The -mm tree is included into linux-next and is updated
> there every 3-4 working days
> 
> ------------------------------------------------------
> From: Andrew Morton <akpm@linux-foundation.org>
> Subject: memcg: rename config variables
> 
> Sanity:
> 
> CONFIG_CGROUP_MEM_RES_CTLR -> CONFIG_MEMCG
> CONFIG_CGROUP_MEM_RES_CTLR_SWAP -> CONFIG_MEMCG_SWAP
> CONFIG_CGROUP_MEM_RES_CTLR_SWAP_ENABLED -> CONFIG_MEMCG_SWAP_ENABLED
> CONFIG_CGROUP_MEM_RES_CTLR_KMEM -> CONFIG_MEMCG_KMEM

Yes!  Thank you.

When would be the best time to fix the function/variable namespace? :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
