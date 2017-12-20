Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id A211B6B0038
	for <linux-mm@kvack.org>; Wed, 20 Dec 2017 05:12:34 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id i14so14152574pgf.13
        for <linux-mm@kvack.org>; Wed, 20 Dec 2017 02:12:34 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t1si11644759pgq.794.2017.12.20.02.12.33
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 20 Dec 2017 02:12:33 -0800 (PST)
Date: Wed, 20 Dec 2017 11:12:29 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2 3/5] mm: enlarge NUMA counters threshold size
Message-ID: <20171220101229.GJ4831@dhcp22.suse.cz>
References: <1513665566-4465-1-git-send-email-kemi.wang@intel.com>
 <1513665566-4465-4-git-send-email-kemi.wang@intel.com>
 <20171219124045.GO2787@dhcp22.suse.cz>
 <439918f7-e8a3-c007-496c-99535cbc4582@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <439918f7-e8a3-c007-496c-99535cbc4582@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kemi <kemi.wang@intel.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, Christopher Lameter <cl@linux.com>, YASUAKI ISHIMATSU <yasu.isimatu@gmail.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Nikolay Borisov <nborisov@suse.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, David Rientjes <rientjes@google.com>, Sebastian Andrzej Siewior <bigeasy@linutronix.de>, Dave <dave.hansen@linux.intel.com>, Andi Kleen <andi.kleen@intel.com>, Tim Chen <tim.c.chen@intel.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Ying Huang <ying.huang@intel.com>, Aaron Lu <aaron.lu@intel.com>, Aubrey Li <aubrey.li@intel.com>, Linux MM <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>

On Wed 20-12-17 13:52:14, kemi wrote:
> 
> 
> On 2017a1'12ae??19ae?JPY 20:40, Michal Hocko wrote:
> > On Tue 19-12-17 14:39:24, Kemi Wang wrote:
> >> We have seen significant overhead in cache bouncing caused by NUMA counters
> >> update in multi-threaded page allocation. See 'commit 1d90ca897cb0 ("mm:
> >> update NUMA counter threshold size")' for more details.
> >>
> >> This patch updates NUMA counters to a fixed size of (MAX_S16 - 2) and deals
> >> with global counter update using different threshold size for node page
> >> stats.
> > 
> > Again, no numbers.
> 
> Compare to vanilla kernel, I don't think it has performance improvement, so
> I didn't post performance data here.
> But, if you would like to see performance gain from enlarging threshold size
> for NUMA stats (compare to the first patch), I will do that later. 

Please do. I would also like to hear _why_ all counters cannot simply
behave same. In other words why we cannot simply increase
stat_threshold? Maybe calculate_normal_threshold needs a better scaling
for larger machines.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
