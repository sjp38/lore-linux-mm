Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id D05416B0255
	for <linux-mm@kvack.org>; Fri, 20 Nov 2015 03:55:04 -0500 (EST)
Received: by pacdm15 with SMTP id dm15so110638083pac.3
        for <linux-mm@kvack.org>; Fri, 20 Nov 2015 00:55:04 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id q65si416216pfi.120.2015.11.20.00.55.03
        for <linux-mm@kvack.org>;
        Fri, 20 Nov 2015 00:55:04 -0800 (PST)
Subject: Re: hugepage compaction causes performance drop
References: <20151119092920.GA11806@aaronlu.sh.intel.com>
 <564DCEA6.3000802@suse.cz>
From: Aaron Lu <aaron.lu@intel.com>
Message-ID: <564EDFE5.5010709@intel.com>
Date: Fri, 20 Nov 2015 16:55:01 +0800
MIME-Version: 1.0
In-Reply-To: <564DCEA6.3000802@suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org
Cc: Huang Ying <ying.huang@intel.com>, Dave Hansen <dave.hansen@intel.com>, Tim Chen <tim.c.chen@linux.intel.com>, lkp@lists.01.org, Andrea Arcangeli <aarcange@redhat.com>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On 11/19/2015 09:29 PM, Vlastimil Babka wrote:
> +CC Andrea, David, Joonsoo
> 
> On 11/19/2015 10:29 AM, Aaron Lu wrote:
>> The vmstat and perf-profile are also attached, please let me know if you
>> need any more information, thanks.
> 
> Output from vmstat (the tool) isn't much useful here, a periodic "cat 
> /proc/vmstat" would be much better.

No problem.

> The perf profiles are somewhat weirdly sorted by children cost (?), but 
> I noticed a very high cost (46%) in pageblock_pfn_to_page(). This could 
> be due to a very large but sparsely populated zone. Could you provide 
> /proc/zoneinfo?

Is a one time /proc/zoneinfo enough or also a periodic one?

> If the compaction scanners behave strangely due to a bug, enabling the 
> ftrace compaction tracepoints should help find the cause. That might 
> produce a very large output, but maybe it would be enough to see some 
> parts of it (i.e. towards beginning, middle, end of the experiment).

I'll see how to do this, never used ftrace before.

Thanks for the quick response.

Regards,
Aaron

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
