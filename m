Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5580A6B0005
	for <linux-mm@kvack.org>; Thu, 14 Apr 2016 04:16:54 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id u190so116651053pfb.0
        for <linux-mm@kvack.org>; Thu, 14 Apr 2016 01:16:54 -0700 (PDT)
Received: from helcar.hengli.com.au (helcar.hengli.com.au. [209.40.204.226])
        by mx.google.com with ESMTPS id rk14si6522641pab.187.2016.04.14.01.16.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Thu, 14 Apr 2016 01:16:52 -0700 (PDT)
Date: Thu, 14 Apr 2016 16:16:42 +0800
From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 18/19] crypto: get rid of superfluous __GFP_REPEAT
Message-ID: <20160414081642.GA21031@gondor.apana.org.au>
References: <1460372892-8157-1-git-send-email-mhocko@kernel.org>
 <1460372892-8157-19-git-send-email-mhocko@kernel.org>
 <20160414062731.GA19640@gondor.apana.org.au>
 <20160414070216.GA2850@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160414070216.GA2850@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, "David S. Miller" <davem@davemloft.net>

On Thu, Apr 14, 2016 at 09:02:17AM +0200, Michal Hocko wrote:
>
> Will do. Do you prefer it now as a stand along patch or when I repost
> the full series. This one doesn't depend on any previous so I can do
> both ways.

I think a standalone patch is fine.

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
