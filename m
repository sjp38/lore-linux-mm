Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id CC7C0828E2
	for <linux-mm@kvack.org>; Wed, 22 Jun 2016 09:28:53 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id s63so103716761ioi.1
        for <linux-mm@kvack.org>; Wed, 22 Jun 2016 06:28:53 -0700 (PDT)
Received: from resqmta-po-10v.sys.comcast.net (resqmta-po-10v.sys.comcast.net. [2001:558:fe16:19:96:114:154:169])
        by mx.google.com with ESMTPS id r83si577437iod.111.2016.06.22.06.28.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Jun 2016 06:28:53 -0700 (PDT)
Date: Wed, 22 Jun 2016 08:28:50 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] mm: slab.h: use ilog2() in kmalloc_index()
In-Reply-To: <20160622005135.GA342@yury-N73SV>
Message-ID: <alpine.DEB.2.20.1606220826430.4529@east.gentwo.org>
References: <1466465586-22096-1-git-send-email-yury.norov@gmail.com> <20160621145237.dae264ea5fe6b3b7f2d2d4e6@linux-foundation.org> <20160622005135.GA342@yury-N73SV>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yury Norov <ynorov@caviumnetworks.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Yury Norov <yury.norov@gmail.com>, masmart@yandex.ru, linux-mm@kvack.org, linux-kernel@vger.kernel.org, enberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, linux@rasmusvillemoes.dk, Alexey Klimov <klimov.linux@gmail.com>

On Wed, 22 Jun 2016, Yury Norov wrote:

>
> There will be no fls() for constant at runtime because ilog2() calculates
> constant values at compile-time as well. From this point of view,
> this patch removes code duplication, as we already have compile-time
> log() calculation in kernel, and should re-use it whenever possible.\

The reason not to use ilog there was that the constant folding did not
work correctly with one or the other architectures/compilers. If you want
to do this then please verify that all arches reliably do produce a
constant there.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
