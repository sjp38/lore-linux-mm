Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 544596B0255
	for <linux-mm@kvack.org>; Tue, 14 Jul 2015 03:18:08 -0400 (EDT)
Received: by padck2 with SMTP id ck2so1071551pad.0
        for <linux-mm@kvack.org>; Tue, 14 Jul 2015 00:18:08 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id q5si165290pdj.240.2015.07.14.00.18.03
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 Jul 2015 00:18:03 -0700 (PDT)
Date: Tue, 14 Jul 2015 00:17:59 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 0/2] mm/shrinker: make unregister_shrinker() less fragile
Message-ID: <20150714071759.GD31117@infradead.org>
References: <1436583115-6323-1-git-send-email-sergey.senozhatsky@gmail.com>
 <20150711100232.GA4607@infradead.org>
 <20150712024732.GA787@swordfish>
 <20150713063341.GA24167@infradead.org>
 <20150713065253.GA811@swordfish>
 <20150713090358.GA28901@infradead.org>
 <20150713092531.GA578@swordfish>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150713092531.GA578@swordfish>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Christoph Hellwig <hch@infradead.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Jul 13, 2015 at 06:34:42PM +0900, Sergey Senozhatsky wrote:
> Yes. 'Nice' used in a sense that drivers have logic to release the
> memory anyway; mm asks volunteers (the drivers that have registered
> shrinker callbacks) to release some spare/wasted/etc. when things
> are getting tough (the drivers are not aware of that in general).
> This is surely important to mm, not to the driver though -- it just
> agrees to be 'nice', but even not expected to release any memory at
> all (IOW, this is not a contract).

Not registering the shrinker is a plain and simple memory leak.  Just
like a missing free your driver will appear to work fine for a while,
but eventually the leaks will bring down the whole system including
your driver.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
