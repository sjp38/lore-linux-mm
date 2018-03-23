Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3DD446B000A
	for <linux-mm@kvack.org>; Fri, 23 Mar 2018 11:19:08 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id 2so6811894pft.4
        for <linux-mm@kvack.org>; Fri, 23 Mar 2018 08:19:08 -0700 (PDT)
Received: from EUR01-DB5-obe.outbound.protection.outlook.com (mail-db5eur01on0135.outbound.protection.outlook.com. [104.47.2.135])
        by mx.google.com with ESMTPS id h32-v6si8818266pld.217.2018.03.23.08.19.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 23 Mar 2018 08:19:06 -0700 (PDT)
Subject: Re: [PATCH] mm, vmscan, tracing: Use pointer to reclaim_stat struct
 in trace event
References: <20180322121003.4177af15@gandalf.local.home>
 <20180322141022.f02476e1f76338ab9cecf62e@linux-foundation.org>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <e223712e-0385-8bdb-3454-534fdfefac26@virtuozzo.com>
Date: Fri, 23 Mar 2018 18:19:48 +0300
MIME-Version: 1.0
In-Reply-To: <20180322141022.f02476e1f76338ab9cecf62e@linux-foundation.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Steven Rostedt <rostedt@goodmis.org>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Michal Hocko <mhocko@suse.com>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Linus Torvalds <torvalds@linux-foundation.org>, Alexei Starovoitov <ast@fb.com>



On 03/23/2018 12:10 AM, Andrew Morton wrote:
> On Thu, 22 Mar 2018 12:10:03 -0400 Steven Rostedt <rostedt@goodmis.org> wrote:
> 
>>
>> The trace event trace_mm_vmscan_lru_shrink_inactive() currently has 12
>> parameters! Seven of them are from the reclaim_stat structure. This
>> structure is currently local to mm/vmscan.c. By moving it to the global
>> vmstat.h header, we can also reference it from the vmscan tracepoints. In
>> moving it, it brings down the overhead of passing so many arguments to the
>> trace event. In the future, we may limit the number of arguments that a
>> trace event may pass (ideally just 6, but more realistically it may be 8).
> 
> Unfortunately this is not a good time.  Andrey's "mm/vmscan: replace
> mm_vmscan_lru_shrink_inactive with shrink_page_list tracepoint" mucks
> with this code quite a lot and that patch's series is undergoing review
> at present, with a few issues yet unresolved.

I slightly reworked my patch series, so that patch "mm/vmscan: replace
mm_vmscan_lru_shrink_inactive with shrink_page_list tracepoint"
is not needed anymore. Replacing that tracepoint with less informative shrink_page_list
probably isn't a very good idea anyway.

So Steven's patch applies *almost* cleanly on top of my v2, nothing that 3-way merge can't handle:
# git am -3 mm-vmscan-tracing-Use-pointer-to-reclaim_stat-struct.patch
Applying: mm, vmscan, tracing: Use pointer to reclaim_stat struct in trace event
Using index info to reconstruct a base tree...
M       include/trace/events/vmscan.h
M       mm/vmscan.c
Falling back to patching base and 3-way merge...
Auto-merging mm/vmscan.c
Auto-merging include/trace/events/vmscan.h
