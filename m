Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 82F1D6B0047
	for <linux-mm@kvack.org>; Thu, 25 Feb 2010 10:52:44 -0500 (EST)
Message-ID: <4B869CBC.5070501@redhat.com>
Date: Thu, 25 Feb 2010 10:52:28 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 06/15] readahead: replace ra->mmap_miss with ra->ra_flags
References: <20100224031001.026464755@intel.com> <20100224031054.449606633@intel.com>
In-Reply-To: <20100224031054.449606633@intel.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jens Axboe <jens.axboe@oracle.com>, Nick Piggin <npiggin@suse.de>, Andi Kleen <andi@firstfloor.org>, Steven Whitehouse <swhiteho@redhat.com>, Chris Mason <chris.mason@oracle.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Clemens Ladisch <clemens@ladisch.de>, Olivier Galibert <galibert@pobox.com>, Vivek Goyal <vgoyal@redhat.com>, Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>, Matt Mackall <mpm@selenic.com>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On 02/23/2010 10:10 PM, Wu Fengguang wrote:
> Introduce a readahead flags field and embed the existing mmap_miss in it
> (mainly to save space).
>
> It also changes the mmap_miss upper bound from LONG_MAX to 4096.
> This is to help adapt properly for changing mmap access patterns.
>
> It will be possible to lose the flags in race conditions, however the
> impact should be limited.  For the race to happen, there must be two
> threads sharing the same file descriptor to be in page fault or
> readahead at the same time.
>
> Note that it has always been racy for "page faults" at the same time.
>
> And if ever the race happen, we'll lose one mmap_miss++ or mmap_miss--.
> Which may change some concrete readahead behavior, but won't really
> impact overall I/O performance.
>
> CC: Nick Piggin<npiggin@suse.de>
> CC: Andi Kleen<andi@firstfloor.org>
> CC: Steven Whitehouse<swhiteho@redhat.com>
> Signed-off-by: Wu Fengguang<fengguang.wu@intel.com>

Acked-by: Rik van Riel <riel@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
