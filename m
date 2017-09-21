Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f198.google.com (mail-yw0-f198.google.com [209.85.161.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9AD846B0038
	for <linux-mm@kvack.org>; Thu, 21 Sep 2017 13:33:46 -0400 (EDT)
Received: by mail-yw0-f198.google.com with SMTP id s62so11802183ywg.3
        for <linux-mm@kvack.org>; Thu, 21 Sep 2017 10:33:46 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id v127si415935ybe.128.2017.09.21.10.33.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Sep 2017 10:33:44 -0700 (PDT)
Date: Thu, 21 Sep 2017 10:33:39 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 7/7] fs-writeback: only allow one inflight and pending
 full flush
Message-ID: <20170921173339.GA13384@infradead.org>
References: <1505921582-26709-1-git-send-email-axboe@kernel.dk>
 <1505921582-26709-8-git-send-email-axboe@kernel.dk>
 <20170921150510.GH8839@infradead.org>
 <728d4141-8d73-97fb-de08-90671c2897da@kernel.dk>
 <3682c4c2-6e8a-e883-9f62-455ea2944496@kernel.dk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3682c4c2-6e8a-e883-9f62-455ea2944496@kernel.dk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@kernel.dk>
Cc: Christoph Hellwig <hch@infradead.org>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, hannes@cmpxchg.org, clm@fb.com, jack@suse.cz

On Thu, Sep 21, 2017 at 10:00:25AM -0600, Jens Axboe wrote:
> Something like the below would fit on top to do that. Gets rid of the
> allocation and embeds the work item for global start-all in the
> bdi_writeback structure.

Something like that.  Although if we still kalloc the global
wb we wouldn't have to expose all the details in the header.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
