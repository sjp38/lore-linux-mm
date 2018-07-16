Return-Path: <linux-kernel-owner@vger.kernel.org>
Date: Mon, 16 Jul 2018 14:12:46 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH] Revert "mm: always flush VMA ranges affected by
 zap_page_range"
Message-ID: <20180716131246.iacuzs5ntzktangk@techsingularity.net>
References: <1530896635.5350.25.camel@surriel.com>
 <20180706131019.51e3a5f0@imladris.surriel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20180706131019.51e3a5f0@imladris.surriel.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Rik van Riel <riel@surriel.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, "kirill.shutemov" <kirill.shutemov@linux.intel.com>, Minchan Kim <minchan@kernel.org>, kernel-team <kernel-team@fb.com>
List-ID: <linux-mm.kvack.org>

On Fri, Jul 06, 2018 at 01:10:19PM -0400, Rik van Riel wrote:
> There was a bug in Linux that could cause madvise (and mprotect?)
> system calls to return to userspace without the TLB having been
> flushed for all the pages involved.
> 
> This could happen when multiple threads of a process made simultaneous
> madvise and/or mprotect calls.
> 
> This was noticed in the summer of 2017, at which time two solutions
> were created:
> 56236a59556c ("mm: refactor TLB gathering API")
> 99baac21e458 ("mm: fix MADV_[FREE|DONTNEED] TLB flush miss problem")
> and
> 4647706ebeee ("mm: always flush VMA ranges affected by zap_page_range")
> 
> We need only one of these solutions, and the former appears to be
> a little more efficient than the latter, so revert that one.
> 
> This reverts commit 4647706ebeee6e50f7b9f922b095f4ec94d581c3.
> ---
>  mm/memory.c | 14 +-------------
>  1 file changed, 1 insertion(+), 13 deletions(-)

Acked-by: Mel Gorman <mgorman@techsingularity.net>

-- 
Mel Gorman
SUSE Labs
