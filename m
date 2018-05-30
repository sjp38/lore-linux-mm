Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id B2A586B0271
	for <linux-mm@kvack.org>; Wed, 30 May 2018 08:01:35 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id bd7-v6so11228384plb.20
        for <linux-mm@kvack.org>; Wed, 30 May 2018 05:01:35 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id n12-v6si9244543plp.123.2018.05.30.05.01.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 30 May 2018 05:01:34 -0700 (PDT)
Date: Wed, 30 May 2018 05:01:33 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH] mm: dmapool: Check the dma pool name
Message-ID: <20180530120133.GC17450@bombadil.infradead.org>
References: <59623b15001e5a20ac32b1a393db88722be2e718.1527679621.git.baolin.wang@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <59623b15001e5a20ac32b1a393db88722be2e718.1527679621.git.baolin.wang@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Baolin Wang <baolin.wang@linaro.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, arnd@arndb.de, broonie@kernel.org

On Wed, May 30, 2018 at 07:28:43PM +0800, Baolin Wang wrote:
> It will be crash if we pass one NULL name when creating one dma pool,
> so we should check the passing name when copy it to dma pool.

NAK.  Crashing is the appropriate thing to do.  Fix the caller to not
pass NULL.

If you permit NULL to be passed then you're inviting crashes or just
bad reporting later when pool->name is printed.
