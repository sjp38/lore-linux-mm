Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 9D80F6B02B5
	for <linux-mm@kvack.org>; Fri,  6 Aug 2010 06:14:31 -0400 (EDT)
Subject: Re: [PATCH 02/13] writeback: avoid unnecessary calculation of bdi
 dirty thresholds
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <20100805162432.963007535@intel.com>
References: <20100805161051.501816677@intel.com>
	 <20100805162432.963007535@intel.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Fri, 06 Aug 2010 12:14:10 +0200
Message-ID: <1281089650.1947.404.camel@laptop>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Dave Chinner <david@fromorbit.com>, Christoph Hellwig <hch@infradead.org>, Mel Gorman <mel@csn.ul.ie>, Chris Mason <chris.mason@oracle.com>, Jens Axboe <axboe@kernel.dk>, Jan Kara <jack@suse.cz>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, 2010-08-06 at 00:10 +0800, Wu Fengguang wrote:
> plain text document attachment (writeback-less-bdi-calc.patch)
> Split get_dirty_limits() into global_dirty_limits()+bdi_dirty_limit(),
> so that the latter can be avoided when under global dirty background
> threshold (which is the normal state for most systems).
>=20
Acked-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
> Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
