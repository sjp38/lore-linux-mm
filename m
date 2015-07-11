Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id E91586B0253
	for <linux-mm@kvack.org>; Sat, 11 Jul 2015 06:02:38 -0400 (EDT)
Received: by pactm7 with SMTP id tm7so180737779pac.2
        for <linux-mm@kvack.org>; Sat, 11 Jul 2015 03:02:38 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id xs6si18567952pab.214.2015.07.11.03.02.34
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 11 Jul 2015 03:02:34 -0700 (PDT)
Date: Sat, 11 Jul 2015 03:02:32 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 0/2] mm/shrinker: make unregister_shrinker() less fragile
Message-ID: <20150711100232.GA4607@infradead.org>
References: <1436583115-6323-1-git-send-email-sergey.senozhatsky@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1436583115-6323-1-git-send-email-sergey.senozhatsky@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>

On Sat, Jul 11, 2015 at 11:51:53AM +0900, Sergey Senozhatsky wrote:
> Hello,
> 
> Shrinker API does not handle nicely unregister_shrinker() on a not-registered
> ->shrinker. Looking at shrinker users, they all have to
> (a) carry on some sort of a flag to make sure that "unregister_shrinker()"
> will not blow up later
> (b) be fishy (potentially can Oops)
> (c) access private members `struct shrinker' (e.g. `shrink.list.next')

Ayone who does that is broken.  You just need to have clear init (with
proper unwinding) and exit functions and order things properly.  It
works like most register/unregister calls and should stay that way.

Maye you you should ty to explain what practical problem you're seeing
to start with.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
