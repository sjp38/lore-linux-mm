Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f171.google.com (mail-io0-f171.google.com [209.85.223.171])
	by kanga.kvack.org (Postfix) with ESMTP id A799C6B007E
	for <linux-mm@kvack.org>; Mon, 28 Mar 2016 04:58:39 -0400 (EDT)
Received: by mail-io0-f171.google.com with SMTP id 124so168890865iov.3
        for <linux-mm@kvack.org>; Mon, 28 Mar 2016 01:58:39 -0700 (PDT)
Received: from mail-ig0-x241.google.com (mail-ig0-x241.google.com. [2607:f8b0:4001:c05::241])
        by mx.google.com with ESMTPS id sa10si6895046igb.8.2016.03.28.01.58.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Mar 2016 01:58:38 -0700 (PDT)
Received: by mail-ig0-x241.google.com with SMTP id ww10so8865330igb.2
        for <linux-mm@kvack.org>; Mon, 28 Mar 2016 01:58:38 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1459142821-20303-3-git-send-email-iamjoonsoo.kim@lge.com>
References: <1459142821-20303-1-git-send-email-iamjoonsoo.kim@lge.com>
	<1459142821-20303-3-git-send-email-iamjoonsoo.kim@lge.com>
Date: Mon, 28 Mar 2016 10:58:38 +0200
Message-ID: <CAMuHMdU7WzkTccN_wa_LB+qx=1f_4V0SSRF+XqNdgYvCb2o5Ng@mail.gmail.com>
Subject: Re: [PATCH 02/11] mm/slab: remove BAD_ALIEN_MAGIC again
From: Geert Uytterhoeven <geert@linux-m68k.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: JoonSoo Kim <js1304@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Linux MM <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

Hi Jonsoo,

On Mon, Mar 28, 2016 at 7:26 AM,  <js1304@gmail.com> wrote:
> From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
>
> Initial attemp to remove BAD_ALIEN_MAGIC is once reverted by
> 'commit edcad2509550 ("Revert "slab: remove BAD_ALIEN_MAGIC"")'
> because it causes a problem on m68k which has many node
> but !CONFIG_NUMA. In this case, although alien cache isn't used
> at all but to cope with some initialization path, garbage value
> is used and that is BAD_ALIEN_MAGIC. Now, this patch set
> use_alien_caches to 0 when !CONFIG_NUMA, there is no initialization
> path problem so we don't need BAD_ALIEN_MAGIC at all. So remove it.
>
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

I gave this a try on m68k/ARAnyM, and it didn't crash, unlike the previous
version that was reverted, so
Tested-by: Geert Uytterhoeven <geert@linux-m68k.org>

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
