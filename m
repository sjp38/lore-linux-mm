Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f170.google.com (mail-lb0-f170.google.com [209.85.217.170])
	by kanga.kvack.org (Postfix) with ESMTP id 234C46B0035
	for <linux-mm@kvack.org>; Fri,  8 Aug 2014 11:08:40 -0400 (EDT)
Received: by mail-lb0-f170.google.com with SMTP id l4so2026829lbv.15
        for <linux-mm@kvack.org>; Fri, 08 Aug 2014 08:08:39 -0700 (PDT)
Received: from mail-lb0-x234.google.com (mail-lb0-x234.google.com [2a00:1450:4010:c04::234])
        by mx.google.com with ESMTPS id yu7si3822316lbb.40.2014.08.08.08.08.37
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 08 Aug 2014 08:08:38 -0700 (PDT)
Received: by mail-lb0-f180.google.com with SMTP id v6so3884479lbi.39
        for <linux-mm@kvack.org>; Fri, 08 Aug 2014 08:08:37 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.11.1408080943280.16459@gentwo.org>
References: <1407481239-7572-1-git-send-email-iamjoonsoo.kim@lge.com>
	<alpine.DEB.2.11.1408080943280.16459@gentwo.org>
Date: Fri, 8 Aug 2014 17:08:37 +0200
Message-ID: <CAMuHMdVZdaVeYY=A=eVEC67GGyQNq2XZ8wN3fk0+ywtkoa6EmA@mail.gmail.com>
Subject: Re: [PATCH for v3.17-rc1] Revert "slab: remove BAD_ALIEN_MAGIC"
From: Geert Uytterhoeven <geert@linux-m68k.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Linux MM <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Vladimir Davydov <vdavydov@parallels.com>

On Fri, Aug 8, 2014 at 4:44 PM, Christoph Lameter <cl@linux.com> wrote:
> On Fri, 8 Aug 2014, Joonsoo Kim wrote:
>
>> This reverts commit a640616822b2 ("slab: remove BAD_ALIEN_MAGIC").
>
> Lets hold off on this one. I am bit confused as to why a non NUMA system
> would have multiple NUMA nodes.

DISCONTIGMEM

mm/Kconfig:

#
# Both the NUMA code and DISCONTIGMEM use arrays of pg_data_t's
# to represent different areas of memory.  This variable allows
# those dependencies to exist individually.
#
config NEED_MULTIPLE_NODES
        def_bool y
        depends on DISCONTIGMEM || NUMA

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
