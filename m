Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 75FE56B004D
	for <linux-mm@kvack.org>; Wed, 24 Feb 2010 22:17:54 -0500 (EST)
Message-ID: <4B85EBD5.2050006@redhat.com>
Date: Wed, 24 Feb 2010 22:17:41 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 02/15] readahead: retain inactive lru pages to be accessed
 soon
References: <20100224031001.026464755@intel.com> <20100224031053.886603916@intel.com>
In-Reply-To: <20100224031053.886603916@intel.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jens Axboe <jens.axboe@oracle.com>, Chris Frost <frost@cs.ucla.edu>, Steve VanDeBogart <vandebo@cs.ucla.edu>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Chris Mason <chris.mason@oracle.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Clemens Ladisch <clemens@ladisch.de>, Olivier Galibert <galibert@pobox.com>, Vivek Goyal <vgoyal@redhat.com>, Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>, Matt Mackall <mpm@selenic.com>, Nick Piggin <npiggin@suse.de>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On 02/23/2010 10:10 PM, Wu Fengguang wrote:
> From: Chris Frost<frost@cs.ucla.edu>
>
> Ensure that cached pages in the inactive list are not prematurely evicted;
> move such pages to lru head when they are covered by
> - in-kernel heuristic readahead
> - an posix_fadvise(POSIX_FADV_WILLNEED) hint from an application

> Signed-off-by: Chris Frost<frost@cs.ucla.edu>
> Signed-off-by: Steve VanDeBogart<vandebo@cs.ucla.edu>
> Signed-off-by: KAMEZAWA Hiroyuki<kamezawa.hiroyu@jp.fujitsu.com>
> Signed-off-by: Wu Fengguang<fengguang.wu@intel.com>

Acked-by: Rik van Riel <riel@redhat.com>

When we get into the situation where readahead thrashing
would occur, we will end up evicting other stuff more
quickly from the inactive file list.  However, that will
be the case either with or without this code...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
