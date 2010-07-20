Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 76F3A60080B
	for <linux-mm@kvack.org>; Tue, 20 Jul 2010 00:15:02 -0400 (EDT)
Date: Mon, 19 Jul 2010 21:14:00 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 3/6] writeback: avoid unnecessary calculation of bdi
 dirty thresholds
Message-Id: <20100719211400.c2bd5494.akpm@linux-foundation.org>
In-Reply-To: <20100720033437.GE6087@localhost>
References: <20100711020656.340075560@intel.com>
	<20100711021748.879183413@intel.com>
	<20100719143520.d9af9649.akpm@linux-foundation.org>
	<20100720033437.GE6087@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Christoph Hellwig <hch@infradead.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Tue, 20 Jul 2010 11:34:37 +0800 Wu Fengguang <fengguang.wu@intel.com> wrote:

> On Tue, Jul 20, 2010 at 05:35:20AM +0800, Andrew Morton wrote:
> > On Sun, 11 Jul 2010 10:06:59 +0800
> > Wu Fengguang <fengguang.wu@intel.com> wrote:
> > 
> > > Split get_dirty_limits() into global_dirty_limits()+bdi_dirty_limit(),
> > > so that the latter can be avoided when under global dirty background
> > > threshold (which is the normal state for most systems).
> > > 
> > 
> > mm/page-writeback.c: In function 'balance_dirty_pages_ratelimited_nr':
> > mm/page-writeback.c:466: warning: 'dirty_exceeded' may be used uninitialized in this function
> > 
> > This was a real bug.
> 
> Thanks! But how do you catch this? There are no warnings in my compile test.

Basic `make allmodconfig'.  But I use a range of different compiler
versions.  Different versions of gcc detect different stuff.  This was 4.1.0
or 4.0.2, I forget which.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
