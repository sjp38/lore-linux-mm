Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id AF2FD6B0033
	for <linux-mm@kvack.org>; Fri, 22 Sep 2017 09:14:43 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id 97so1211483wrb.1
        for <linux-mm@kvack.org>; Fri, 22 Sep 2017 06:14:43 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h9si3807778edk.169.2017.09.22.06.14.42
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 22 Sep 2017 06:14:42 -0700 (PDT)
Date: Fri, 22 Sep 2017 15:14:38 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 4/7] page-writeback: pass in '0' for nr_pages writeback
 in laptop mode
Message-ID: <20170922131438.GB22455@quack2.suse.cz>
References: <1505921582-26709-1-git-send-email-axboe@kernel.dk>
 <1505921582-26709-5-git-send-email-axboe@kernel.dk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1505921582-26709-5-git-send-email-axboe@kernel.dk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@kernel.dk>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, hannes@cmpxchg.org, clm@fb.com, jack@suse.cz

On Wed 20-09-17 09:32:59, Jens Axboe wrote:
> Laptop mode really wants to writeback the number of dirty
> pages and inodes. Instead of calculating this in the caller,
> just pass in 0 and let wakeup_flusher_threads() handle it.
> 
> Use the new wakeup_flusher_threads_bdi() instead of rolling
> our own. This changes the writeback to not be range cyclic,
> but that should not matter for laptop mode flush-all
> semantics.
> 
> Acked-by: Johannes Weiner <hannes@cmpxchg.org>
> Tested-by: Chris Mason <clm@fb.com>
> Signed-off-by: Jens Axboe <axboe@kernel.dk>
> Reviewed-by: Jan Kara <jack@suse.cz>
> Signed-off-by: Jens Axboe <axboe@kernel.dk>

The subject of the patch looks stale.

									Honza

-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
