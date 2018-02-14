Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 165B26B0006
	for <linux-mm@kvack.org>; Wed, 14 Feb 2018 14:56:35 -0500 (EST)
Received: by mail-pl0-f71.google.com with SMTP id b3so11344362plr.23
        for <linux-mm@kvack.org>; Wed, 14 Feb 2018 11:56:35 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id w6si1577691pfj.311.2018.02.14.11.56.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 14 Feb 2018 11:56:34 -0800 (PST)
Date: Wed, 14 Feb 2018 11:56:31 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH 0/2] Add kvzalloc_struct to complement kvzalloc_array
Message-ID: <20180214195631.GC20627@bombadil.infradead.org>
References: <20180214182618.14627-1-willy@infradead.org>
 <1518634058.3678.15.camel@perches.com>
 <CAGXu5jJdAJt3HK7FgaCyPRbXeFV-hJOrPodNnOkx=kCvSieK3w@mail.gmail.com>
 <1518636765.3678.19.camel@perches.com>
 <20180214193613.GB20627@bombadil.infradead.org>
 <1518637426.3678.21.camel@perches.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1518637426.3678.21.camel@perches.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joe Perches <joe@perches.com>
Cc: Kees Cook <keescook@chromium.org>, Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <mawilcox@microsoft.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Kernel Hardening <kernel-hardening@lists.openwall.com>

On Wed, Feb 14, 2018 at 11:43:46AM -0800, Joe Perches wrote:
> On Wed, 2018-02-14 at 11:36 -0800, Matthew Wilcox wrote:
> > If somebody wants them, then we can add them.
> 
> Yeah, but I don't think any of it is necessary.
> 
> How many of these struct+bufsize * count entries
> actually exist?

Wrong question.  How many of them currently exist that don't check for
integer overflow?  How many of them will be added in the future that
will fail to check for integer overflow?

I chose five at random to fix as demonstration that the API is good.
There are more; I imagine that Julia will be able to tell us how many.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
