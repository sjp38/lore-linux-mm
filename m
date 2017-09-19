Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id C3BB96B0033
	for <linux-mm@kvack.org>; Tue, 19 Sep 2017 16:05:17 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id b9so643034wra.3
        for <linux-mm@kvack.org>; Tue, 19 Sep 2017 13:05:17 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id n23si151689edd.38.2017.09.19.13.05.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 19 Sep 2017 13:05:16 -0700 (PDT)
Date: Tue, 19 Sep 2017 16:05:09 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 1/6] buffer: cleanup free_more_memory() flusher wakeup
Message-ID: <20170919200509.GA11873@cmpxchg.org>
References: <1505850787-18311-1-git-send-email-axboe@kernel.dk>
 <1505850787-18311-2-git-send-email-axboe@kernel.dk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1505850787-18311-2-git-send-email-axboe@kernel.dk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@kernel.dk>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, clm@fb.com, jack@suse.cz

On Tue, Sep 19, 2017 at 01:53:02PM -0600, Jens Axboe wrote:
> This whole function is... interesting. Change the wakeup call
> to the flusher threads to pass in nr_pages == 0, instead of
> some random number of pages. This matches more closely what
> similar cases do for memory shortage/reclaim.
> 
> Signed-off-by: Jens Axboe <axboe@kernel.dk>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
