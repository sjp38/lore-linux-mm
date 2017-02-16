Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id DB5614405C6
	for <linux-mm@kvack.org>; Thu, 16 Feb 2017 03:44:36 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id f5so16297705pgi.1
        for <linux-mm@kvack.org>; Thu, 16 Feb 2017 00:44:36 -0800 (PST)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id i186si6288499pge.421.2017.02.16.00.44.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Feb 2017 00:44:35 -0800 (PST)
From: "Huang\, Ying" <ying.huang@intel.com>
Subject: Re: swap_cluster_info lockdep splat
References: <20170216052218.GA13908@bbox>
Date: Thu, 16 Feb 2017 16:44:33 +0800
In-Reply-To: <20170216052218.GA13908@bbox> (Minchan Kim's message of "Thu, 16
	Feb 2017 14:22:18 +0900")
Message-ID: <87o9y2a5ji.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: "Huang, Ying" <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Tim Chen <tim.c.chen@linux.intel.com>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hi, Minchan,

Minchan Kim <minchan@kernel.org> writes:

> Hi Huang,
>
> With changing from bit lock to spinlock of swap_cluster_info, my zram
> test failed with below message. It seems nested lock problem so need to
> play with lockdep.

Sorry, I could not reproduce the warning in my tests.  Could you try the
patches as below?   And could you share your test case?

Best Regards,
Huang, Ying

------------------------------------------------------------->
