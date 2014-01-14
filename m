Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qe0-f42.google.com (mail-qe0-f42.google.com [209.85.128.42])
	by kanga.kvack.org (Postfix) with ESMTP id D6EDA6B0031
	for <linux-mm@kvack.org>; Tue, 14 Jan 2014 17:06:38 -0500 (EST)
Received: by mail-qe0-f42.google.com with SMTP id b4so284041qen.29
        for <linux-mm@kvack.org>; Tue, 14 Jan 2014 14:06:38 -0800 (PST)
Received: from blackbird.sr71.net ([2001:19d0:2:6:209:6bff:fe9a:902])
        by mx.google.com with ESMTP id o8si2326181qey.119.2014.01.14.14.06.32
        for <linux-mm@kvack.org>;
        Tue, 14 Jan 2014 14:06:33 -0800 (PST)
Message-ID: <52D5B48D.30006@sr71.net>
Date: Tue, 14 Jan 2014 14:05:01 -0800
From: Dave Hansen <dave@sr71.net>
MIME-Version: 1.0
Subject: Re: [PATCH 0/9] re-shrink 'struct page' when SLUB is on.
References: <20140103180147.6566F7C1@viggo.jf.intel.com> <20140103141816.20ef2a24c8adffae040e53dc@linux-foundation.org> <20140106043237.GE696@lge.com> <52D05D90.3060809@sr71.net> <20140110153913.844e84755256afd271371493@linux-foundation.org> <52D0854F.5060102@sr71.net> <CAOJsxLE-oMpV2G-gxrhyv0Au1tPd87Ow57VD5CWFo41wF8F4Yw@mail.gmail.com> <alpine.DEB.2.10.1401111854580.6036@nuc> <20140113014408.GA25900@lge.com> <52D41F52.5020805@sr71.net> <alpine.DEB.2.10.1401141404190.19618@nuc>
In-Reply-To: <alpine.DEB.2.10.1401141404190.19618@nuc>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Pekka Enberg <penberg@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 01/14/2014 12:07 PM, Christoph Lameter wrote:
> One easy way to shrink struct page is to simply remove the feature. The
> patchset looked a bit complicated and does many other things.

Sure.  There's a clear path if you only care about 'struct page' size,
or if you only care about making the slub fast path as fast as possible.
 We've got three variables, though:

1. slub fast path speed
2. space overhead from 'struct page'
3. code complexity.

Arranged in three basic choices:

1. Big 'struct page', fast, medium complexity code
2. Small 'struct page', slow, lowest complexity
3. Small 'struct page', fast, highest complexity, risk of new code

The question is what we should do by _default_, and what we should be
recommending for our customers via the distros.  Are you saying that you
think we should completely rule out even having option 1 in mainline?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
