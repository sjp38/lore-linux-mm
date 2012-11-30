Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx152.postini.com [74.125.245.152])
	by kanga.kvack.org (Postfix) with SMTP id D27276B00CD
	for <linux-mm@kvack.org>; Fri, 30 Nov 2012 11:53:50 -0500 (EST)
Date: Fri, 30 Nov 2012 17:53:47 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH for 3.2.34] memcg: do not trigger OOM from
 add_to_page_cache_locked
Message-ID: <20121130165347.GO29317@dhcp22.suse.cz>
References: <20121126132149.GD17860@dhcp22.suse.cz>
 <20121130032918.59B3F780@pobox.sk>
 <20121130124506.GH29317@dhcp22.suse.cz>
 <20121130144427.51A09169@pobox.sk>
 <20121130144431.GI29317@dhcp22.suse.cz>
 <20121130160811.6BB25BDD@pobox.sk>
 <20121130153942.GL29317@dhcp22.suse.cz>
 <20121130165937.F9564EBE@pobox.sk>
 <20121130161923.GN29317@dhcp22.suse.cz>
 <20121130172651.B6917602@pobox.sk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121130172651.B6917602@pobox.sk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: azurIt <azurit@pobox.sk>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups mailinglist <cgroups@vger.kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>

On Fri 30-11-12 17:26:51, azurIt wrote:
> >Could you also post your complete containers configuration, maybe there
> >is something strange in there (basically grep . -r YOUR_CGROUP_MNT
> >except for tasks files which are of no use right now).
> 
> 
> Here it is:
> http://www.watchdog.sk/lkml/cgroups.gz

The only strange thing I noticed is that some groups have 0 limit. Is
this intentional?
grep memory.limit_in_bytes cgroups | grep -v uid | sed 's@.*/@@' | sort | uniq -c
      3 memory.limit_in_bytes:0
    254 memory.limit_in_bytes:104857600
    107 memory.limit_in_bytes:157286400
     68 memory.limit_in_bytes:209715200
     10 memory.limit_in_bytes:262144000
     28 memory.limit_in_bytes:314572800
      1 memory.limit_in_bytes:346030080
      1 memory.limit_in_bytes:524288000
      2 memory.limit_in_bytes:9223372036854775807
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
