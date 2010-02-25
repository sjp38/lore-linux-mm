Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id E72C46B004D
	for <linux-mm@kvack.org>; Thu, 25 Feb 2010 10:00:57 -0500 (EST)
Message-ID: <4B86909E.3080009@redhat.com>
Date: Thu, 25 Feb 2010 10:00:46 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 05/15] readahead: limit readahead size for small memory
 systems
References: <20100224031001.026464755@intel.com> <20100224031054.307027163@intel.com>
In-Reply-To: <20100224031054.307027163@intel.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jens Axboe <jens.axboe@oracle.com>, Matt Mackall <mpm@selenic.com>, Chris Mason <chris.mason@oracle.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Clemens Ladisch <clemens@ladisch.de>, Olivier Galibert <galibert@pobox.com>, Vivek Goyal <vgoyal@redhat.com>, Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>, Nick Piggin <npiggin@suse.de>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On 02/23/2010 10:10 PM, Wu Fengguang wrote:
> When lifting the default readahead size from 128KB to 512KB,
> make sure it won't add memory pressure to small memory systems.
>
> For read-ahead, the memory pressure is mainly readahead buffers consumed
> by too many concurrent streams. The context readahead can adapt
> readahead size to thrashing threshold well.  So in principle we don't
> need to adapt the default _max_ read-ahead size to memory pressure.
>
> For read-around, the memory pressure is mainly read-around misses on
> executables/libraries. Which could be reduced by scaling down
> read-around size on fast "reclaim passes".
>
> This patch presents a straightforward solution: to limit default
> readahead size proportional to available system memory, ie.
>                  512MB mem =>  512KB readahead size
>                  128MB mem =>  128KB readahead size
>                   32MB mem =>   32KB readahead size (minimal)
>
> Strictly speaking, only read-around size has to be limited.  However we
> don't bother to seperate read-around size from read-ahead size for now.
>
> CC: Matt Mackall<mpm@selenic.com>
> Signed-off-by: Wu Fengguang<fengguang.wu@intel.com>

Acked-by: Rik van Riel <riel@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
