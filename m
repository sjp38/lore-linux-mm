Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f41.google.com (mail-oi0-f41.google.com [209.85.218.41])
	by kanga.kvack.org (Postfix) with ESMTP id D39AD6B0257
	for <linux-mm@kvack.org>; Mon, 23 Nov 2015 04:24:30 -0500 (EST)
Received: by oige206 with SMTP id e206so116509450oig.2
        for <linux-mm@kvack.org>; Mon, 23 Nov 2015 01:24:30 -0800 (PST)
Received: from mail-oi0-x22a.google.com (mail-oi0-x22a.google.com. [2607:f8b0:4003:c06::22a])
        by mx.google.com with ESMTPS id y6si7795241oei.53.2015.11.23.01.24.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Nov 2015 01:24:30 -0800 (PST)
Received: by oixx65 with SMTP id x65so116649451oix.0
        for <linux-mm@kvack.org>; Mon, 23 Nov 2015 01:24:30 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <5652CF40.6040400@intel.com>
References: <20151119092920.GA11806@aaronlu.sh.intel.com>
	<564DCEA6.3000802@suse.cz>
	<564EDFE5.5010709@intel.com>
	<564EE8FD.7090702@intel.com>
	<564EF0B6.10508@suse.cz>
	<20151123081601.GA29397@js1304-P5Q-DELUXE>
	<5652CF40.6040400@intel.com>
Date: Mon, 23 Nov 2015 18:24:29 +0900
Message-ID: <CAAmzW4M6oJukBLwucByK89071RukF4UEyt02A7ZjenpPr5rsdQ@mail.gmail.com>
Subject: Re: hugepage compaction causes performance drop
From: Joonsoo Kim <js1304@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Aaron Lu <aaron.lu@intel.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Vlastimil Babka <vbabka@suse.cz>, Linux Memory Management List <linux-mm@kvack.org>, Huang Ying <ying.huang@intel.com>, Dave Hansen <dave.hansen@intel.com>, Tim Chen <tim.c.chen@linux.intel.com>, lkp@lists.01.org, Andrea Arcangeli <aarcange@redhat.com>, David Rientjes <rientjes@google.com>

2015-11-23 17:33 GMT+09:00 Aaron Lu <aaron.lu@intel.com>:
> On 11/23/2015 04:16 PM, Joonsoo Kim wrote:
>> Numbers looks fine to me. I guess this performance degradation is
>> caused by COMPACT_CLUSTER_MAX change (from 32 to 256). THP allocation
>> is async so should be aborted quickly. But, after isolating 256
>> migratable pages, it can't be aborted and will finish 256 pages
>> migration (at least, current implementation).

Let me correct above comment. It can be aborted after some try.

>> Aaron, please test again with setting COMPACT_CLUSTER_MAX to 32
>> (in swap.h)?
>
> This is what I found in include/linux/swap.h:
>
> #define SWAP_CLUSTER_MAX 32UL
> #define COMPACT_CLUSTER_MAX SWAP_CLUSTER_MAX
>
> Looks like it is already 32, or am I looking at the wrong place?
>
> BTW, I'm using v4.3 for all these tests, and I just checked v4.4-rc2,
> the above definition doesn't change.

Sorry. I looked at linux-next tree and, there, it is 128.
Please ignore my comment! :)

>>
>> And, please attach always-always's vmstat numbers, too.
>
> Sure, attached the vmstat tool output, taken every second.

Oops... I'd like to see '1 sec interval cat /proc/vmstat' for always-never.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
