Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id BDAB66B003D
	for <linux-mm@kvack.org>; Mon, 16 Mar 2009 09:39:33 -0400 (EDT)
Date: Mon, 16 Mar 2009 09:39:23 -0400
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 2/7] writeback: switch to per-bdi threads for flushing
	data
Message-ID: <20090316133923.GA27393@infradead.org>
References: <1236868428-20408-1-git-send-email-jens.axboe@oracle.com> <1236868428-20408-3-git-send-email-jens.axboe@oracle.com> <20090316102253.GB9510@infradead.org> <1237210214.30224.3.camel@think.oraclecorp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1237210214.30224.3.camel@think.oraclecorp.com>
Sender: owner-linux-mm@kvack.org
To: Chris Mason <chris.mason@oracle.com>
Cc: Christoph Hellwig <hch@infradead.org>, Jens Axboe <jens.axboe@oracle.com>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, david@fromorbit.com, npiggin@suse.de, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Mar 16, 2009 at 09:30:14AM -0400, Chris Mason wrote:
> Some of our poor filesystem cousins don't write the super until kupdate
> kicks them (see ext2_write_super).  kupdate has always been the periodic
> FS thread of last resort.

Yikes, looks like this is indeed the only peridocial sb update for many
simpler filesystems.  We should really have a separate thread for that
instead of hacking it into VM writeback.  Especially with the per-bdi
one where the current setup doesn't make any sense.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
