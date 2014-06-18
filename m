Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id 06A836B0031
	for <linux-mm@kvack.org>; Wed, 18 Jun 2014 08:20:19 -0400 (EDT)
Received: by mail-wi0-f182.google.com with SMTP id bs8so1014825wib.9
        for <linux-mm@kvack.org>; Wed, 18 Jun 2014 05:20:19 -0700 (PDT)
Received: from jenni1.inet.fi (mta-out1.inet.fi. [62.71.2.198])
        by mx.google.com with ESMTP id da4si2519136wib.106.2014.06.18.05.20.18
        for <linux-mm@kvack.org>;
        Wed, 18 Jun 2014 05:20:18 -0700 (PDT)
Date: Wed, 18 Jun 2014 15:17:31 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH v2 2/2] mm, thp: replace smp_mb after atomic_add by
 smp_mb__after_atomic
Message-ID: <20140618121731.GA5957@node.dhcp.inet.fi>
References: <1403044679-9993-1-git-send-email-Waiman.Long@hp.com>
 <1403044679-9993-3-git-send-email-Waiman.Long@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1403044679-9993-3-git-send-email-Waiman.Long@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Waiman Long <Waiman.Long@hp.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <peterz@infradead.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Scott J Norton <scott.norton@hp.com>

On Tue, Jun 17, 2014 at 06:37:59PM -0400, Waiman Long wrote:
> In some architectures like x86, atomic_add() is a full memory
> barrier. In that case, an additional smp_mb() is just a waste of time.
> This patch replaces that smp_mb() by smp_mb__after_atomic() which
> will avoid the redundant memory barrier in some architectures.
> 
> With a 3.16-rc1 based kernel, this patch reduced the execution time
> of breaking 1000 transparent huge pages from 38,245us to 30,964us. A
> reduction of 19% which is quite sizeable. It also reduces the %cpu
> time of the __split_huge_page_refcount function in the perf profile
> from 2.18% to 1.15%.
> 
> Signed-off-by: Waiman Long <Waiman.Long@hp.com>

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
