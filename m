Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id A80966B0253
	for <linux-mm@kvack.org>; Mon, 13 Jul 2015 05:04:01 -0400 (EDT)
Received: by pactm7 with SMTP id tm7so204176781pac.2
        for <linux-mm@kvack.org>; Mon, 13 Jul 2015 02:04:01 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id ox1si27428831pdb.28.2015.07.13.02.04.00
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 Jul 2015 02:04:00 -0700 (PDT)
Date: Mon, 13 Jul 2015 02:03:58 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 0/2] mm/shrinker: make unregister_shrinker() less fragile
Message-ID: <20150713090358.GA28901@infradead.org>
References: <1436583115-6323-1-git-send-email-sergey.senozhatsky@gmail.com>
 <20150711100232.GA4607@infradead.org>
 <20150712024732.GA787@swordfish>
 <20150713063341.GA24167@infradead.org>
 <20150713065253.GA811@swordfish>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150713065253.GA811@swordfish>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Jul 13, 2015 at 03:52:53PM +0900, Sergey Senozhatsky wrote:
> Why? In some sense, shrinker callbacks are just a way to be nice.
> No one writes a driver just to be able to handle shrinker calls. An
> ability to react to those calls is just additional option; it does
> not directly affect or limit driver's functionality (at least, it
> really should not).

No, they are not just nice.  They are a fundamental part of memory
management and required to reclaim (often large) amounts of memory.

Nevermind that we don't ignore any other registration time error in
the kernel.

> > The right way forward is to handle register failure properly.
> 
> In other words, to
>  (a) keep a flag to signify that register was not successful
> or
>  (b) look at ->shrinker.list.next or ->nr_deferred
> or
>  (c) treat register failures as critical errors. (I sort of
>      disagree with you here).

The only important part is here is (c).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
