Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id D3A646B0334
	for <linux-mm@kvack.org>; Fri,  8 Sep 2017 03:55:21 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id a2so3706548pfj.2
        for <linux-mm@kvack.org>; Fri, 08 Sep 2017 00:55:21 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id f3si1213063pld.65.2017.09.08.00.55.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Sep 2017 00:55:20 -0700 (PDT)
Date: Fri, 8 Sep 2017 00:55:19 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH v6 10/11] mm: add a user_virt_to_phys symbol
Message-ID: <20170908075519.GD4957@infradead.org>
References: <20170907173609.22696-1-tycho@docker.com>
 <20170907173609.22696-11-tycho@docker.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170907173609.22696-11-tycho@docker.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tycho Andersen <tycho@docker.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com, Marco Benatto <marco.antonio.780@gmail.com>, Juerg Haefliger <juerg.haefliger@canonical.com>, linux-arm-kernel@lists.infradead.org, x86@kernel.org

On Thu, Sep 07, 2017 at 11:36:08AM -0600, Tycho Andersen wrote:
> We need someting like this for testing XPFO. Since it's architecture
> specific, putting it in the test code is slightly awkward, so let's make it
> an arch-specific symbol and export it for use in LKDTM.

We really should not add an export for this.

I think you'll want to just open code it in your test module.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
