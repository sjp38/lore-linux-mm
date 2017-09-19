Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1526B6B0253
	for <linux-mm@kvack.org>; Tue, 19 Sep 2017 16:08:04 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id i131so588263wma.1
        for <linux-mm@kvack.org>; Tue, 19 Sep 2017 13:08:04 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id 22si115446edw.486.2017.09.19.13.08.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 19 Sep 2017 13:08:03 -0700 (PDT)
Date: Tue, 19 Sep 2017 16:07:59 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 5/6] fs-writeback: move nr_pages == 0 logic to one
 location
Message-ID: <20170919200759.GE11873@cmpxchg.org>
References: <1505850787-18311-1-git-send-email-axboe@kernel.dk>
 <1505850787-18311-6-git-send-email-axboe@kernel.dk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1505850787-18311-6-git-send-email-axboe@kernel.dk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@kernel.dk>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, clm@fb.com, jack@suse.cz

On Tue, Sep 19, 2017 at 01:53:06PM -0600, Jens Axboe wrote:
> Now that we have no external callers of wb_start_writeback(),
> we can move the nr_pages == 0 logic into that function.
> 
> Signed-off-by: Jens Axboe <axboe@kernel.dk>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
