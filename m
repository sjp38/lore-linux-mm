Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id B35F56B0069
	for <linux-mm@kvack.org>; Tue, 19 Sep 2017 16:07:31 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id r74so565960wme.5
        for <linux-mm@kvack.org>; Tue, 19 Sep 2017 13:07:31 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id r21si104868edc.507.2017.09.19.13.07.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 19 Sep 2017 13:07:30 -0700 (PDT)
Date: Tue, 19 Sep 2017 16:07:27 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 4/6] fs-writeback: make wb_start_writeback() static
Message-ID: <20170919200727.GD11873@cmpxchg.org>
References: <1505850787-18311-1-git-send-email-axboe@kernel.dk>
 <1505850787-18311-5-git-send-email-axboe@kernel.dk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1505850787-18311-5-git-send-email-axboe@kernel.dk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@kernel.dk>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, clm@fb.com, jack@suse.cz

On Tue, Sep 19, 2017 at 01:53:05PM -0600, Jens Axboe wrote:
> We don't have any callers outside of fs-writeback.c anymore,
> make it private.
> 
> Signed-off-by: Jens Axboe <axboe@kernel.dk>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
