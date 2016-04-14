Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id D66996B0005
	for <linux-mm@kvack.org>; Thu, 14 Apr 2016 02:27:38 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id o126so146864060iod.1
        for <linux-mm@kvack.org>; Wed, 13 Apr 2016 23:27:38 -0700 (PDT)
Received: from helcar.hengli.com.au (helcar.hengli.com.au. [209.40.204.226])
        by mx.google.com with ESMTPS id bw19si5011267igb.93.2016.04.13.23.27.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Wed, 13 Apr 2016 23:27:38 -0700 (PDT)
Date: Thu, 14 Apr 2016 14:27:31 +0800
From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 18/19] crypto: get rid of superfluous __GFP_REPEAT
Message-ID: <20160414062731.GA19640@gondor.apana.org.au>
References: <1460372892-8157-1-git-send-email-mhocko@kernel.org>
 <1460372892-8157-19-git-send-email-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1460372892-8157-19-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, "David S. Miller" <davem@davemloft.net>

On Mon, Apr 11, 2016 at 01:08:11PM +0200, Michal Hocko wrote:
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
> Signed-off-by: Michal Hocko <mhocko@suse.com>

Could you please send this patch to the linux-crypto list? Thanks.
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
