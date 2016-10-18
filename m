Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 94274280251
	for <linux-mm@kvack.org>; Tue, 18 Oct 2016 06:38:39 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id i187so8553750lfe.4
        for <linux-mm@kvack.org>; Tue, 18 Oct 2016 03:38:39 -0700 (PDT)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id vg1si13144310wjb.19.2016.10.18.03.38.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Oct 2016 03:38:38 -0700 (PDT)
Date: Tue, 18 Oct 2016 12:38:37 +0200
From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH 2/6] mm: mark all calls into the vmalloc subsystem as
	potentially sleeping
Message-ID: <20161018103837.GA8945@lst.de>
References: <1476773771-11470-1-git-send-email-hch@lst.de> <1476773771-11470-3-git-send-email-hch@lst.de> <20161018103359.GM29072@nuc-i3427.alporthouse.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161018103359.GM29072@nuc-i3427.alporthouse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chris Wilson <chris@chris-wilson.co.uk>
Cc: Christoph Hellwig <hch@lst.de>, akpm@linux-foundation.org, joelaf@google.com, jszhang@marvell.com, joaodias@google.com, linux-mm@kvack.org, linux-rt-users@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue, Oct 18, 2016 at 11:33:59AM +0100, Chris Wilson wrote:
> On Tue, Oct 18, 2016 at 08:56:07AM +0200, Christoph Hellwig wrote:
> > This is how everyone seems to already use them, but let's make that
> > explicit.
> 
> mm/page_alloc.c: alloc_large_system_hash() is perhaps the exception to
> the rule.

While alloc_large_system_hash passes GFP_ATOMIC it still is called
from context where it can sleep - I think it just abuses GFP_ATOMIC
so that it gets an "early" failure.  For which GFP_ATOMIC isn't
exactly a good choice as it dips into additional reserves, GFP_NOWAIT
would have probably been a better choice.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
