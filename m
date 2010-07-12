Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id AB65C6B02A3
	for <linux-mm@kvack.org>; Mon, 12 Jul 2010 17:57:13 -0400 (EDT)
Date: Mon, 12 Jul 2010 14:56:43 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 3/6] writeback: avoid unnecessary calculation of bdi
 dirty thresholds
Message-Id: <20100712145643.a944c495.akpm@linux-foundation.org>
In-Reply-To: <20100711021748.879183413@intel.com>
References: <20100711020656.340075560@intel.com>
	<20100711021748.879183413@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Christoph Hellwig <hch@infradead.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>, linux-fsdevel@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Sun, 11 Jul 2010 10:06:59 +0800
Wu Fengguang <fengguang.wu@intel.com> wrote:

> +void global_dirty_limits(unsigned long *pbackground, unsigned long *pdirty)
>
> ...
>
> +unsigned long bdi_dirty_limit(struct backing_dev_info *bdi,
> +			       unsigned long dirty)

It'd be nice to have some documentation for these things.  They're
non-static, non-obvious and are stuffed to the gills with secret magic
numbers.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
