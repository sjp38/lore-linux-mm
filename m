Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx148.postini.com [74.125.245.148])
	by kanga.kvack.org (Postfix) with SMTP id 8581D8D0001
	for <linux-mm@kvack.org>; Fri, 30 Nov 2012 10:37:17 -0500 (EST)
Date: Fri, 30 Nov 2012 16:37:15 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH for 3.2.34] memcg: do not trigger OOM from
 add_to_page_cache_locked
Message-ID: <20121130153715.GK29317@dhcp22.suse.cz>
References: <20121125120524.GB10623@dhcp22.suse.cz>
 <20121125135542.GE10623@dhcp22.suse.cz>
 <20121126013855.AF118F5E@pobox.sk>
 <20121126131837.GC17860@dhcp22.suse.cz>
 <20121126132149.GD17860@dhcp22.suse.cz>
 <20121130032918.59B3F780@pobox.sk>
 <20121130124506.GH29317@dhcp22.suse.cz>
 <20121130144427.51A09169@pobox.sk>
 <20121130144431.GI29317@dhcp22.suse.cz>
 <20121130150347.GJ29317@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121130150347.GJ29317@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: azurIt <azurit@pobox.sk>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups mailinglist <cgroups@vger.kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>

On Fri 30-11-12 16:03:47, Michal Hocko wrote:
[...]
> Anyway, the more interesting thing is gfp_mask is GFP_NOWAIT allocation
> from the page fault? Huh this shouldn't happen - ever.

OK, it starts making sense now. The message came from
pagefault_out_of_memory which doesn't have gfp nor the required node
information any longer. This suggests that VM_FAULT_OOM has been
returned by the fault handler. So this hasn't been triggered by the page
fault allocator.
I am wondering whether this could be caused by the patch but the effect
of that one should be limitted to the write (unlike the later version
for -mm tree which hooks into the shmem as well).

Will have to think about it some more.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
