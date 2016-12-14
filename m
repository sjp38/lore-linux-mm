Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f198.google.com (mail-wj0-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id C892C6B0038
	for <linux-mm@kvack.org>; Wed, 14 Dec 2016 14:02:18 -0500 (EST)
Received: by mail-wj0-f198.google.com with SMTP id j10so13836243wjb.3
        for <linux-mm@kvack.org>; Wed, 14 Dec 2016 11:02:18 -0800 (PST)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id lh9si55809732wjc.83.2016.12.14.11.02.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Dec 2016 11:02:17 -0800 (PST)
Received: by mail-wm0-f65.google.com with SMTP id g23so1126271wme.1
        for <linux-mm@kvack.org>; Wed, 14 Dec 2016 11:02:17 -0800 (PST)
Date: Wed, 14 Dec 2016 20:02:15 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/3] mm, trace: extract COMPACTION_STATUS and ZONE_TYPE
 to a common header
Message-ID: <20161214190215.GE16763@dhcp22.suse.cz>
References: <20161214145324.26261-2-mhocko@kernel.org>
 <201612150127.1D06IAf6%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201612150127.1D06IAf6%fengguang.wu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <lkp@intel.com>
Cc: kbuild-all@01.org, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Thu 15-12-16 01:32:06, kbuild test robot wrote:
> Hi Michal,
> 
> [auto build test ERROR on tip/perf/core]
> [also build test ERROR on v4.9 next-20161214]
> [if your patch is applied to the wrong git tree, please drop us a note to help improve the system]
> 
> url:    https://github.com/0day-ci/linux/commits/Michal-Hocko/mm-oom-add-oom-detection-tracepoints/20161214-231225
> config: x86_64-randconfig-s2-12142134 (attached as .config)
> compiler: gcc-4.4 (Debian 4.4.7-8) 4.4.7
> reproduce:
>         # save the attached .config to linux build tree
>         make ARCH=x86_64 
> 
> All error/warnings (new ones prefixed by >>):
> 
>    In file included from include/trace/trace_events.h:361,
>                     from include/trace/define_trace.h:95,
>                     from include/trace/events/compaction.h:356,
>                     from mm/compaction.c:43:
>    include/trace/events/compaction.h: In function 'trace_raw_output_mm_compaction_end':
> >> include/trace/events/compaction.h:134: error: expected expression before ',' token
>    include/trace/events/compaction.h: In function 'trace_raw_output_mm_compaction_suitable_template':
>    include/trace/events/compaction.h:195: error: expected expression before ',' token
> >> include/trace/events/compaction.h:195: warning: missing braces around initializer
>    include/trace/events/compaction.h:195: warning: (near initialization for 'symbols[0]')
> >> include/trace/events/compaction.h:195: error: initializer element is not constant
>    include/trace/events/compaction.h:195: error: (near initialization for 'symbols[0].mask')

Interesting. I am pretty sure that my config battery has
CONFIG_COMPACTION=n. Not sure which part of your config made a change.
Anyway, I've added to my collection. And with the below diff it passes
all my configs.
---
