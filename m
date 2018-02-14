Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 434F26B0005
	for <linux-mm@kvack.org>; Wed, 14 Feb 2018 15:06:08 -0500 (EST)
Received: by mail-it0-f69.google.com with SMTP id l16so13138207iti.4
        for <linux-mm@kvack.org>; Wed, 14 Feb 2018 12:06:08 -0800 (PST)
Received: from smtprelay.hostedemail.com (smtprelay0086.hostedemail.com. [216.40.44.86])
        by mx.google.com with ESMTPS id u35si445081ioi.278.2018.02.14.12.06.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Feb 2018 12:06:07 -0800 (PST)
Message-ID: <1518638764.3678.23.camel@perches.com>
Subject: Re: [PATCH 0/2] Add kvzalloc_struct to complement kvzalloc_array
From: Joe Perches <joe@perches.com>
Date: Wed, 14 Feb 2018 12:06:04 -0800
In-Reply-To: <20180214195631.GC20627@bombadil.infradead.org>
References: <20180214182618.14627-1-willy@infradead.org>
	 <1518634058.3678.15.camel@perches.com>
	 <CAGXu5jJdAJt3HK7FgaCyPRbXeFV-hJOrPodNnOkx=kCvSieK3w@mail.gmail.com>
	 <1518636765.3678.19.camel@perches.com>
	 <20180214193613.GB20627@bombadil.infradead.org>
	 <1518637426.3678.21.camel@perches.com>
	 <20180214195631.GC20627@bombadil.infradead.org>
Content-Type: text/plain; charset="ISO-8859-1"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Kees Cook <keescook@chromium.org>, Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <mawilcox@microsoft.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Kernel Hardening <kernel-hardening@lists.openwall.com>

On Wed, 2018-02-14 at 11:56 -0800, Matthew Wilcox wrote:
> On Wed, Feb 14, 2018 at 11:43:46AM -0800, Joe Perches wrote:
> > On Wed, 2018-02-14 at 11:36 -0800, Matthew Wilcox wrote:
> > > If somebody wants them, then we can add them.
> > 
> > Yeah, but I don't think any of it is necessary.
> > 
> > How many of these struct+bufsize * count entries
> > actually exist?
> 
> Wrong question.  How many of them currently exist that don't check for
> integer overflow?  How many of them will be added in the future that
> will fail to check for integer overflow?
> 
> I chose five at random to fix as demonstration that the API is good.
> There are more; I imagine that Julia will be able to tell us how many.

No such conversions exist in the patch series
you submitted.

What are those?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
