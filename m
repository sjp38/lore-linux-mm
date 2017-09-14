Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 09BAE6B0253
	for <linux-mm@kvack.org>; Thu, 14 Sep 2017 17:21:44 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id e64so1184449wmi.0
        for <linux-mm@kvack.org>; Thu, 14 Sep 2017 14:21:43 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id s74si721872wmb.175.2017.09.14.14.21.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Sep 2017 14:21:43 -0700 (PDT)
Date: Thu, 14 Sep 2017 14:21:40 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH -mm -v4 3/5] mm, swap: VMA based swap readahead
Message-Id: <20170914142140.9c5e3ef37e6bad1d68899e64@linux-foundation.org>
In-Reply-To: <20170914131446.GA12850@bgram>
References: <20170807054038.1843-1-ying.huang@intel.com>
	<20170807054038.1843-4-ying.huang@intel.com>
	<20170913014019.GB29422@bbox>
	<20170913140229.8a6cad6f017fa3ea8b53cefc@linux-foundation.org>
	<20170914075345.GA5533@bbox>
	<87h8w5jxph.fsf@yhuang-dev.intel.com>
	<20170914131446.GA12850@bgram>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: "Huang, Ying" <ying.huang@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Shaohua Li <shli@kernel.org>, Hugh Dickins <hughd@google.com>, Fengguang Wu <fengguang.wu@intel.com>, Tim Chen <tim.c.chen@intel.com>, Dave Hansen <dave.hansen@intel.com>

On Thu, 14 Sep 2017 22:14:46 +0900 Minchan Kim <minchan@kernel.org> wrote:

> > Now.  Users can choose between VMA based readahead and original
> > readahead via a knob as follow at runtime,
> > 
> > /sys/kernel/mm/swap/vma_ra_enabled
> 
> It's not a config option and is enabled by default. IOW, it's under the radar
> so current users cannot notice it. That's why we want to emit big fat warnning.
> when old user set 0 to page-cluster. However, as Andrew said, it's lame.
> 
> If we make it config option, product maker/kernel upgrade user can have
> a chance to notice and read description so they could be aware of two weird
> knobs and help to solve the problem in advance without printk_once warn.
> If user has no interest about swap-readahead or skip the new config option
> by mistake, it works physcial readahead which means no regression.

Yup, a Kconfig option sounds like a good idea.  And that's a bit more
friendly to tiny kernels as well.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
