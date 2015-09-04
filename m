Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id 279706B0254
	for <linux-mm@kvack.org>; Fri,  4 Sep 2015 12:07:13 -0400 (EDT)
Received: by wiclk2 with SMTP id lk2so22846912wic.1
        for <linux-mm@kvack.org>; Fri, 04 Sep 2015 09:07:12 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b13si5071779wjz.156.2015.09.04.09.07.11
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 04 Sep 2015 09:07:11 -0700 (PDT)
Subject: Re: [RESEND RFC v4 1/3] mm: add tracepoint for scanning pages
References: <1441313508-4276-1-git-send-email-ebru.akagunduz@gmail.com>
 <1441313508-4276-2-git-send-email-ebru.akagunduz@gmail.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <55E9C1AA.4010908@suse.cz>
Date: Fri, 4 Sep 2015 18:07:06 +0200
MIME-Version: 1.0
In-Reply-To: <1441313508-4276-2-git-send-email-ebru.akagunduz@gmail.com>
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ebru Akagunduz <ebru.akagunduz@gmail.com>, linux-mm@kvack.org
Cc: akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com, aarcange@redhat.com, riel@redhat.com, iamjoonsoo.kim@lge.com, xiexiuqi@huawei.com, gorcunov@openvz.org, linux-kernel@vger.kernel.org, mgorman@suse.de, rientjes@google.com, aneesh.kumar@linux.vnet.ibm.com, hughd@google.com, hannes@cmpxchg.org, mhocko@suse.cz, boaz@plexistor.com, raindel@mellanox.com

On 09/03/2015 10:51 PM, Ebru Akagunduz wrote:
> Using static tracepoints, data of functions is recorded.
> It is good to automatize debugging without doing a lot
> of changes in the source code.
> 
> This patch adds tracepoint for khugepaged_scan_pmd,
> collapse_huge_page and __collapse_huge_page_isolate.
> 
> Signed-off-by: Ebru Akagunduz <ebru.akagunduz@gmail.com>
> Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Acked-by: Rik van Riel <riel@redhat.com>
> ---
> Changes in v2:
>  - Nothing changed
> 
> Changes in v3:
>  - Print page address instead of vm_start (Vlastimil Babka)
>  - Define constants to specify exact tracepoint result (Vlastimil Babka)
> 
> Changes in v4:
>  - Change the constant prefix with SCAN_ instead of MM_ (Vlastimil Babka)
>  - Move the constants into the enum (Vlastimil Babka)
>  - Move the constants from mm.h to huge_memory.c
>    (because only will be used in huge_memory.c) (Vlastimil Babka)
>  - Print pfn in tracepoints (Vlastimil Babka)
>  - Print scan result as string in tracepoint (Vlastimil Babka)
>    (I tried to make same things to print string like mm/compaction.c.
>     My patch does not print string, I skip something but could not see why)

How do you print the trace? Do you cat /sys/kernel/debug/tracing/trace_pipe
or use some tool such as trace-cmd? I have just recently realized that tools
don't print strings in the compaction tracepoints, which lead to a patch [1].
You could convert this patch in the same way and then it should work with
tracing tools. Sorry for previously suggesting a wrong example to follow.

[1] https://lkml.org/lkml/2015/8/27/373

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
