Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id 84ACE6B0038
	for <linux-mm@kvack.org>; Sat,  5 Sep 2015 15:24:54 -0400 (EDT)
Received: by wiclk2 with SMTP id lk2so51561916wic.0
        for <linux-mm@kvack.org>; Sat, 05 Sep 2015 12:24:54 -0700 (PDT)
Received: from mail-wi0-x22f.google.com (mail-wi0-x22f.google.com. [2a00:1450:400c:c05::22f])
        by mx.google.com with ESMTPS id s2si5175382wjw.75.2015.09.05.12.24.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 05 Sep 2015 12:24:53 -0700 (PDT)
Received: by wiclk2 with SMTP id lk2so46971472wic.1
        for <linux-mm@kvack.org>; Sat, 05 Sep 2015 12:24:52 -0700 (PDT)
Date: Sat, 5 Sep 2015 22:24:48 +0300
From: Ebru Akagunduz <ebru.akagunduz@gmail.com>
Subject: Re: [RESEND RFC v4 1/3] mm: add tracepoint for scanning pages
Message-ID: <20150905192448.GA3933@debian>
References: <1441313508-4276-1-git-send-email-ebru.akagunduz@gmail.com>
 <1441313508-4276-2-git-send-email-ebru.akagunduz@gmail.com>
 <55E9C1AA.4010908@suse.cz>
 <55E9CA8B.7090004@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <55E9CA8B.7090004@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>
Cc: akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com, aarcange@redhat.com, iamjoonsoo.kim@lge.com, xiexiuqi@huawei.com, gorcunov@openvz.org, linux-kernel@vger.kernel.org, mgorman@suse.de, rientjes@google.com, aneesh.kumar@linux.vnet.ibm.com, hughd@google.com, hannes@cmpxchg.org, mhocko@suse.cz, boaz@plexistor.com, raindel@mellanox.com, linux-mm@kvack.org

On Fri, Sep 04, 2015 at 12:44:59PM -0400, Rik van Riel wrote:
> On 09/04/2015 12:07 PM, Vlastimil Babka wrote:
> > On 09/03/2015 10:51 PM, Ebru Akagunduz wrote:
> >> Using static tracepoints, data of functions is recorded.
> >> It is good to automatize debugging without doing a lot
> >> of changes in the source code.
> >>
> >> This patch adds tracepoint for khugepaged_scan_pmd,
> >> collapse_huge_page and __collapse_huge_page_isolate.
> >>
> >> Signed-off-by: Ebru Akagunduz <ebru.akagunduz@gmail.com>
> >> Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> >> Acked-by: Rik van Riel <riel@redhat.com>
> >> ---
> >> Changes in v2:
> >>  - Nothing changed
> >>
> >> Changes in v3:
> >>  - Print page address instead of vm_start (Vlastimil Babka)
> >>  - Define constants to specify exact tracepoint result (Vlastimil Babka)
> >>
> >> Changes in v4:
> >>  - Change the constant prefix with SCAN_ instead of MM_ (Vlastimil Babka)
> >>  - Move the constants into the enum (Vlastimil Babka)
> >>  - Move the constants from mm.h to huge_memory.c
> >>    (because only will be used in huge_memory.c) (Vlastimil Babka)
> >>  - Print pfn in tracepoints (Vlastimil Babka)
> >>  - Print scan result as string in tracepoint (Vlastimil Babka)
> >>    (I tried to make same things to print string like mm/compaction.c.
> >>     My patch does not print string, I skip something but could not see why)
> > 
> > How do you print the trace? Do you cat /sys/kernel/debug/tracing/trace_pipe
> > or use some tool such as trace-cmd? I have just recently realized that tools
> > don't print strings in the compaction tracepoints, which lead to a patch [1].
> > You could convert this patch in the same way and then it should work with
> > tracing tools. Sorry for previously suggesting a wrong example to follow.
> > 
> > [1] https://lkml.org/lkml/2015/8/27/373

I use perf tool to test changes.
> 
> Well that explains why doing the same thing as compaction.c
> resulted in the strings not being printed!  Ebru and I got
> confused over that for quite a while :)
> 
> Thanks for pointing us to the fix.
> 
> Ebru, can you use tracepoint macros like in Vlastimil's patch
> above, so your tracepoints work?
> 
I did similar changes with Vlastimil's patch. It works!

Thanks,
Ebru

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
