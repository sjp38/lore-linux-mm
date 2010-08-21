Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 0B6BA6B0375
	for <linux-mm@kvack.org>; Sat, 21 Aug 2010 01:48:34 -0400 (EDT)
Date: Sat, 21 Aug 2010 13:48:08 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 4/4] writeback: Reporting dirty thresholds in
 /proc/vmstat
Message-ID: <20100821054808.GA29869@localhost>
References: <1282296689-25618-1-git-send-email-mrubin@google.com>
 <1282296689-25618-5-git-send-email-mrubin@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1282296689-25618-5-git-send-email-mrubin@google.com>
Sender: owner-linux-mm@kvack.org
To: Michael Rubin <mrubin@google.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "jack@suse.cz" <jack@suse.cz>, "riel@redhat.com" <riel@redhat.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "david@fromorbit.com" <david@fromorbit.com>, "npiggin@kernel.dk" <npiggin@kernel.dk>, "hch@lst.de" <hch@lst.de>, "axboe@kernel.dk" <axboe@kernel.dk>
List-ID: <linux-mm.kvack.org>

On Fri, Aug 20, 2010 at 05:31:29PM +0800, Michael Rubin wrote:
> The kernel already exposes the user desired thresholds in /proc/sys/vm
> with dirty_background_ratio and background_ratio. But the kernel may
> alter the number requested without giving the user any indication that
> is the case.
> 
> Knowing the actual ratios the kernel is honoring can help app developers
> understand how their buffered IO will be sent to the disk.
> 
> 	$ grep threshold /proc/vmstat
> 	nr_dirty_threshold 409111
> 	nr_dirty_background_threshold 818223

I realized that the dirty thresholds has already been exported here:

$ grep Thresh  /debug/bdi/8:0/stats
BdiDirtyThresh:     381000 kB
DirtyThresh:       1719076 kB
BackgroundThresh:   859536 kB

So why not use that interface directly?

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
