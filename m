Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 15F026B0005
	for <linux-mm@kvack.org>; Tue, 26 Apr 2016 13:24:06 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id s63so17775720wme.2
        for <linux-mm@kvack.org>; Tue, 26 Apr 2016 10:24:06 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id dg4si31057569wjd.125.2016.04.26.10.24.04
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 26 Apr 2016 10:24:04 -0700 (PDT)
Subject: Re: [PATCH 19/28] mm, page_alloc: Reduce cost of fair zone allocation
 policy retry
References: <1460710760-32601-1-git-send-email-mgorman@techsingularity.net>
 <1460711275-1130-1-git-send-email-mgorman@techsingularity.net>
 <1460711275-1130-7-git-send-email-mgorman@techsingularity.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <571FA432.1050103@suse.cz>
Date: Tue, 26 Apr 2016 19:24:02 +0200
MIME-Version: 1.0
In-Reply-To: <1460711275-1130-7-git-send-email-mgorman@techsingularity.net>
Content-Type: text/plain; charset=iso-8859-2; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>
Cc: Jesper Dangaard Brouer <brouer@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 04/15/2016 11:07 AM, Mel Gorman wrote:
> The fair zone allocation policy is not without cost but it can be reduced
> slightly. This patch removes an unnecessary local variable, checks the
> likely conditions of the fair zone policy first, uses a bool instead of
> a flags check and falls through when a remote node is encountered instead
> of doing a full restart. The benefit is marginal but it's there
>
>                                             4.6.0-rc2                  4.6.0-rc2
>                                         decstat-v1r20              optfair-v1r20
> Min      alloc-odr0-1               377.00 (  0.00%)           380.00 ( -0.80%)
> Min      alloc-odr0-2               273.00 (  0.00%)           273.00 (  0.00%)
> Min      alloc-odr0-4               226.00 (  0.00%)           227.00 ( -0.44%)
> Min      alloc-odr0-8               196.00 (  0.00%)           196.00 (  0.00%)
> Min      alloc-odr0-16              183.00 (  0.00%)           183.00 (  0.00%)
> Min      alloc-odr0-32              175.00 (  0.00%)           173.00 (  1.14%)
> Min      alloc-odr0-64              172.00 (  0.00%)           169.00 (  1.74%)
> Min      alloc-odr0-128             170.00 (  0.00%)           169.00 (  0.59%)
> Min      alloc-odr0-256             183.00 (  0.00%)           180.00 (  1.64%)
> Min      alloc-odr0-512             191.00 (  0.00%)           190.00 (  0.52%)
> Min      alloc-odr0-1024            199.00 (  0.00%)           198.00 (  0.50%)
> Min      alloc-odr0-2048            204.00 (  0.00%)           204.00 (  0.00%)
> Min      alloc-odr0-4096            210.00 (  0.00%)           209.00 (  0.48%)
> Min      alloc-odr0-8192            213.00 (  0.00%)           213.00 (  0.00%)
> Min      alloc-odr0-16384           214.00 (  0.00%)           214.00 (  0.00%)
>
> The benefit is marginal at best but one of the most important benefits,
> avoiding a second search when falling back to another node is not triggered
> by this particular test so the benefit for some corner cases is understated.
>
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>

Acked-by: Vlastimil Babka <vbabka@suse.cz>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
