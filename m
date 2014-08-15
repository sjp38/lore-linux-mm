Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f182.google.com (mail-yk0-f182.google.com [209.85.160.182])
	by kanga.kvack.org (Postfix) with ESMTP id 97D5D6B0037
	for <linux-mm@kvack.org>; Fri, 15 Aug 2014 06:56:10 -0400 (EDT)
Received: by mail-yk0-f182.google.com with SMTP id q9so1965749ykb.13
        for <linux-mm@kvack.org>; Fri, 15 Aug 2014 03:56:10 -0700 (PDT)
Received: from cam-admin0.cambridge.arm.com (cam-admin0.cambridge.arm.com. [217.140.96.50])
        by mx.google.com with ESMTP id g48si12676787yhk.13.2014.08.15.03.56.09
        for <linux-mm@kvack.org>;
        Fri, 15 Aug 2014 03:56:10 -0700 (PDT)
Date: Fri, 15 Aug 2014 11:55:51 +0100
From: Will Deacon <will.deacon@arm.com>
Subject: Re: [PATCH v14 7/8] arm64: add pmd_[dirty|mkclean] for THP
Message-ID: <20140815105550.GL27466@arm.com>
References: <1407981212-17818-1-git-send-email-minchan@kernel.org>
 <1407981212-17818-8-git-send-email-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1407981212-17818-8-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Michael Kerrisk <mtk.manpages@gmail.com>, Linux API <linux-api@vger.kernel.org>, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Jason Evans <je@fb.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Russell King <linux@arm.linux.org.uk>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Steve Capper <steve.capper@linaro.org>, Catalin Marinas <Catalin.Marinas@arm.com>

On Thu, Aug 14, 2014 at 02:53:31AM +0100, Minchan Kim wrote:
> MADV_FREE needs pmd_dirty and pmd_mkclean for detecting recent
> overwrite of the contents since MADV_FREE syscall is called for
> THP page.
> 
> This patch adds pmd_dirty and pmd_mkclean for THP page MADV_FREE
> support.

Acked-by: Will Deacon <will.deacon@arm.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
