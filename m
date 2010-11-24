Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id AB1766B0085
	for <linux-mm@kvack.org>; Wed, 24 Nov 2010 05:26:20 -0500 (EST)
Subject: Re: [PATCH 05/13] writeback: account per-bdi accumulated written
 pages
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <20101117042849.884566722@intel.com>
References: <20101117042720.033773013@intel.com>
	 <20101117042849.884566722@intel.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Wed, 24 Nov 2010 11:26:16 +0100
Message-ID: <1290594376.2072.442.camel@laptop>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, Chris Mason <chris.mason@oracle.com>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, 2010-11-17 at 12:27 +0800, Wu Fengguang wrote:
> @@ -1292,6 +1292,7 @@ int test_clear_page_writeback(struct pag
>                                                 PAGECACHE_TAG_WRITEBACK);
>                         if (bdi_cap_account_writeback(bdi)) {
>                                 __dec_bdi_stat(bdi, BDI_WRITEBACK);
> +                               __inc_bdi_stat(bdi, BDI_WRITTEN);
>                                 __bdi_writeout_inc(bdi);
>                         }
>                 }=20

Shouldn't that live in __bdi_writeout_inc()? It looks like this forgets
about fuse (fuse_writepage_finish() -> bdi_writeout_inc() ->
__bdi_writeout_inc()).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
