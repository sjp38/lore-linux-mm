Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id AED526B0005
	for <linux-mm@kvack.org>; Thu, 14 Apr 2016 03:02:19 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id l6so44770549wml.3
        for <linux-mm@kvack.org>; Thu, 14 Apr 2016 00:02:19 -0700 (PDT)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id bw2si42413470wjc.138.2016.04.14.00.02.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Apr 2016 00:02:18 -0700 (PDT)
Received: by mail-wm0-f66.google.com with SMTP id a140so20005146wma.2
        for <linux-mm@kvack.org>; Thu, 14 Apr 2016 00:02:18 -0700 (PDT)
Date: Thu, 14 Apr 2016 09:02:17 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 18/19] crypto: get rid of superfluous __GFP_REPEAT
Message-ID: <20160414070216.GA2850@dhcp22.suse.cz>
References: <1460372892-8157-1-git-send-email-mhocko@kernel.org>
 <1460372892-8157-19-git-send-email-mhocko@kernel.org>
 <20160414062731.GA19640@gondor.apana.org.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160414062731.GA19640@gondor.apana.org.au>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, "David S. Miller" <davem@davemloft.net>

On Thu 14-04-16 14:27:31, Herbert Xu wrote:
> On Mon, Apr 11, 2016 at 01:08:11PM +0200, Michal Hocko wrote:
> > From: Michal Hocko <mhocko@suse.com>
> > 
> > __GFP_REPEAT has a rather weak semantic but since it has been introduced
> > around 2.6.12 it has been ignored for low order allocations.
> > 
> > lzo_init uses __GFP_REPEAT to allocate LZO1X_MEM_COMPRESS 16K. This is
> > order 3 allocation request and __GFP_REPEAT is ignored for this size
> > as well as all <= PAGE_ALLOC_COSTLY requests.
> > 
> > Cc: Herbert Xu <herbert@gondor.apana.org.au>
> > Cc: "David S. Miller" <davem@davemloft.net>
> > Signed-off-by: Michal Hocko <mhocko@suse.com>
> 
> Could you please send this patch to the linux-crypto list? Thanks.

Will do. Do you prefer it now as a stand along patch or when I repost
the full series. This one doesn't depend on any previous so I can do
both ways.

Thanks!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
