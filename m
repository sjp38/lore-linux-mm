Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id 397B86B0038
	for <linux-mm@kvack.org>; Mon, 13 Jan 2014 12:17:36 -0500 (EST)
Received: by mail-pd0-f170.google.com with SMTP id z10so2301451pdj.15
        for <linux-mm@kvack.org>; Mon, 13 Jan 2014 09:17:35 -0800 (PST)
Received: from blackbird.sr71.net (www.sr71.net. [198.145.64.142])
        by mx.google.com with ESMTP id dv5si16242648pbb.253.2014.01.13.09.17.33
        for <linux-mm@kvack.org>;
        Mon, 13 Jan 2014 09:17:33 -0800 (PST)
Message-ID: <52D41F52.5020805@sr71.net>
Date: Mon, 13 Jan 2014 09:16:02 -0800
From: Dave Hansen <dave@sr71.net>
MIME-Version: 1.0
Subject: Re: [PATCH 0/9] re-shrink 'struct page' when SLUB is on.
References: <20140103180147.6566F7C1@viggo.jf.intel.com> <20140103141816.20ef2a24c8adffae040e53dc@linux-foundation.org> <20140106043237.GE696@lge.com> <52D05D90.3060809@sr71.net> <20140110153913.844e84755256afd271371493@linux-foundation.org> <52D0854F.5060102@sr71.net> <CAOJsxLE-oMpV2G-gxrhyv0Au1tPd87Ow57VD5CWFo41wF8F4Yw@mail.gmail.com> <alpine.DEB.2.10.1401111854580.6036@nuc> <20140113014408.GA25900@lge.com>
In-Reply-To: <20140113014408.GA25900@lge.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 01/12/2014 05:44 PM, Joonsoo Kim wrote:
> We only touch one struct page on small allocation.
> In 64-byte case, we always use one cacheline for touching struct page, since
> it is aligned to cacheline size. However, in 56-byte case, we possibly use
> two cachelines because struct page isn't aligned to cacheline size.

I think you're completely correct that this can _happen_, but I'm a bit
unconvinced that what you're talking about is the thing which dominates
the results.  I'm sure it plays a role, but the tests I was doing were
doing tens of millions of allocations and touching a _lot_ of 'struct
pages'.  I would not expect these effects to be observable across such a
large sample of pages.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
