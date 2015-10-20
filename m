Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id C016282F65
	for <linux-mm@kvack.org>; Tue, 20 Oct 2015 03:47:03 -0400 (EDT)
Received: by wicll6 with SMTP id ll6so32172838wic.0
        for <linux-mm@kvack.org>; Tue, 20 Oct 2015 00:47:03 -0700 (PDT)
Received: from outbound-smtp03.blacknight.com (outbound-smtp03.blacknight.com. [81.17.249.16])
        by mx.google.com with ESMTPS id n3si299463wiz.86.2015.10.20.00.47.02
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 20 Oct 2015 00:47:02 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp03.blacknight.com (Postfix) with ESMTPS id 2C969992C7
	for <linux-mm@kvack.org>; Tue, 20 Oct 2015 07:47:02 +0000 (UTC)
Date: Tue, 20 Oct 2015 08:47:00 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH] mm: vmpressure: fix scan window after SWAP_CLUSTER_MAX
 increase
Message-ID: <20151020074700.GB2629@techsingularity.net>
References: <1445278381-21033-1-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1445278381-21033-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vladimir Davydov <vdavydov@virtuozzo.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Mon, Oct 19, 2015 at 02:13:01PM -0400, Johannes Weiner wrote:
> mm-increase-swap_cluster_max-to-batch-tlb-flushes.patch changed
> SWAP_CLUSTER_MAX from 32 pages to 256 pages, inadvertantly switching
> the scan window for vmpressure detection from 2MB to 16MB. Revert.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

This was known at the time but it was not clear what the measurable
impact would be. VM Pressure is odd in that it gives strange results at
times anyway, particularly on NUMA machines. To be honest, it still isn't
clear to me what the impact of the patch is. With different base page sizes
(e.g. on ppc64 with some configs), the window is still large. At the time,
it was left as-is as I could not decide one way or the other but I'm ok
with restoring the behaviour so either way;

Acked-by: Mel Gorman <mgorman@techsingularity.net>

Out of curiosity though, what *is* the user-visible impact of the patch
though? It's different but I'm having trouble deciding if it's better
or worse. I'm curious as to whether the patch is based on a bug report
or intuition.

Thanks.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
