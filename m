Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3734E6B0038
	for <linux-mm@kvack.org>; Thu, 21 Sep 2017 11:00:51 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id p5so12056095pgn.7
        for <linux-mm@kvack.org>; Thu, 21 Sep 2017 08:00:51 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id a6si1268956plt.502.2017.09.21.08.00.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Sep 2017 08:00:48 -0700 (PDT)
Date: Thu, 21 Sep 2017 08:00:47 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 4/7] page-writeback: pass in '0' for nr_pages writeback
 in laptop mode
Message-ID: <20170921150047.GE8839@infradead.org>
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

On Wed, Sep 20, 2017 at 09:32:59AM -0600, Jens Axboe wrote:
> Use the new wakeup_flusher_threads_bdi() instead of rolling
> our own. This changes the writeback to not be range cyclic,
> but that should not matter for laptop mode flush-all
> semantics.

Oh btw - I think this actually is the more important change and
should probably be in the subject line.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
