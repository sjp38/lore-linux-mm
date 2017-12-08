Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id E0D466B0253
	for <linux-mm@kvack.org>; Fri,  8 Dec 2017 03:48:02 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id w7so8246663pfd.4
        for <linux-mm@kvack.org>; Fri, 08 Dec 2017 00:48:02 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d2si5149412plh.536.2017.12.08.00.48.01
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 08 Dec 2017 00:48:01 -0800 (PST)
Date: Fri, 8 Dec 2017 09:47:55 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/2] mm: NUMA stats code cleanup and enhancement
Message-ID: <20171208084755.GS20234@dhcp22.suse.cz>
References: <1511848824-18709-1-git-send-email-kemi.wang@intel.com>
 <20171129121740.f6drkbktc43l5ib6@dhcp22.suse.cz>
 <4b840074-cb5f-3c10-d65b-916bc02fb1ee@intel.com>
 <20171130085322.tyys6xbzzvui7ogz@dhcp22.suse.cz>
 <0f039a89-5500-1bf5-c013-d39ba3bf62bd@intel.com>
 <20171130094523.vvcljyfqjpbloe5e@dhcp22.suse.cz>
 <9cd6cc9f-252a-3c6f-2f1f-e39d4ec0457b@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <9cd6cc9f-252a-3c6f-2f1f-e39d4ec0457b@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kemi <kemi.wang@intel.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, Christopher Lameter <cl@linux.com>, YASUAKI ISHIMATSU <yasu.isimatu@gmail.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Nikolay Borisov <nborisov@suse.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, David Rientjes <rientjes@google.com>, Sebastian Andrzej Siewior <bigeasy@linutronix.de>, Dave <dave.hansen@linux.intel.com>, Andi Kleen <andi.kleen@intel.com>, Tim Chen <tim.c.chen@intel.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Ying Huang <ying.huang@intel.com>, Aaron Lu <aaron.lu@intel.com>, Aubrey Li <aubrey.li@intel.com>, Linux MM <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>

On Fri 08-12-17 16:38:46, kemi wrote:
> 
> 
> On 2017a1'11ae??30ae?JPY 17:45, Michal Hocko wrote:
> > On Thu 30-11-17 17:32:08, kemi wrote:
> 
> > Do not get me wrong. If we want to make per-node stats more optimal,
> > then by all means let's do that. But having 3 sets of counters is just
> > way to much.
> > 
> 
> Hi, Michal
>   Apologize to respond later in this email thread.
> 
> After thinking about how to optimize our per-node stats more gracefully, 
> we may add u64 vm_numa_stat_diff[] in struct per_cpu_nodestat, thus,
> we can keep everything in per cpu counter and sum them up when read /proc
> or /sys for numa stats. 
> What's your idea for that? thanks

I would like to see a strong argument why we cannot make it a _standard_
node counter.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
