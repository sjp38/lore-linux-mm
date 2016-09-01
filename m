Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f198.google.com (mail-yb0-f198.google.com [209.85.213.198])
	by kanga.kvack.org (Postfix) with ESMTP id 844D482F64
	for <linux-mm@kvack.org>; Thu,  1 Sep 2016 03:14:57 -0400 (EDT)
Received: by mail-yb0-f198.google.com with SMTP id 18so35387630ybc.3
        for <linux-mm@kvack.org>; Thu, 01 Sep 2016 00:14:57 -0700 (PDT)
Received: from mail-pa0-x22a.google.com (mail-pa0-x22a.google.com. [2607:f8b0:400e:c03::22a])
        by mx.google.com with ESMTPS id j29si4202656pfk.53.2016.09.01.00.14.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Sep 2016 00:14:56 -0700 (PDT)
Received: by mail-pa0-x22a.google.com with SMTP id hb8so26981862pac.2
        for <linux-mm@kvack.org>; Thu, 01 Sep 2016 00:14:56 -0700 (PDT)
Date: Thu, 1 Sep 2016 15:14:52 +0800
From: Simon Guo <wei.guo.simon@gmail.com>
Subject: Re: [PATCH 4/4] selftests/vm: add test for mlock() when areas are
 intersected.
Message-ID: <20160901071354.GA3306@simonLocalRHEL7.x64>
References: <1472554781-9835-1-git-send-email-wei.guo.simon@gmail.com>
 <1472554781-9835-5-git-send-email-wei.guo.simon@gmail.com>
 <alpine.DEB.2.10.1608311612190.89744@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1608311612190.89744@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: linux-mm@kvack.org, Alexey Klimov <klimov.linux@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Eric B Munson <emunson@akamai.com>, Geert Uytterhoeven <geert@linux-m68k.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-kernel@vger.kernel.org, linux-kselftest@vger.kernel.org, Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@suse.com>, Shuah Khan <shuah@kernel.org>, Thierry Reding <treding@nvidia.com>, Vlastimil Babka <vbabka@suse.cz>

Hi David,
On Wed, Aug 31, 2016 at 04:14:14PM -0700, David Rientjes wrote:
> On Tue, 30 Aug 2016, wei.guo.simon@gmail.com wrote:
> 
> > From: Simon Guo <wei.guo.simon@gmail.com>
> > 
> > This patch adds mlock() test for multiple invocation on
> > the same address area, and verify it doesn't mess the
> > rlimit mlock limitation.
> > 
> 
> Thanks for expanding mlock testing.  I'm wondering if you are interested 
> in more elaborate testing that doesn't only check what you are fixing, 
> such as mlock(p + x, 40k) where x is < 20k?
> 
> Would you also be willing to make sure that the rlimit is actually 
> enforced when it's expected to?
I'd like to do so. 
Let me think more for the comprehensive testing. If you have any other
test cases in mind, please let me know.

Thanks,
- Simon

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
