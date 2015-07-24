Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f176.google.com (mail-qk0-f176.google.com [209.85.220.176])
	by kanga.kvack.org (Postfix) with ESMTP id D3B106B0038
	for <linux-mm@kvack.org>; Fri, 24 Jul 2015 10:22:27 -0400 (EDT)
Received: by qkdl129 with SMTP id l129so15163990qkd.0
        for <linux-mm@kvack.org>; Fri, 24 Jul 2015 07:22:27 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id t34si10204587qgt.97.2015.07.24.07.22.26
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Jul 2015 07:22:27 -0700 (PDT)
Message-ID: <55B24A1D.1030400@redhat.com>
Date: Fri, 24 Jul 2015 10:22:21 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [RFC v2 0/4] Outsourcing compaction for THP allocations to kcompactd
References: <1435826795-13777-1-git-send-email-vbabka@suse.cz>
In-Reply-To: <1435826795-13777-1-git-send-email-vbabka@suse.cz>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On 07/02/2015 04:46 AM, Vlastimil Babka wrote:
> This RFC series is another evolution of the attempt to deal with THP
> allocations latencies. Please see the motivation in the previous version [1]
>
> The main difference here is that I've bitten the bullet and implemented
> per-node kcompactd kthreads - see Patch 1 for the details of why and how.
> Trying to fit everything into khugepaged was getting too clumsy, and kcompactd
> could have more benefits, see e.g. the ideas here [2]. Not everything is
> implemented yet, though, I would welcome some feedback first.

This leads to a few questions, one of which has an obvious answer.

1) Why should this functionality not be folded into kswapd?

    (because kswapd can get stuck on IO for long periods of time)

2) Given that kswapd can get stuck on IO for long periods of
    time, are there other tasks we may want to break out of
    kswapd, in order to reduce page reclaim latencies for things
    like network allocations?

    (freeing clean inactive pages?)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
