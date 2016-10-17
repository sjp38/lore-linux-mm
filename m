Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id CB56D6B0038
	for <linux-mm@kvack.org>; Mon, 17 Oct 2016 05:45:07 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id l29so97053681pfg.7
        for <linux-mm@kvack.org>; Mon, 17 Oct 2016 02:45:07 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id c22si30060319pfk.159.2016.10.17.02.45.06
        for <linux-mm@kvack.org>;
        Mon, 17 Oct 2016 02:45:07 -0700 (PDT)
Date: Mon, 17 Oct 2016 10:45:02 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCH] kmemleak: fix reference to Documentation
Message-ID: <20161017094501.GA10891@e104818-lin.cambridge.arm.com>
References: <1476544946-18804-1-git-send-email-andreas.platschek@opentech.at>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1476544946-18804-1-git-send-email-andreas.platschek@opentech.at>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andreas Platschek <andreas.platschek@opentech.at>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>

On Sat, Oct 15, 2016 at 03:22:26PM +0000, Andreas Platschek wrote:
> Documentation/kmemleak.txt was moved to Documentation/dev-tools/kmemleak.rst,
> this fixes the reference to the new location.
> 
> Signed-off-by: Andreas Platschek <andreas.platschek@opentech.at>

In case Andrew picks this patch up:

Acked-by: Catalin Marinas <catalin.marinas@arm.com>

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
