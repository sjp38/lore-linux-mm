Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id B01C96B0267
	for <linux-mm@kvack.org>; Wed, 23 Nov 2016 03:39:51 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id g23so3911863wme.4
        for <linux-mm@kvack.org>; Wed, 23 Nov 2016 00:39:51 -0800 (PST)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id t14si1351572wme.122.2016.11.23.00.39.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 Nov 2016 00:39:50 -0800 (PST)
Date: Wed, 23 Nov 2016 09:39:49 +0100
From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH 07/10] mm: warn about vfree from atomic context
Message-ID: <20161123083949.GD16966@lst.de>
References: <1479474236-4139-1-git-send-email-hch@lst.de> <1479474236-4139-8-git-send-email-hch@lst.de> <996e56cb-137f-cd3e-eb69-e9ef03ad75c4@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <996e56cb-137f-cd3e-eb69-e9ef03ad75c4@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Christoph Hellwig <hch@lst.de>, akpm@linux-foundation.org, joelaf@google.com, jszhang@marvell.com, chris@chris-wilson.co.uk, joaodias@google.com, linux-mm@kvack.org, linux-rt-users@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org

On Tue, Nov 22, 2016 at 07:35:34PM +0300, Andrey Ryabinin wrote:
> This one is wrong. We still can call vfree() from interrupt context.
> So WARN_ON_ONCE(in_atomic() && !in_interrupt()) would be correct,
> but also redundant. DEBUG_ATOMIC_SLEEP=y should catch illegal vfree() calls.
> Let's just drop this patch, ok?

Ok, fine.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
