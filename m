Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx174.postini.com [74.125.245.174])
	by kanga.kvack.org (Postfix) with SMTP id E32A46B00CE
	for <linux-mm@kvack.org>; Fri, 30 Nov 2012 11:19:25 -0500 (EST)
Date: Fri, 30 Nov 2012 17:19:23 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH for 3.2.34] memcg: do not trigger OOM from
 add_to_page_cache_locked
Message-ID: <20121130161923.GN29317@dhcp22.suse.cz>
References: <20121126013855.AF118F5E@pobox.sk>
 <20121126131837.GC17860@dhcp22.suse.cz>
 <20121126132149.GD17860@dhcp22.suse.cz>
 <20121130032918.59B3F780@pobox.sk>
 <20121130124506.GH29317@dhcp22.suse.cz>
 <20121130144427.51A09169@pobox.sk>
 <20121130144431.GI29317@dhcp22.suse.cz>
 <20121130160811.6BB25BDD@pobox.sk>
 <20121130153942.GL29317@dhcp22.suse.cz>
 <20121130165937.F9564EBE@pobox.sk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121130165937.F9564EBE@pobox.sk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: azurIt <azurit@pobox.sk>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups mailinglist <cgroups@vger.kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>

On Fri 30-11-12 16:59:37, azurIt wrote:
> >> Here is the full boot log:
> >> www.watchdog.sk/lkml/kern.log
> >
> >The log is not complete. Could you paste the comple dmesg output? Or
> >even better, do you have logs from the previous run?
> 
> 
> What is missing there? All kernel messages are logging into
> /var/log/kern.log (it's the same as dmesg), dmesg itself was already
> rewrited by other messages. I think it's all what that kernel printed.

Early boot messages are missing - so exactly the BIOS memory map I was
asking for. As the NUMA has been excluded it is probably not that
relevant anymore.
The important question is why you see VM_FAULT_OOM and whether memcg
charging failure can trigger that. I don not see how this could happen
right now because __GFP_NORETRY is not used for user pages (except for
THP which disable memcg OOM already), file backed page faults (aka
__do_fault) use mem_cgroup_newpage_charge which doesn't disable OOM.
This is a real head scratcher.

Could you also post your complete containers configuration, maybe there
is something strange in there (basically grep . -r YOUR_CGROUP_MNT
except for tasks files which are of no use right now).
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
