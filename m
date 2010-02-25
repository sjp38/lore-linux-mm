Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id C79EC6B0047
	for <linux-mm@kvack.org>; Wed, 24 Feb 2010 22:11:14 -0500 (EST)
Message-ID: <4B85EA46.5090607@redhat.com>
Date: Wed, 24 Feb 2010 22:11:02 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 01/15] readahead: limit readahead size for small devices
References: <20100224031001.026464755@intel.com> <20100224031053.737437080@intel.com>
In-Reply-To: <20100224031053.737437080@intel.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jens Axboe <jens.axboe@oracle.com>, Li Shaohua <shaohua.li@intel.com>, Clemens Ladisch <clemens@ladisch.de>, Chris Mason <chris.mason@oracle.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Olivier Galibert <galibert@pobox.com>, Vivek Goyal <vgoyal@redhat.com>, Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>, Matt Mackall <mpm@selenic.com>, Nick Piggin <npiggin@suse.de>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On 02/23/2010 10:10 PM, Wu Fengguang wrote:
> Linus reports a _really_ small&  slow (505kB, 15kB/s) USB device,
> on which blkid runs unpleasantly slow. He manages to optimize the blkid
> reads down to 1kB+16kB, but still kernel read-ahead turns it into 48kB.

> CC: Li Shaohua<shaohua.li@intel.com>
> CC: Clemens Ladisch<clemens@ladisch.de>
> Acked-by: Jens Axboe<jens.axboe@oracle.com>
> Tested-by: Vivek Goyal<vgoyal@redhat.com>
> Tested-by: Linus Torvalds<torvalds@linux-foundation.org>
> Signed-off-by: Wu Fengguang<fengguang.wu@intel.com>

Acked-by: Rik van Riel <riel@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
