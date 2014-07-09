Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f181.google.com (mail-vc0-f181.google.com [209.85.220.181])
	by kanga.kvack.org (Postfix) with ESMTP id 1F05982965
	for <linux-mm@kvack.org>; Wed,  9 Jul 2014 18:46:58 -0400 (EDT)
Received: by mail-vc0-f181.google.com with SMTP id il7so8846871vcb.40
        for <linux-mm@kvack.org>; Wed, 09 Jul 2014 15:46:57 -0700 (PDT)
Received: from mail-vc0-f171.google.com (mail-vc0-f171.google.com [209.85.220.171])
        by mx.google.com with ESMTPS id dc7si8728806vec.33.2014.07.09.15.46.56
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 09 Jul 2014 15:46:57 -0700 (PDT)
Received: by mail-vc0-f171.google.com with SMTP id id10so8875890vcb.2
        for <linux-mm@kvack.org>; Wed, 09 Jul 2014 15:46:56 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1404324218-4743-4-git-send-email-lauraa@codeaurora.org>
References: <1404324218-4743-1-git-send-email-lauraa@codeaurora.org>
	<1404324218-4743-4-git-send-email-lauraa@codeaurora.org>
Date: Wed, 9 Jul 2014 15:46:56 -0700
Message-ID: <CAOesGMimCAYnqxkKoYpZ2ws7x9eH4K1Yw3LnLz9HC6MWyHEo3A@mail.gmail.com>
Subject: Re: [PATCHv4 3/5] common: dma-mapping: Introduce common remapping functions
From: Olof Johansson <olof@lixom.net>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <lauraa@codeaurora.org>
Cc: Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, David Riley <davidriley@chromium.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Ritesh Harjain <ritesh.harjani@gmail.com>, linux-mm <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Wed, Jul 2, 2014 at 11:03 AM, Laura Abbott <lauraa@codeaurora.org> wrote:
>
> For architectures without coherent DMA, memory for DMA may
> need to be remapped with coherent attributes. Factor out
> the the remapping code from arm and put it in a
> common location to reduced code duplication.
>
> Signed-off-by: Laura Abbott <lauraa@codeaurora.org>

Hm. The switch from ioremap to map_vm_area() here seems to imply that
lib/ioremap can/should be reworked to use just wrap the vmalloc
functions too?

Unrelated to this change.

I did a pass of review here. Nothing stands out as wrong but I don't
claim to know this area well these days.

What's the merge/ack plan here? It might reduce the complexity of
merging to add the common functions in your series, then move the ARM
code over separately?


-Olof

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
