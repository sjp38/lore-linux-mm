Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f182.google.com (mail-ie0-f182.google.com [209.85.223.182])
	by kanga.kvack.org (Postfix) with ESMTP id EF1E86B0031
	for <linux-mm@kvack.org>; Thu,  3 Apr 2014 12:33:18 -0400 (EDT)
Received: by mail-ie0-f182.google.com with SMTP id y20so2119026ier.27
        for <linux-mm@kvack.org>; Thu, 03 Apr 2014 09:33:18 -0700 (PDT)
Received: from qmta05.emeryville.ca.mail.comcast.net (qmta05.emeryville.ca.mail.comcast.net. [2001:558:fe2d:43:76:96:30:48])
        by mx.google.com with ESMTP id r10si6722269icv.131.2014.04.03.09.33.17
        for <linux-mm@kvack.org>;
        Thu, 03 Apr 2014 09:33:18 -0700 (PDT)
Date: Thu, 3 Apr 2014 11:33:15 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH v2] mm: convert some level-less printks to pr_*
In-Reply-To: <1396291441.21529.52.camel@joe-AO722>
Message-ID: <alpine.DEB.2.10.1404031132310.21658@nuc>
References: <1395942859-11611-1-git-send-email-mitchelh@codeaurora.org> <1395942859-11611-2-git-send-email-mitchelh@codeaurora.org> <alpine.DEB.2.10.1403311334060.3313@nuc> <1396291441.21529.52.camel@joe-AO722>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joe Perches <joe@perches.com>
Cc: Mitchel Humpherys <mitchelh@codeaurora.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, 31 Mar 2014, Joe Perches wrote:

> On Mon, 2014-03-31 at 13:35 -0500, Christoph Lameter wrote:
> > On Thu, 27 Mar 2014, Mitchel Humpherys wrote:
> >
> > > diff --git a/mm/slub.c b/mm/slub.c
> []
> > > @@ -9,6 +9,8 @@
> > >   * (C) 2011 Linux Foundation, Christoph Lameter
> > >   */
> > >
> > > +#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
> >
> > This is implicitly used by some macros? If so then please define this
> > elsewhere. I do not see any use in slub.c of this one.
>
> Hi Christoph
>
> All the pr_<level> macros use it.
>
> from include/linux/printk.h:

Ok then why do you add the definition to slub.c?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
