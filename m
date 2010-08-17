Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id BA83D6B01F4
	for <linux-mm@kvack.org>; Mon, 16 Aug 2010 22:41:43 -0400 (EDT)
Date: Tue, 17 Aug 2010 10:41:40 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [RFC][PATCH] Per file dirty limit throttling
Message-ID: <20100817024140.GB13916@localhost>
References: <201008160949.51512.knikanth@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201008160949.51512.knikanth@suse.de>
Sender: owner-linux-mm@kvack.org
To: Nikanth Karthikesan <knikanth@suse.de>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Jens Axboe <axboe@kernel.dk>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Trond Myklebust <Trond.Myklebust@netapp.com>, Peter Staubach <staubach@redhat.com>
List-ID: <linux-mm.kvack.org>

On Mon, Aug 16, 2010 at 12:19:50PM +0800, Nikanth Karthikesan wrote:
> When the total dirty pages exceed vm_dirty_ratio, the dirtier is made to do
> the writeback. But this dirtier may not be the one who took the system to this
> state. Instead, if we can track the dirty count per-file, we could throttle
> the dirtier of a file, when the file's dirty pages exceed a certain limit.
> Even though this dirtier may not be the one who dirtied the other pages of
> this file, it is fair to throttle this process, as it uses that file.

Nikanth, there's a more elegant solution in upstream kernel.
See the comment for task_dirty_limit() in commit 1babe1838.

NFS may want to limit per-file dirty pages, to prevent long stall time
inside the nfs_getattr()->filemap_write_and_wait() calls (and problems
like that). Peter Staubach has similar ideas on it.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
