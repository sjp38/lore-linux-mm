Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 6AD336B0047
	for <linux-mm@kvack.org>; Thu, 25 Feb 2010 17:38:02 -0500 (EST)
Message-ID: <4B86FBAB.6070807@redhat.com>
Date: Thu, 25 Feb 2010 17:37:31 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 08/15] readahead: record readahead patterns
References: <20100224031001.026464755@intel.com> <20100224031054.734136802@intel.com>
In-Reply-To: <20100224031054.734136802@intel.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jens Axboe <jens.axboe@oracle.com>, Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Chris Mason <chris.mason@oracle.com>, Clemens Ladisch <clemens@ladisch.de>, Olivier Galibert <galibert@pobox.com>, Vivek Goyal <vgoyal@redhat.com>, Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>, Matt Mackall <mpm@selenic.com>, Nick Piggin <npiggin@suse.de>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On 02/23/2010 10:10 PM, Wu Fengguang wrote:
> Record the readahead pattern in ra_flags. This info can be examined by
> users via the readahead tracing/stats interfaces.
>
> Currently 7 patterns are defined:
>
>        	pattern			readahead for
> -----------------------------------------------------------
> 	RA_PATTERN_INITIAL	start-of-file/oversize read
> 	RA_PATTERN_SUBSEQUENT	trivial     sequential read
> 	RA_PATTERN_CONTEXT	interleaved sequential read
> 	RA_PATTERN_THRASH	thrashed    sequential read
> 	RA_PATTERN_MMAP_AROUND	mmap fault
> 	RA_PATTERN_FADVISE	posix_fadvise()
> 	RA_PATTERN_RANDOM	random read
>
> CC: Ingo Molnar<mingo@elte.hu>
> CC: Jens Axboe<jens.axboe@oracle.com>
> CC: Peter Zijlstra<a.p.zijlstra@chello.nl>
> Signed-off-by: Wu Fengguang<fengguang.wu@intel.com>

Acked-by: Rik van Riel <riel@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
