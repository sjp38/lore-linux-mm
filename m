Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id E59766B0253
	for <linux-mm@kvack.org>; Mon, 13 Jul 2015 02:33:44 -0400 (EDT)
Received: by pactm7 with SMTP id tm7so201966462pac.2
        for <linux-mm@kvack.org>; Sun, 12 Jul 2015 23:33:44 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id jf2si20737898pbd.115.2015.07.12.23.33.43
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 12 Jul 2015 23:33:43 -0700 (PDT)
Date: Sun, 12 Jul 2015 23:33:41 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 0/2] mm/shrinker: make unregister_shrinker() less fragile
Message-ID: <20150713063341.GA24167@infradead.org>
References: <1436583115-6323-1-git-send-email-sergey.senozhatsky@gmail.com>
 <20150711100232.GA4607@infradead.org>
 <20150712024732.GA787@swordfish>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150712024732.GA787@swordfish>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Cc: Christoph Hellwig <hch@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>

On Sun, Jul 12, 2015 at 11:47:32AM +0900, Sergey Senozhatsky wrote:
> Yes, but the main difference here is that it seems that shrinker users
> don't tend to treat shrinker registration failures as fatal errors and
> just continue with shrinker functionality disabled. And it makes sense.
> 
> (copy paste from https://lkml.org/lkml/2015/7/9/751)
> 

I hearily disagree.  It's not any less critical than other failures.

The right way forward is to handle register failure properly.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
