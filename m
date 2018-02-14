Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 191546B0007
	for <linux-mm@kvack.org>; Wed, 14 Feb 2018 14:36:18 -0500 (EST)
Received: by mail-pl0-f69.google.com with SMTP id w16so11400459plp.20
        for <linux-mm@kvack.org>; Wed, 14 Feb 2018 11:36:18 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id z3-v6si3244959plb.117.2018.02.14.11.36.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 14 Feb 2018 11:36:17 -0800 (PST)
Date: Wed, 14 Feb 2018 11:36:13 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH 0/2] Add kvzalloc_struct to complement kvzalloc_array
Message-ID: <20180214193613.GB20627@bombadil.infradead.org>
References: <20180214182618.14627-1-willy@infradead.org>
 <1518634058.3678.15.camel@perches.com>
 <CAGXu5jJdAJt3HK7FgaCyPRbXeFV-hJOrPodNnOkx=kCvSieK3w@mail.gmail.com>
 <1518636765.3678.19.camel@perches.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1518636765.3678.19.camel@perches.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joe Perches <joe@perches.com>
Cc: Kees Cook <keescook@chromium.org>, Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <mawilcox@microsoft.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Kernel Hardening <kernel-hardening@lists.openwall.com>

On Wed, Feb 14, 2018 at 11:32:45AM -0800, Joe Perches wrote:
> On Wed, 2018-02-14 at 11:23 -0800, Kees Cook wrote:
> > On Wed, Feb 14, 2018 at 10:47 AM, Joe Perches <joe@perches.com> wrote:
> > > I think expanding the number of allocation functions
> > > is not necessary.
> > 
> > I think removing common mispatterns in favor of overflow-protected
> > allocation functions makes sense.
> 
> Function symmetry matters too.
> 
> These allocation functions are specific to kvz<foo>
> and are not symmetric for k<foo>, v<foo>, devm_<foo>
> <foo>_node, and the like.

If somebody wants them, then we can add them.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
