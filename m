Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id DCBEC6B0038
	for <linux-mm@kvack.org>; Thu, 21 Sep 2017 10:55:31 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id 188so12068483pgb.3
        for <linux-mm@kvack.org>; Thu, 21 Sep 2017 07:55:31 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id c8si1134281pfm.48.2017.09.21.07.55.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Sep 2017 07:55:29 -0700 (PDT)
Date: Thu, 21 Sep 2017 07:55:27 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 1/7] buffer: cleanup free_more_memory() flusher wakeup
Message-ID: <20170921145527.GA8839@infradead.org>
References: <1505921582-26709-1-git-send-email-axboe@kernel.dk>
 <1505921582-26709-2-git-send-email-axboe@kernel.dk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1505921582-26709-2-git-send-email-axboe@kernel.dk>
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
