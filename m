Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 73E5F6B0033
	for <linux-mm@kvack.org>; Wed, 29 Nov 2017 01:38:44 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id z12so1542918pgv.6
        for <linux-mm@kvack.org>; Tue, 28 Nov 2017 22:38:44 -0800 (PST)
Received: from ringil.hmeau.com ([128.1.224.119])
        by mx.google.com with ESMTPS id ay8si764763plb.436.2017.11.28.22.38.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Tue, 28 Nov 2017 22:38:43 -0800 (PST)
Date: Wed, 29 Nov 2017 17:38:16 +1100
From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [5/8] crypto: remove unused hardirq.h
Message-ID: <20171129063816.GD21594@gondor.apana.org.au>
References: <1510959741-31109-5-git-send-email-yang.s@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1510959741-31109-5-git-send-email-yang.s@alibaba-inc.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <yang.s@alibaba-inc.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-crypto@vger.kernel.org, netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>

On Sat, Nov 18, 2017 at 07:02:18AM +0800, Yang Shi wrote:
> Preempt counter APIs have been split out, currently, hardirq.h just
> includes irq_enter/exit APIs which are not used by crypto at all.
> 
> So, remove the unused hardirq.h.
> 
> Signed-off-by: Yang Shi <yang.s@alibaba-inc.com>
> Cc: Herbert Xu <herbert@gondor.apana.org.au>
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: linux-crypto@vger.kernel.org

Patch applied.  Thanks.
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
