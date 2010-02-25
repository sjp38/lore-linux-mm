Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id ABA7B6B0047
	for <linux-mm@kvack.org>; Thu, 25 Feb 2010 18:42:51 -0500 (EST)
Message-ID: <4B870AF1.90300@redhat.com>
Date: Thu, 25 Feb 2010 18:42:41 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 14/15] readahead: reduce MMAP_LOTSAMISS for mmap read-around
References: <20100224031001.026464755@intel.com> <20100224031055.594006457@intel.com>
In-Reply-To: <20100224031055.594006457@intel.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jens Axboe <jens.axboe@oracle.com>, Nick Piggin <npiggin@suse.de>, Chris Mason <chris.mason@oracle.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Clemens Ladisch <clemens@ladisch.de>, Olivier Galibert <galibert@pobox.com>, Vivek Goyal <vgoyal@redhat.com>, Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>, Matt Mackall <mpm@selenic.com>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On 02/23/2010 10:10 PM, Wu Fengguang wrote:
> Now that we lifts readahead size from 128KB to 512KB,
> the MMAP_LOTSAMISS shall be shrinked accordingly.
>
> We shrink it a bit more, so that for sparse random access patterns,
> only 10*512KB or ~5MB memory will be wasted, instead of the previous
> 100*128KB or ~12MB. The new threshold "10" is still big enough to avoid
> turning off read-around for typical executable/lib page faults.
>
> CC: Nick Piggin<npiggin@suse.de>
> Signed-off-by: Wu Fengguang<fengguang.wu@intel.com>

Acked-by: Rik van Riel <riel@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
