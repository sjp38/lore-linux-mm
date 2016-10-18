Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id A1D48280251
	for <linux-mm@kvack.org>; Tue, 18 Oct 2016 06:34:08 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id b81so8508453lfe.1
        for <linux-mm@kvack.org>; Tue, 18 Oct 2016 03:34:08 -0700 (PDT)
Received: from fireflyinternet.com (mail.fireflyinternet.com. [109.228.58.192])
        by mx.google.com with ESMTPS id o85si22081822lfg.139.2016.10.18.03.34.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Oct 2016 03:34:07 -0700 (PDT)
Date: Tue, 18 Oct 2016 11:33:59 +0100
From: Chris Wilson <chris@chris-wilson.co.uk>
Subject: Re: [PATCH 2/6] mm: mark all calls into the vmalloc subsystem as
 potentially sleeping
Message-ID: <20161018103359.GM29072@nuc-i3427.alporthouse.com>
References: <1476773771-11470-1-git-send-email-hch@lst.de>
 <1476773771-11470-3-git-send-email-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1476773771-11470-3-git-send-email-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: akpm@linux-foundation.org, joelaf@google.com, jszhang@marvell.com, joaodias@google.com, linux-mm@kvack.org, linux-rt-users@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue, Oct 18, 2016 at 08:56:07AM +0200, Christoph Hellwig wrote:
> This is how everyone seems to already use them, but let's make that
> explicit.

mm/page_alloc.c: alloc_large_system_hash() is perhaps the exception to
the rule.
-Chris

-- 
Chris Wilson, Intel Open Source Technology Centre

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
