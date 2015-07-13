Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 7CD8A6B0253
	for <linux-mm@kvack.org>; Mon, 13 Jul 2015 02:52:23 -0400 (EDT)
Received: by pachj5 with SMTP id hj5so26941448pac.3
        for <linux-mm@kvack.org>; Sun, 12 Jul 2015 23:52:23 -0700 (PDT)
Received: from mail-pa0-x22b.google.com (mail-pa0-x22b.google.com. [2607:f8b0:400e:c03::22b])
        by mx.google.com with ESMTPS id g6si10548832pdn.197.2015.07.12.23.52.22
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 12 Jul 2015 23:52:22 -0700 (PDT)
Received: by pachj5 with SMTP id hj5so26941228pac.3
        for <linux-mm@kvack.org>; Sun, 12 Jul 2015 23:52:22 -0700 (PDT)
Date: Mon, 13 Jul 2015 15:52:53 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH 0/2] mm/shrinker: make unregister_shrinker() less fragile
Message-ID: <20150713065253.GA811@swordfish>
References: <1436583115-6323-1-git-send-email-sergey.senozhatsky@gmail.com>
 <20150711100232.GA4607@infradead.org>
 <20150712024732.GA787@swordfish>
 <20150713063341.GA24167@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150713063341.GA24167@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>

On (07/12/15 23:33), Christoph Hellwig wrote:
> On Sun, Jul 12, 2015 at 11:47:32AM +0900, Sergey Senozhatsky wrote:
> > Yes, but the main difference here is that it seems that shrinker users
> > don't tend to treat shrinker registration failures as fatal errors and
> > just continue with shrinker functionality disabled. And it makes sense.
> > 
> > (copy paste from https://lkml.org/lkml/2015/7/9/751)
> > 
> 
> I hearily disagree.  It's not any less critical than other failures.

Why? In some sense, shrinker callbacks are just a way to be nice.
No one writes a driver just to be able to handle shrinker calls. An
ability to react to those calls is just additional option; it does
not directly affect or limit driver's functionality (at least, it
really should not).

> The right way forward is to handle register failure properly.

In other words, to
 (a) keep a flag to signify that register was not successful
or
 (b) look at ->shrinker.list.next or ->nr_deferred
or
 (c) treat register failures as critical errors. (I sort of
     disagree with you here).

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
