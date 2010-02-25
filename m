Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 1B9A86B0047
	for <linux-mm@kvack.org>; Thu, 25 Feb 2010 17:42:50 -0500 (EST)
Message-ID: <4B86FCDE.1010201@redhat.com>
Date: Thu, 25 Feb 2010 17:42:38 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 11/15] readahead: dont do start-of-file readahead after
 lseek()
References: <20100224031001.026464755@intel.com> <20100224031055.164120692@intel.com>
In-Reply-To: <20100224031055.164120692@intel.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jens Axboe <jens.axboe@oracle.com>, Linus Torvalds <torvalds@linux-foundation.org>, Chris Mason <chris.mason@oracle.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Clemens Ladisch <clemens@ladisch.de>, Olivier Galibert <galibert@pobox.com>, Vivek Goyal <vgoyal@redhat.com>, Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>, Matt Mackall <mpm@selenic.com>, Nick Piggin <npiggin@suse.de>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On 02/23/2010 10:10 PM, Wu Fengguang wrote:
> Some applications (eg. blkid, id3tool etc.) seek around the file
> to get information. For example, blkid does
> 	     seek to	0
> 	     read	1024
> 	     seek to	1536
> 	     read	16384
>
> The start-of-file readahead heuristic is wrong for them, whose
> access pattern can be identified by lseek() calls.
>
> So test-and-set a READAHEAD_LSEEK flag on lseek() and don't
> do start-of-file readahead on seeing it. Proposed by Linus.
>
> Acked-by: Linus Torvalds<torvalds@linux-foundation.org>
> Signed-off-by: Wu Fengguang<fengguang.wu@intel.com>

Acked-by: Rik van Riel <riel@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
