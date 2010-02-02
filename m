Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 03B796B0098
	for <linux-mm@kvack.org>; Tue,  2 Feb 2010 13:13:22 -0500 (EST)
Date: Tue, 2 Feb 2010 19:13:21 +0100
From: Olivier Galibert <galibert@pobox.com>
Subject: Re: [PATCH 10/11] readahead: dont do start-of-file readahead after lseek()
Message-ID: <20100202181321.GB75577@dspnet.fr.eu.org>
References: <20100202152835.683907822@intel.com> <20100202153317.644170708@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100202153317.644170708@intel.com>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jens Axboe <jens.axboe@oracle.com>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Tue, Feb 02, 2010 at 11:28:45PM +0800, Wu Fengguang wrote:
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

Wouldn't that trigger on lseeks to end of file to get the size?

  OG.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
