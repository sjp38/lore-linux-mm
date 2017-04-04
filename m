Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6BA496B0390
	for <linux-mm@kvack.org>; Tue,  4 Apr 2017 03:10:37 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id u3so164105205pgn.12
        for <linux-mm@kvack.org>; Tue, 04 Apr 2017 00:10:37 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id d11si16540864pln.319.2017.04.04.00.10.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Apr 2017 00:10:36 -0700 (PDT)
Date: Tue, 4 Apr 2017 00:10:33 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH] loop: Add PF_LESS_THROTTLE to block/loop device thread.
Message-ID: <20170404071033.GA25855@infradead.org>
References: <871staffus.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <871staffus.fsf@notabene.neil.brown.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: NeilBrown <neilb@suse.com>
Cc: Jens Axboe <axboe@fb.com>, linux-block@vger.kernel.org, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

Looks fine,

Reviewed-by: Christoph Hellwig <hch@lst.de>

But if you actually care about performance in any way I'd suggest
to use the loop device in direct I/O mode..

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
