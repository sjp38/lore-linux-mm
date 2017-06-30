Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5CC906B0279
	for <linux-mm@kvack.org>; Fri, 30 Jun 2017 03:53:31 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id y62so109567622pfa.3
        for <linux-mm@kvack.org>; Fri, 30 Jun 2017 00:53:31 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id 7si5846014plf.146.2017.06.30.00.53.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 30 Jun 2017 00:53:30 -0700 (PDT)
From: "Huang\, Ying" <ying.huang@intel.com>
Subject: Re: [PATCH -mm -v2 0/6] mm, swap: VMA based swap readahead
References: <20170630014443.23983-1-ying.huang@intel.com>
	<20170630022626.GA25190@bbox>
Date: Fri, 30 Jun 2017 15:53:17 +0800
In-Reply-To: <20170630022626.GA25190@bbox> (Minchan Kim's message of "Fri, 30
	Jun 2017 11:26:26 +0900")
Message-ID: <87o9t5vrma.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: "Huang, Ying" <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, Shaohua Li <shli@kernel.org>, Hugh Dickins <hughd@google.com>, Fengguang Wu <fengguang.wu@intel.com>, Tim Chen <tim.c.chen@intel.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>

Hi, Minchan,

Minchan Kim <minchan@kernel.org> writes:
> Hi Huang,
>
> Ccing Johannes:
>
> I don't read this patch yet but I remember Johannes tried VMA-based
> readahead approach long time ago so he might have good comment.

Thanks a lot for your information and connecting!

Hi, Johannes,

Do you have time to take a look at this patchset?

Best Regards,
Huang, Ying

[snip]

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
