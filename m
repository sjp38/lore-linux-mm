Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qe0-f48.google.com (mail-qe0-f48.google.com [209.85.128.48])
	by kanga.kvack.org (Postfix) with ESMTP id F3C4B6B003B
	for <linux-mm@kvack.org>; Thu, 16 Jan 2014 11:44:29 -0500 (EST)
Received: by mail-qe0-f48.google.com with SMTP id ne12so900598qeb.21
        for <linux-mm@kvack.org>; Thu, 16 Jan 2014 08:44:29 -0800 (PST)
Received: from qmta13.emeryville.ca.mail.comcast.net (qmta13.emeryville.ca.mail.comcast.net. [2001:558:fe2d:44:76:96:27:243])
        by mx.google.com with ESMTP id t5si10363257qak.16.2014.01.16.08.44.27
        for <linux-mm@kvack.org>;
        Thu, 16 Jan 2014 08:44:29 -0800 (PST)
Date: Thu, 16 Jan 2014 10:44:24 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 0/9] re-shrink 'struct page' when SLUB is on.
In-Reply-To: <52D5B48D.30006@sr71.net>
Message-ID: <alpine.DEB.2.10.1401161041160.29778@nuc>
References: <20140103180147.6566F7C1@viggo.jf.intel.com> <20140103141816.20ef2a24c8adffae040e53dc@linux-foundation.org> <20140106043237.GE696@lge.com> <52D05D90.3060809@sr71.net> <20140110153913.844e84755256afd271371493@linux-foundation.org> <52D0854F.5060102@sr71.net>
 <CAOJsxLE-oMpV2G-gxrhyv0Au1tPd87Ow57VD5CWFo41wF8F4Yw@mail.gmail.com> <alpine.DEB.2.10.1401111854580.6036@nuc> <20140113014408.GA25900@lge.com> <52D41F52.5020805@sr71.net> <alpine.DEB.2.10.1401141404190.19618@nuc> <52D5B48D.30006@sr71.net>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Pekka Enberg <penberg@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, 14 Jan 2014, Dave Hansen wrote:

> On 01/14/2014 12:07 PM, Christoph Lameter wrote:
> > One easy way to shrink struct page is to simply remove the feature. The
> > patchset looked a bit complicated and does many other things.
>
> Sure.  There's a clear path if you only care about 'struct page' size,
> or if you only care about making the slub fast path as fast as possible.
>  We've got three variables, though:
>
> 1. slub fast path speed

The fast path does use this_cpu_cmpxchg_double which is something
different from a cmpxchg_double and its not used on struct page.

> Arranged in three basic choices:
>
> 1. Big 'struct page', fast, medium complexity code
> 2. Small 'struct page', slow, lowest complexity

The numbers that I see seem to indicate that a big struct page means slow.

> The question is what we should do by _default_, and what we should be
> recommending for our customers via the distros.  Are you saying that you
> think we should completely rule out even having option 1 in mainline?

If option 1 is slower than option 2 then we do not need it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
