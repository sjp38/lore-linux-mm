Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 937D36B01D7
	for <linux-mm@kvack.org>; Wed, 26 May 2010 07:40:26 -0400 (EDT)
Date: Wed, 26 May 2010 13:40:19 +0200
From: Christoph Hellwig <hch@lst.de>
Subject: Re: writeback hang in current mainline
Message-ID: <20100526114018.GA30107@lst.de>
References: <20100526111326.GA28541@lst.de> <20100526112125.GJ23411@kernel.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100526112125.GJ23411@kernel.dk>
Sender: owner-linux-mm@kvack.org
To: Jens Axboe <jens.axboe@oracle.com>
Cc: Christoph Hellwig <hch@lst.de>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, May 26, 2010 at 01:21:25PM +0200, Jens Axboe wrote:
> Not good, can you see if reverting 7c8a3554 makes it go away?

Reverting back to the revision before 7c8a3554 gives me lots of warnings ala:

[  178.253431] ------------[ cut here ]------------
[  178.256845] WARNING: at
/home/hch/work/linux-2.6/fs/fs-writeback.c:596
writeback_inodes_wb+0x423/0x440()
[  178.259995] Hardware name: Bochs
[  178.261270] Modules linked in:
[  178.262508] Pid: 2298, comm: flush-253:16 Tainted: G        W
2.6.34-rc5 #121
[  178.265199] Call Trace:
[  178.266210]  [<c08d86ca>] ? printk+0x18/0x1a
[  178.267597]  [<c0162d0d>] warn_slowpath_common+0x6d/0xa0
[  178.269296]  [<c0216ff3>] ? writeback_inodes_wb+0x423/0x440
[  178.271348]  [<c0216ff3>] ? writeback_inodes_wb+0x423/0x440
[  178.273121]  [<c0162d55>] warn_slowpath_null+0x15/0x20
[  178.274681]  [<c0216ff3>] writeback_inodes_wb+0x423/0x440
[  178.276390]  [<c0217111>] wb_writeback+0x101/0x1b0
[  178.277846]  [<c01a9a79>] ? __call_rcu+0x99/0x130
[  178.279287]  [<c01a9b38>] ? call_rcu+0x8/0x10
[  178.281110]  [<c02161fa>] ? wb_clear_pending+0x7a/0xa0
[  178.282673]  [<c021728f>] wb_do_writeback+0xcf/0x1a0
[  178.284239]  [<c02171e0>] ? wb_do_writeback+0x20/0x1a0
[  178.285823]  [<c021738a>] bdi_writeback_task+0x2a/0x90
[  178.287371]  [<c01dca90>] ? bdi_start_fn+0x0/0xb0
[  178.288992]  [<c01dcae8>] bdi_start_fn+0x58/0xb0
[  178.290823]  [<c01dca90>] ? bdi_start_fn+0x0/0xb0
[  178.292378]  [<c017dc7c>] kthread+0x6c/0x80
[  178.293711]  [<c017dc10>] ? kthread+0x0/0x80
[  178.295073]  [<c013023a>] kernel_thread_helper+0x6/0x1c
[  178.296753] ---[ end trace a7919e7f17c0a80f ]---

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
