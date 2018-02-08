Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id C6A7E6B0007
	for <linux-mm@kvack.org>; Thu,  8 Feb 2018 14:48:53 -0500 (EST)
Received: by mail-qk0-f197.google.com with SMTP id v198so4526413qkb.17
        for <linux-mm@kvack.org>; Thu, 08 Feb 2018 11:48:53 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id o74sor556067qkl.111.2018.02.08.11.48.52
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 08 Feb 2018 11:48:52 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20180208194235.GA3424@bombadil.infradead.org>
References: <20180208021112.GB14918@bombadil.infradead.org>
 <CAG48ez2-MTJ2YrS5fPZi19RY6P_6NWuK1U5CcQpJ25=xrGSy_A@mail.gmail.com>
 <CA+DvKQLHDR0s=6r4uiHL8kw2_PnfJcwYfPxgQOmuLbc=5k39+g@mail.gmail.com>
 <20180208185648.GB9524@bombadil.infradead.org> <CA+DvKQLHcFc3+kW_SnD6hs53yyD5Zi+uAeSgDMm1tRzxqy-Opg@mail.gmail.com>
 <20180208194235.GA3424@bombadil.infradead.org>
From: Daniel Micay <danielmicay@gmail.com>
Date: Thu, 8 Feb 2018 14:48:52 -0500
Message-ID: <CA+DvKQKba0iU+tydbmGkAJsxCxazORDnuoe32sy-2nggyagUxQ@mail.gmail.com>
Subject: Re: [RFC] Warn the user when they could overflow mapcount
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Jann Horn <jannh@google.com>, linux-mm@kvack.org, Kernel Hardening <kernel-hardening@lists.openwall.com>, kernel list <linux-kernel@vger.kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

I guess it could saturate and then switch to tracking the count via an
object pointer -> count mapping with a global lock? Whatever the
solution is should probably be a generic one since it's a recurring
issue.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
