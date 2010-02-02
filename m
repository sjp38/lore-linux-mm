Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 0F72A6B009C
	for <linux-mm@kvack.org>; Tue,  2 Feb 2010 12:41:35 -0500 (EST)
Date: Tue, 2 Feb 2010 09:39:38 -0800 (PST)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH 10/11] readahead: dont do start-of-file readahead after
 lseek()
In-Reply-To: <20100202153317.644170708@intel.com>
Message-ID: <alpine.LFD.2.00.1002020939220.3664@localhost.localdomain>
References: <20100202152835.683907822@intel.com> <20100202153317.644170708@intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jens Axboe <jens.axboe@oracle.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>



On Tue, 2 Feb 2010, Wu Fengguang wrote:
>
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
> CC: Linus Torvalds <torvalds@linux-foundation.org> 
> Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>

Acked-by: Linus Torvalds <torvalds@linux-foundation.org>

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
