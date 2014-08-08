Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f52.google.com (mail-qg0-f52.google.com [209.85.192.52])
	by kanga.kvack.org (Postfix) with ESMTP id F37F46B0035
	for <linux-mm@kvack.org>; Fri,  8 Aug 2014 10:11:22 -0400 (EDT)
Received: by mail-qg0-f52.google.com with SMTP id f51so6136506qge.11
        for <linux-mm@kvack.org>; Fri, 08 Aug 2014 07:11:22 -0700 (PDT)
Received: from qmta09.emeryville.ca.mail.comcast.net (qmta09.emeryville.ca.mail.comcast.net. [2001:558:fe2d:43:76:96:30:96])
        by mx.google.com with ESMTP id l9si10331745qac.103.2014.08.08.07.11.20
        for <linux-mm@kvack.org>;
        Fri, 08 Aug 2014 07:11:21 -0700 (PDT)
Date: Fri, 8 Aug 2014 09:11:12 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: BUG: enable_cpucache failed for radix_tree_node, error 12 (was:
 Re: [PATCH v3 9/9] slab: remove BAD_ALIEN_MAGIC)
In-Reply-To: <CAMuHMdWNNuPgDsjM1eM0uo2090-6OxAX8Kfw8Pcd2zo5G6zPkw@mail.gmail.com>
Message-ID: <alpine.DEB.2.11.1408080909480.16459@gentwo.org>
References: <CAMuHMdW2kb=EF-Nmem_gyUu=p7hFOTe+Q2ekHh41SaHHiWDGeg@mail.gmail.com> <CAAmzW4MX2birtCOUxjDdQ7c3Y+RyVkBt383HEQ=XFgnhhOsQPw@mail.gmail.com> <CAMuHMdVC8aYwDEHnntshdVA24Nx3qAUXZfeRQNGqj=J6eExU-Q@mail.gmail.com> <CAAmzW4NWnMeO+Z3CQ=9Z7rUFLaPmR-w0iMhxzjO+PVgVu7OMuQ@mail.gmail.com>
 <20140808071903.GD6150@js1304-P5Q-DELUXE> <CAMuHMdVHmmct=BC=WXFJWeizYp+S706WjvNi=powYsJkarKUhw@mail.gmail.com> <alpine.DEB.2.11.1408080649430.14841@gentwo.org> <CAMuHMdWNNuPgDsjM1eM0uo2090-6OxAX8Kfw8Pcd2zo5G6zPkw@mail.gmail.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Geert Uytterhoeven <geert@linux-m68k.org>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Linux MM <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Vladimir Davydov <vdavydov@parallels.com>

On Fri, 8 Aug 2014, Geert Uytterhoeven wrote:

> > Ok this is broken on m68k. CONFIG_NUMA is required for this to work. If
> > the arch code does this despite !CONFIG_NUMA then lots of things should
> > break.
>
> Can you please elaborate? We've been using for years...

!CONFIG_NUMA leads to the assumption of a system with a single node in
numerous places.

F.e. in include/linux/mm.h:


static inline int zone_to_nid(struct zone *zone)
{
#ifdef CONFIG_NUMA
        return zone->node;
#else
        return 0;
#endif
}


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
