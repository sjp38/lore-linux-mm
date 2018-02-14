Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4B2476B0005
	for <linux-mm@kvack.org>; Wed, 14 Feb 2018 14:43:50 -0500 (EST)
Received: by mail-io0-f199.google.com with SMTP id w17so20696066iow.23
        for <linux-mm@kvack.org>; Wed, 14 Feb 2018 11:43:50 -0800 (PST)
Received: from smtprelay.hostedemail.com (smtprelay0235.hostedemail.com. [216.40.44.235])
        by mx.google.com with ESMTPS id i70si1746058itc.37.2018.02.14.11.43.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Feb 2018 11:43:49 -0800 (PST)
Message-ID: <1518637426.3678.21.camel@perches.com>
Subject: Re: [PATCH 0/2] Add kvzalloc_struct to complement kvzalloc_array
From: Joe Perches <joe@perches.com>
Date: Wed, 14 Feb 2018 11:43:46 -0800
In-Reply-To: <20180214193613.GB20627@bombadil.infradead.org>
References: <20180214182618.14627-1-willy@infradead.org>
	 <1518634058.3678.15.camel@perches.com>
	 <CAGXu5jJdAJt3HK7FgaCyPRbXeFV-hJOrPodNnOkx=kCvSieK3w@mail.gmail.com>
	 <1518636765.3678.19.camel@perches.com>
	 <20180214193613.GB20627@bombadil.infradead.org>
Content-Type: text/plain; charset="ISO-8859-1"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Kees Cook <keescook@chromium.org>, Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <mawilcox@microsoft.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Kernel Hardening <kernel-hardening@lists.openwall.com>

On Wed, 2018-02-14 at 11:36 -0800, Matthew Wilcox wrote:
> On Wed, Feb 14, 2018 at 11:32:45AM -0800, Joe Perches wrote:
> > On Wed, 2018-02-14 at 11:23 -0800, Kees Cook wrote:
> > > On Wed, Feb 14, 2018 at 10:47 AM, Joe Perches <joe@perches.com> wrote:
> > > > I think expanding the number of allocation functions
> > > > is not necessary.
> > > 
> > > I think removing common mispatterns in favor of overflow-protected
> > > allocation functions makes sense.
> > 
> > Function symmetry matters too.
> > 
> > These allocation functions are specific to kvz<foo>
> > and are not symmetric for k<foo>, v<foo>, devm_<foo>
> > <foo>_node, and the like.
> 
> If somebody wants them, then we can add them.

Yeah, but I don't think any of it is necessary.

How many of these struct+bufsize * count entries
actually exist?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
