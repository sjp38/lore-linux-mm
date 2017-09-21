Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 766486B0038
	for <linux-mm@kvack.org>; Thu, 21 Sep 2017 11:02:15 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id a7so10626496pfj.3
        for <linux-mm@kvack.org>; Thu, 21 Sep 2017 08:02:15 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id k184si1208256pga.79.2017.09.21.08.02.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Sep 2017 08:02:14 -0700 (PDT)
Date: Thu, 21 Sep 2017 08:02:13 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 6/7] fs-writeback: move nr_pages == 0 logic to one
 location
Message-ID: <20170921150213.GG8839@infradead.org>
References: <1505921582-26709-1-git-send-email-axboe@kernel.dk>
 <1505921582-26709-7-git-send-email-axboe@kernel.dk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1505921582-26709-7-git-send-email-axboe@kernel.dk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@kernel.dk>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, hannes@cmpxchg.org, clm@fb.com, jack@suse.cz

Looks fine,

Reviewed-by: Christoph Hellwig <hch@lst.de>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
