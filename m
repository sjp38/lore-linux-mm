Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f71.google.com (mail-vk0-f71.google.com [209.85.213.71])
	by kanga.kvack.org (Postfix) with ESMTP id 419496B000D
	for <linux-mm@kvack.org>; Mon,  4 Jun 2018 14:06:53 -0400 (EDT)
Received: by mail-vk0-f71.google.com with SMTP id 196-v6so11520794vko.21
        for <linux-mm@kvack.org>; Mon, 04 Jun 2018 11:06:53 -0700 (PDT)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id v38-v6si20682848uaf.47.2018.06.04.11.06.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Jun 2018 11:06:51 -0700 (PDT)
Date: Mon, 4 Jun 2018 11:06:42 -0700
From: Daniel Jordan <daniel.m.jordan@oracle.com>
Subject: Re: [PATCH -mm -V3 00/21] mm, THP, swap: Swapout/swapin THP in one
 piece
Message-ID: <20180604180642.qexvwe5dqvkgraij@ca-dmjordan1.us.oracle.com>
References: <20180523082625.6897-1-ying.huang@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20180523082625.6897-1-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, May 23, 2018 at 04:26:04PM +0800, Huang, Ying wrote:
> And for all, Any comment is welcome!
> 
> This patchset is based on the 2018-05-18 head of mmotm/master.

Trying to review this and it doesn't apply to mmotm-2018-05-18-16-44.  git
fails on patch 10:

Applying: mm, THP, swap: Support to count THP swapin and its fallback
error: Documentation/vm/transhuge.rst: does not exist in index
Patch failed at 0010 mm, THP, swap: Support to count THP swapin and its fallback

Sure enough, this tag has Documentation/vm/transhuge.txt but not the .rst
version.  Was this the tag you meant?  If so did you pull in some of Mike
Rapoport's doc changes on top?

>             base                  optimized
> ---------------- -------------------------- 
>          %stddev     %change         %stddev
>              \          |                \  
>    1417897 +-  2%    +992.8%   15494673        vm-scalability.throughput
>    1020489 +-  4%   +1091.2%   12156349        vmstat.swap.si
>    1255093 +-  3%    +940.3%   13056114        vmstat.swap.so
>    1259769 +-  7%   +1818.3%   24166779        meminfo.AnonHugePages
>   28021761           -10.7%   25018848 +-  2%  meminfo.AnonPages
>   64080064 +-  4%     -95.6%    2787565 +- 33%  interrupts.CAL:Function_call_interrupts
>      13.91 +-  5%     -13.8        0.10 +- 27%  perf-profile.children.cycles-pp.native_queued_spin_lock_slowpath
> 
...snip...
> test, while in optimized kernel, that is 96.6%.  The TLB flushing IPI
> (represented as interrupts.CAL:Function_call_interrupts) reduced
> 95.6%, while cycles for spinlock reduced from 13.9% to 0.1%.  These
> are performance benefit of THP swapout/swapin too.

Which spinlocks are we spending less time on?
