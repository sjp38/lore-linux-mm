Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f51.google.com (mail-wg0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id E39066B0036
	for <linux-mm@kvack.org>; Fri, 18 Jul 2014 10:55:13 -0400 (EDT)
Received: by mail-wg0-f51.google.com with SMTP id b13so3583237wgh.34
        for <linux-mm@kvack.org>; Fri, 18 Jul 2014 07:55:12 -0700 (PDT)
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
        by mx.google.com with ESMTPS id gh6si4270197wib.12.2014.07.18.07.55.10
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 18 Jul 2014 07:55:11 -0700 (PDT)
Received: by mail-wi0-f182.google.com with SMTP id d1so994613wiv.3
        for <linux-mm@kvack.org>; Fri, 18 Jul 2014 07:55:10 -0700 (PDT)
Date: Fri, 18 Jul 2014 15:55:07 +0100
From: Steve Capper <steve.capper@linaro.org>
Subject: Re: [PATCH v13 7/8] arm64: add pmd_[dirty|mkclean] for THP
Message-ID: <20140718145506.GB18569@linaro.org>
References: <1405666386-15095-1-git-send-email-minchan@kernel.org>
 <1405666386-15095-8-git-send-email-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1405666386-15095-8-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michael Kerrisk <mtk.manpages@gmail.com>, Linux API <linux-api@vger.kernel.org>, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Jason Evans <je@fb.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Russell King <linux@arm.linux.org.uk>, linux-arm-kernel@lists.infradead.org

On Fri, Jul 18, 2014 at 03:53:05PM +0900, Minchan Kim wrote:
> MADV_FREE needs pmd_dirty and pmd_mkclean for detecting recent
> overwrite of the contents since MADV_FREE syscall is called for
> THP page.
> 
> This patch adds pmd_dirty and pmd_mkclean for THP page MADV_FREE
> support.
> 
> Cc: Catalin Marinas <catalin.marinas@arm.com>
> Cc: Will Deacon <will.deacon@arm.com>
> Cc: Steve Capper <steve.capper@linaro.org>
> Cc: Russell King <linux@arm.linux.org.uk>
> Cc: linux-arm-kernel@lists.infradead.org
> Acked-by: Catalin Marinas <catalin.marinas@arm.com>
> Signed-off-by: Minchan Kim <minchan@kernel.org>

Acked-by: Steve Capper <steve.capper@linaro.org> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
