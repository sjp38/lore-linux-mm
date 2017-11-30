Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 32AC16B0038
	for <linux-mm@kvack.org>; Thu, 30 Nov 2017 04:45:28 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id a6so4574907pff.17
        for <linux-mm@kvack.org>; Thu, 30 Nov 2017 01:45:28 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s11si2856967plj.633.2017.11.30.01.45.27
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 30 Nov 2017 01:45:27 -0800 (PST)
Date: Thu, 30 Nov 2017 10:45:23 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/2] mm: NUMA stats code cleanup and enhancement
Message-ID: <20171130094523.vvcljyfqjpbloe5e@dhcp22.suse.cz>
References: <1511848824-18709-1-git-send-email-kemi.wang@intel.com>
 <20171129121740.f6drkbktc43l5ib6@dhcp22.suse.cz>
 <4b840074-cb5f-3c10-d65b-916bc02fb1ee@intel.com>
 <20171130085322.tyys6xbzzvui7ogz@dhcp22.suse.cz>
 <0f039a89-5500-1bf5-c013-d39ba3bf62bd@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <0f039a89-5500-1bf5-c013-d39ba3bf62bd@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kemi <kemi.wang@intel.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, Christopher Lameter <cl@linux.com>, YASUAKI ISHIMATSU <yasu.isimatu@gmail.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Nikolay Borisov <nborisov@suse.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, David Rientjes <rientjes@google.com>, Sebastian Andrzej Siewior <bigeasy@linutronix.de>, Dave <dave.hansen@linux.intel.com>, Andi Kleen <andi.kleen@intel.com>, Tim Chen <tim.c.chen@intel.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Ying Huang <ying.huang@intel.com>, Aaron Lu <aaron.lu@intel.com>, Aubrey Li <aubrey.li@intel.com>, Linux MM <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>

On Thu 30-11-17 17:32:08, kemi wrote:
[...]
> Your patch saves more code than mine because the node stats framework is reused
> for numa stats. But it has a performance regression because of the limitation of
> threshold size (125 at most, see calculate_normal_threshold() in vmstat.c) 
> in inc_node_state().

But this "regression" would be visible only on those workloads which
really need to squeeze every single cycle out of the allocation hot path
and those are supposed to disable the accounting altogether. Or is this
visible on a wider variety of workloads.

Do not get me wrong. If we want to make per-node stats more optimal,
then by all means let's do that. But having 3 sets of counters is just
way to much.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
