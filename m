Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id B748A6B038A
	for <linux-mm@kvack.org>; Sat, 18 Mar 2017 12:37:39 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id n11so12144171pfg.7
        for <linux-mm@kvack.org>; Sat, 18 Mar 2017 09:37:39 -0700 (PDT)
Received: from helcar.apana.org.au (helcar.hengli.com.au. [209.40.204.226])
        by mx.google.com with ESMTPS id z7si8564669pff.69.2017.03.18.09.37.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 18 Mar 2017 09:37:38 -0700 (PDT)
Date: Sun, 19 Mar 2017 00:37:02 +0800
From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 0/5] mm subsystem refcounter conversions
Message-ID: <20170318163702.GA23796@gondor.apana.org.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170228172156.de13fdc41a3ca6a4deea7750@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: elena.reshetova@intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, peterz@infradead.org, gregkh@linuxfoundation.org, viro@zeniv.linux.org.uk, catalin.marinas@arm.com, mingo@redhat.com, arnd@arndb.de, luto@kernel.org, "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org

Andrew Morton <akpm@linux-foundation.org> wrote:
>
> The performance implications of this proposal are terrifying.
> 
> I suggest adding a set of non-debug inlined refcount functions which
> just fall back to the simple atomic.h operations.
> 
> And add a new CONFIG_DEBUG_REFCOUNT.  So the performance (and code
> size!) with CONFIG_DEBUG_REFCOUNT=n is unaltered from present code. 
> And make CONFIG_DEBUG_REFCOUNT suitably difficult to set.

I agree.  Refcounts are used in many performance-critical sites
within the network subsystem.

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
