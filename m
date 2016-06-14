Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 052AC6B007E
	for <linux-mm@kvack.org>; Tue, 14 Jun 2016 09:10:54 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id l5so267346899ioa.0
        for <linux-mm@kvack.org>; Tue, 14 Jun 2016 06:10:54 -0700 (PDT)
Received: from mail-it0-x241.google.com (mail-it0-x241.google.com. [2607:f8b0:4001:c0b::241])
        by mx.google.com with ESMTPS id a197si4836983ita.65.2016.06.14.06.10.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 Jun 2016 06:10:52 -0700 (PDT)
Received: by mail-it0-x241.google.com with SMTP id i6so11122632ith.0
        for <linux-mm@kvack.org>; Tue, 14 Jun 2016 06:10:52 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAMuHMdXC=zEjbZADE5wELjOq_kBiFNewpdUrMCe8d3Utu98h8A@mail.gmail.com>
References: <CAMuHMdXC=zEjbZADE5wELjOq_kBiFNewpdUrMCe8d3Utu98h8A@mail.gmail.com>
From: Geert Uytterhoeven <geert@linux-m68k.org>
Date: Tue, 14 Jun 2016 15:10:52 +0200
Message-ID: <CAMuHMdXEjxWY=0Vuu=aHupexVg1hERPnUromk-2sCjwbDn8H1w@mail.gmail.com>
Subject: Re: Boot failure on emev2/kzm9d (was: Re: [PATCH v2 11/11] mm/slab:
 lockless decision to grow cache)
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Linux MM <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-renesas-soc@vger.kernel.org, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>

Hi Jonsoo,

On Mon, Jun 13, 2016 at 9:43 PM, Geert Uytterhoeven
<geert@linux-m68k.org> wrote:
> On Tue, Apr 12, 2016 at 6:51 AM,  <js1304@gmail.com> wrote:
>> From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
>> To check whther free objects exist or not precisely, we need to grab a
>> lock.  But, accuracy isn't that important because race window would be
>> even small and if there is too much free object, cache reaper would reap
>> it.  So, this patch makes the check for free object exisistence not to
>> hold a lock.  This will reduce lock contention in heavily allocation case.

>> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
>
> I've bisected a boot failure (no output at all) in v4.7-rc2 on emev2/kzm9d
> (Renesas dual Cortex A9) to this patch, which is upstream commit
> 801faf0db8947e01877920e848a4d338dd7a99e7.

BTW, when disabling SMP, the problem goes away.

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
