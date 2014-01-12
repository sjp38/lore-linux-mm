Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qe0-f48.google.com (mail-qe0-f48.google.com [209.85.128.48])
	by kanga.kvack.org (Postfix) with ESMTP id DFFA36B0031
	for <linux-mm@kvack.org>; Sat, 11 Jan 2014 19:58:05 -0500 (EST)
Received: by mail-qe0-f48.google.com with SMTP id k5so4732147qej.35
        for <linux-mm@kvack.org>; Sat, 11 Jan 2014 16:58:05 -0800 (PST)
Received: from qmta12.emeryville.ca.mail.comcast.net (qmta12.emeryville.ca.mail.comcast.net. [2001:558:fe2d:44:76:96:27:227])
        by mx.google.com with ESMTP id ko6si16675160qeb.9.2014.01.11.16.58.04
        for <linux-mm@kvack.org>;
        Sat, 11 Jan 2014 16:58:04 -0800 (PST)
Date: Sat, 11 Jan 2014 18:55:39 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 0/9] re-shrink 'struct page' when SLUB is on.
In-Reply-To: <CAOJsxLE-oMpV2G-gxrhyv0Au1tPd87Ow57VD5CWFo41wF8F4Yw@mail.gmail.com>
Message-ID: <alpine.DEB.2.10.1401111854580.6036@nuc>
References: <20140103180147.6566F7C1@viggo.jf.intel.com> <20140103141816.20ef2a24c8adffae040e53dc@linux-foundation.org> <20140106043237.GE696@lge.com> <52D05D90.3060809@sr71.net> <20140110153913.844e84755256afd271371493@linux-foundation.org> <52D0854F.5060102@sr71.net>
 <CAOJsxLE-oMpV2G-gxrhyv0Au1tPd87Ow57VD5CWFo41wF8F4Yw@mail.gmail.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Dave Hansen <dave@sr71.net>, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Sat, 11 Jan 2014, Pekka Enberg wrote:

> On Sat, Jan 11, 2014 at 1:42 AM, Dave Hansen <dave@sr71.net> wrote:
> > On 01/10/2014 03:39 PM, Andrew Morton wrote:
> >>> I tested 4 cases, all of these on the "cache-cold kfree()" case.  The
> >>> first 3 are with vanilla upstream kernel source.  The 4th is patched
> >>> with my new slub code (all single-threaded):
> >>>
> >>>      http://www.sr71.net/~dave/intel/slub/slub-perf-20140109.png
> >>
> >> So we're converging on the most complex option.  argh.
> >
> > Yeah, looks that way.
>
> Seems like a reasonable compromise between memory usage and allocation speed.
>
> Christoph?

Fundamentally I think this is good. I need to look at the details but I am
only going to be able to do that next week when I am back in the office.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
