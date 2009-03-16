Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id D23DD6B003D
	for <linux-mm@kvack.org>; Mon, 16 Mar 2009 06:22:59 -0400 (EDT)
Date: Mon, 16 Mar 2009 06:22:53 -0400
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 2/7] writeback: switch to per-bdi threads for flushing
	data
Message-ID: <20090316102253.GB9510@infradead.org>
References: <1236868428-20408-1-git-send-email-jens.axboe@oracle.com> <1236868428-20408-3-git-send-email-jens.axboe@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1236868428-20408-3-git-send-email-jens.axboe@oracle.com>
Sender: owner-linux-mm@kvack.org
To: Jens Axboe <jens.axboe@oracle.com>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, chris.mason@oracle.com, david@fromorbit.com, npiggin@suse.de, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Mar 12, 2009 at 03:33:43PM +0100, Jens Axboe wrote:
> +static void bdi_kupdated(struct backing_dev_info *bdi)
> +{
> +	long nr_to_write;
> +	struct writeback_control wbc = {
> +		.bdi		= bdi,
> +		.sync_mode	= WB_SYNC_NONE,
> +		.nr_to_write	= 0,
> +		.for_kupdate	= 1,
> +		.range_cyclic	= 1,
> +	};
> +
> +	sync_supers();

Not directly related to your patch, but can someone explain WTF
sync_supers is doing here or in the old kupdated?  We're writing back
dirty pages from the VM, and for some reason we try to also write back
superblocks.   This doesn't really make any sense.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
