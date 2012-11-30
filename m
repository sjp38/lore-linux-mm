Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx201.postini.com [74.125.245.201])
	by kanga.kvack.org (Postfix) with SMTP id 95FD78D0001
	for <linux-mm@kvack.org>; Fri, 30 Nov 2012 10:39:44 -0500 (EST)
Date: Fri, 30 Nov 2012 16:39:42 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH for 3.2.34] memcg: do not trigger OOM from
 add_to_page_cache_locked
Message-ID: <20121130153942.GL29317@dhcp22.suse.cz>
References: <20121125120524.GB10623@dhcp22.suse.cz>
 <20121125135542.GE10623@dhcp22.suse.cz>
 <20121126013855.AF118F5E@pobox.sk>
 <20121126131837.GC17860@dhcp22.suse.cz>
 <20121126132149.GD17860@dhcp22.suse.cz>
 <20121130032918.59B3F780@pobox.sk>
 <20121130124506.GH29317@dhcp22.suse.cz>
 <20121130144427.51A09169@pobox.sk>
 <20121130144431.GI29317@dhcp22.suse.cz>
 <20121130160811.6BB25BDD@pobox.sk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121130160811.6BB25BDD@pobox.sk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: azurIt <azurit@pobox.sk>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups mailinglist <cgroups@vger.kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>

On Fri 30-11-12 16:08:11, azurIt wrote:
> >DMA32 zone is usually fills up first 4G unless your HW remaps the rest
> >of the memory above 4G or you have a numa machine and the rest of the
> >memory is at other node. Could you post your memory map printed during
> >the boot? (e820: BIOS-provided physical RAM map: and following lines)
> 
> 
> Here is the full boot log:
> www.watchdog.sk/lkml/kern.log

The log is not complete. Could you paste the comple dmesg output? Or
even better, do you have logs from the previous run?

> >You have mentioned that you are comounting with cpuset. If this happens
> >to be a NUMA machine have you made the access to all nodes available?
> >Also what does /proc/sys/vm/zone_reclaim_mode says?
> 
> 
> Don't really know what NUMA means and which nodes are you talking
> about, sorry :(

http://en.wikipedia.org/wiki/Non-Uniform_Memory_Access
 
> # cat /proc/sys/vm/zone_reclaim_mode
> cat: /proc/sys/vm/zone_reclaim_mode: No such file or directory

OK, so the NUMA is not enabled.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
