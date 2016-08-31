Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f197.google.com (mail-ua0-f197.google.com [209.85.217.197])
	by kanga.kvack.org (Postfix) with ESMTP id 632D86B0038
	for <linux-mm@kvack.org>; Wed, 31 Aug 2016 19:14:17 -0400 (EDT)
Received: by mail-ua0-f197.google.com with SMTP id i89so7695801uad.1
        for <linux-mm@kvack.org>; Wed, 31 Aug 2016 16:14:17 -0700 (PDT)
Received: from mail-pa0-x235.google.com (mail-pa0-x235.google.com. [2607:f8b0:400e:c03::235])
        by mx.google.com with ESMTPS id or6si2050628pab.77.2016.08.31.16.14.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Aug 2016 16:14:16 -0700 (PDT)
Received: by mail-pa0-x235.google.com with SMTP id fu3so15135467pad.3
        for <linux-mm@kvack.org>; Wed, 31 Aug 2016 16:14:16 -0700 (PDT)
Date: Wed, 31 Aug 2016 16:14:14 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 4/4] selftests/vm: add test for mlock() when areas are
 intersected.
In-Reply-To: <1472554781-9835-5-git-send-email-wei.guo.simon@gmail.com>
Message-ID: <alpine.DEB.2.10.1608311612190.89744@chino.kir.corp.google.com>
References: <1472554781-9835-1-git-send-email-wei.guo.simon@gmail.com> <1472554781-9835-5-git-send-email-wei.guo.simon@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Simon Guo <wei.guo.simon@gmail.com>
Cc: linux-mm@kvack.org, Alexey Klimov <klimov.linux@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Eric B Munson <emunson@akamai.com>, Geert Uytterhoeven <geert@linux-m68k.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-kernel@vger.kernel.org, linux-kselftest@vger.kernel.org, Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@suse.com>, Shuah Khan <shuah@kernel.org>, Thierry Reding <treding@nvidia.com>, Vlastimil Babka <vbabka@suse.cz>

On Tue, 30 Aug 2016, wei.guo.simon@gmail.com wrote:

> From: Simon Guo <wei.guo.simon@gmail.com>
> 
> This patch adds mlock() test for multiple invocation on
> the same address area, and verify it doesn't mess the
> rlimit mlock limitation.
> 

Thanks for expanding mlock testing.  I'm wondering if you are interested 
in more elaborate testing that doesn't only check what you are fixing, 
such as mlock(p + x, 40k) where x is < 20k?

Would you also be willing to make sure that the rlimit is actually 
enforced when it's expected to?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
