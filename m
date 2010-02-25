Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 72FBD6B0047
	for <linux-mm@kvack.org>; Wed, 24 Feb 2010 23:02:37 -0500 (EST)
Message-ID: <4B85F648.1080607@redhat.com>
Date: Wed, 24 Feb 2010 23:02:16 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 03/15] readahead: bump up the default readahead size
References: <20100224031001.026464755@intel.com> <20100224031054.032435626@intel.com>
In-Reply-To: <20100224031054.032435626@intel.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jens Axboe <jens.axboe@oracle.com>, Chris Mason <chris.mason@oracle.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Paul Gortmaker <paul.gortmaker@windriver.com>, Matt Mackall <mpm@selenic.com>, David Woodhouse <dwmw2@infradead.org>, Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>, Clemens Ladisch <clemens@ladisch.de>, Olivier Galibert <galibert@pobox.com>, Vivek Goyal <vgoyal@redhat.com>, Nick Piggin <npiggin@suse.de>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On 02/23/2010 10:10 PM, Wu Fengguang wrote:
> Use 512kb max readahead size, and 32kb min readahead size.
>
> The former helps io performance for common workloads.
> The latter will be used in the thrashing safe context readahead.

> CC: Jens Axboe<jens.axboe@oracle.com>
> CC: Chris Mason<chris.mason@oracle.com>
> CC: Peter Zijlstra<a.p.zijlstra@chello.nl>
> CC: Martin Schwidefsky<schwidefsky@de.ibm.com>
> CC: Paul Gortmaker<paul.gortmaker@windriver.com>
> CC: Matt Mackall<mpm@selenic.com>
> CC: David Woodhouse<dwmw2@infradead.org>
> Tested-by: Vivek Goyal<vgoyal@redhat.com>
> Tested-by: Christian Ehrhardt<ehrhardt@linux.vnet.ibm.com>
> Acked-by:  Christian Ehrhardt<ehrhardt@linux.vnet.ibm.com>
> Signed-off-by: Wu Fengguang<fengguang.wu@intel.com>

Acked-by: Rik van Riel <riel@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
