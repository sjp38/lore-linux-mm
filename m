Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1AE586B0005
	for <linux-mm@kvack.org>; Fri, 15 Apr 2016 10:37:32 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id zy2so134529657pac.1
        for <linux-mm@kvack.org>; Fri, 15 Apr 2016 07:37:32 -0700 (PDT)
Received: from helcar.hengli.com.au (helcar.hengli.com.au. [209.40.204.226])
        by mx.google.com with ESMTPS id 21si2755989pfv.71.2016.04.15.07.37.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Fri, 15 Apr 2016 07:37:31 -0700 (PDT)
Date: Fri, 15 Apr 2016 22:37:24 +0800
From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH resend] crypto: get rid of superfluous __GFP_REPEAT
Message-ID: <20160415143724.GI733@gondor.apana.org.au>
References: <1460372892-8157-19-git-send-email-mhocko@kernel.org>
 <1460623902-7109-1-git-send-email-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1460623902-7109-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, "David S. Miller" <davem@davemloft.net>, linux-crypto@vger.kernel.org

On Thu, Apr 14, 2016 at 10:51:42AM +0200, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> __GFP_REPEAT has a rather weak semantic but since it has been introduced
> around 2.6.12 it has been ignored for low order allocations.
> 
> lzo_init uses __GFP_REPEAT to allocate LZO1X_MEM_COMPRESS 16K. This is
> order 3 allocation request and __GFP_REPEAT is ignored for this size
> as well as all <= PAGE_ALLOC_COSTLY requests.
> 
> Cc: Herbert Xu <herbert@gondor.apana.org.au>
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: linux-crypto@vger.kernel.org
> Signed-off-by: Michal Hocko <mhocko@suse.com>

Applied.
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
