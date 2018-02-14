Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id E734D6B0005
	for <linux-mm@kvack.org>; Wed, 14 Feb 2018 14:32:49 -0500 (EST)
Received: by mail-io0-f198.google.com with SMTP id m70so7365478ioi.8
        for <linux-mm@kvack.org>; Wed, 14 Feb 2018 11:32:49 -0800 (PST)
Received: from smtprelay.hostedemail.com (smtprelay0103.hostedemail.com. [216.40.44.103])
        by mx.google.com with ESMTPS id v2si3178790iod.72.2018.02.14.11.32.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Feb 2018 11:32:49 -0800 (PST)
Message-ID: <1518636765.3678.19.camel@perches.com>
Subject: Re: [PATCH 0/2] Add kvzalloc_struct to complement kvzalloc_array
From: Joe Perches <joe@perches.com>
Date: Wed, 14 Feb 2018 11:32:45 -0800
In-Reply-To: <CAGXu5jJdAJt3HK7FgaCyPRbXeFV-hJOrPodNnOkx=kCvSieK3w@mail.gmail.com>
References: <20180214182618.14627-1-willy@infradead.org>
	 <1518634058.3678.15.camel@perches.com>
	 <CAGXu5jJdAJt3HK7FgaCyPRbXeFV-hJOrPodNnOkx=kCvSieK3w@mail.gmail.com>
Content-Type: text/plain; charset="ISO-8859-1"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: Matthew Wilcox <willy@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <mawilcox@microsoft.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Kernel Hardening <kernel-hardening@lists.openwall.com>

On Wed, 2018-02-14 at 11:23 -0800, Kees Cook wrote:
> On Wed, Feb 14, 2018 at 10:47 AM, Joe Perches <joe@perches.com> wrote:
> > On Wed, 2018-02-14 at 10:26 -0800, Matthew Wilcox wrote:
> > > From: Matthew Wilcox <mawilcox@microsoft.com>
> > > 
> > > We all know the perils of multiplying a value provided from userspace
> > > by a constant and then allocating the resulting number of bytes.  That's
> > > why we have kvmalloc_array(), so we don't have to think about it.
> > > This solves the same problem when we embed one of these arrays in a
> > > struct like this:
> > > 
> > > struct {
> > >       int n;
> > >       unsigned long array[];
> > > };
> > 
> > I think expanding the number of allocation functions
> > is not necessary.
> 
> I think removing common mispatterns in favor of overflow-protected
> allocation functions makes sense.

Function symmetry matters too.

These allocation functions are specific to kvz<foo>
and are not symmetric for k<foo>, v<foo>, devm_<foo>
<foo>_node, and the like.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
