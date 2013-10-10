Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id E2B3C6B0031
	for <linux-mm@kvack.org>; Wed,  9 Oct 2013 22:26:41 -0400 (EDT)
Received: by mail-pd0-f178.google.com with SMTP id w10so1855118pde.23
        for <linux-mm@kvack.org>; Wed, 09 Oct 2013 19:26:41 -0700 (PDT)
Received: by mail-ob0-f179.google.com with SMTP id wp18so1318576obc.10
        for <linux-mm@kvack.org>; Wed, 09 Oct 2013 19:26:39 -0700 (PDT)
Date: Wed, 9 Oct 2013 21:26:27 -0500
From: Seth Jennings <sjennings@variantweb.net>
Subject: Re: [PATCH] frontswap: enable call to invalidate area on swapoff
Message-ID: <20131010022627.GA8535@variantweb.net>
References: <1381159541-13981-1-git-send-email-k.kozlowski@samsung.com>
 <20131007150338.1fdee18b536bb1d9fe41a07b@linux-foundation.org>
 <1381220000.16135.10.camel@AMDC1943>
 <20131008130853.96139b79a0a4d3aaacc79ed2@linux-foundation.org>
 <20131009144045.GA5406@variantweb.net>
 <525602E3.3080501@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <525602E3.3080501@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Liu <bob.liu@oracle.com>
Cc: Seth Jennings <spartacus06@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Krzysztof Kozlowski <k.kozlowski@samsung.com>, linux-mm@kvack.org, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, linux-kernel@vger.kernel.org, Shaohua Li <shli@fusionio.com>, Minchan Kim <minchan@kernel.org>

On Thu, Oct 10, 2013 at 09:29:07AM +0800, Bob Liu wrote:
> On 10/09/2013 10:40 PM, Seth Jennings wrote:
> > 
> > The reason we never noticed this for zswap is that zswap has no
> > dynamically allocated per-type resources.  In the expected case,
> > where all of the pages have been drained from zswap,
> > zswap_frontswap_invalidate_area() is a no-op.
> > 
> 
> Not exactly, see the bug fix "mm/zswap: bugfix: memory leak when
> re-swapon" from Weijie.
> Zswap needs invalidate_area() also.

I remembered this patch as soon as I sent out this note.  What I said
about zswap_frontswap_invalidate_area() being a no-op in the expected
case is true as of v3.12-rc4, but it shouldn't be :)

I sent a note to Andrew reminding him to pull in that patch.

Thanks,
Seth

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
