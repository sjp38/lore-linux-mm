Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id A9B1A6B0069
	for <linux-mm@kvack.org>; Tue, 19 Sep 2017 16:05:48 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id i131so583157wma.1
        for <linux-mm@kvack.org>; Tue, 19 Sep 2017 13:05:48 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id g4si118214edh.228.2017.09.19.13.05.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 19 Sep 2017 13:05:47 -0700 (PDT)
Date: Tue, 19 Sep 2017 16:05:39 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 2/6] fs-writeback: provide a wakeup_flusher_threads_bdi()
Message-ID: <20170919200539.GB11873@cmpxchg.org>
References: <1505850787-18311-1-git-send-email-axboe@kernel.dk>
 <1505850787-18311-3-git-send-email-axboe@kernel.dk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1505850787-18311-3-git-send-email-axboe@kernel.dk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@kernel.dk>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, clm@fb.com, jack@suse.cz

On Tue, Sep 19, 2017 at 01:53:03PM -0600, Jens Axboe wrote:
> Similar to wakeup_flusher_threads(), except that we only wake
> up the flusher threads on the specified backing device.
> 
> No functional changes in this patch.
> 
> Signed-off-by: Jens Axboe <axboe@kernel.dk>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
