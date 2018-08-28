Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2F8676B48A9
	for <linux-mm@kvack.org>; Tue, 28 Aug 2018 19:28:07 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id r2-v6so2103291pgp.3
        for <linux-mm@kvack.org>; Tue, 28 Aug 2018 16:28:07 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id t19-v6si2069261pgu.285.2018.08.28.16.28.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Aug 2018 16:28:06 -0700 (PDT)
Date: Tue, 28 Aug 2018 16:28:04 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 2/2] scripts: add kmemleak2pprof.py for slab usage
 analysis
Message-Id: <20180828162804.4ee225124cbde3f39f53fd80@linux-foundation.org>
In-Reply-To: <20180828103914.30434-2-vincent.whitchurch@axis.com>
References: <20180828103914.30434-1-vincent.whitchurch@axis.com>
	<20180828103914.30434-2-vincent.whitchurch@axis.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vincent Whitchurch <vincent.whitchurch@axis.com>
Cc: catalin.marinas@arm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Vincent Whitchurch <rabinv@axis.com>

On Tue, 28 Aug 2018 12:39:14 +0200 Vincent Whitchurch <vincent.whitchurch@axis.com> wrote:

> Add a script which converts /sys/kernel/debug/kmemleak_all to the pprof
> format, which can be used for analysing memory usage.  See
> https://github.com/google/pprof.

Why is this better than /proc/slabinfo?

>  $ ./kmemleak2pprof.py kmemleak_all
>  $ pprof -text -ignore free_area_init_node -compact_labels -nodecount 10 prof

Are we missing an argument here?  s/prof/kmemleak_all/?

>  Showing nodes accounting for 4.85MB, 34.05% of 14.23MB total
>  Dropped 3989 nodes (cum <= 0.07MB)
>  Showing top 10 nodes out of 190
>        flat  flat%   sum%        cum   cum%
>      1.39MB  9.78%  9.78%     1.61MB 11.29%  new_inode_pseudo+0x8/0x4c
>      0.75MB  5.27% 15.04%     0.75MB  5.27%  alloc_large_system_hash+0x19c/0x2b8
>      0.73MB  5.12% 20.17%     0.86MB  6.07%  kernfs_new_node+0x30/0x50
>      0.66MB  4.62% 24.79%     0.66MB  4.62%  __vmalloc_node.constprop.9+0x48/0x50
>      0.61MB  4.28% 29.06%     0.61MB  4.28%  d_alloc+0x10/0x78
>      0.22MB  1.52% 30.58%     0.22MB  1.52%  alloc_inode+0x1c/0xa4
>      0.18MB  1.28% 31.86%     0.20MB  1.42%  _do_fork+0xb0/0x41c
>      0.13MB  0.88% 32.74%     0.13MB  0.88%  early_trace_init+0x16c/0x374
>      0.09MB  0.66% 33.40%     0.17MB  1.17%  inet_init+0x128/0x24c
>      0.09MB  0.65% 34.05%     0.09MB  0.65%  __kernfs_new_node+0x34/0x1a8
