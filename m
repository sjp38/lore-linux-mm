Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 570056B0007
	for <linux-mm@kvack.org>; Sat,  3 Mar 2018 12:09:48 -0500 (EST)
Received: by mail-pl0-f72.google.com with SMTP id j6-v6so6377466pll.10
        for <linux-mm@kvack.org>; Sat, 03 Mar 2018 09:09:48 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id a74si4436783pfj.287.2018.03.03.09.09.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sat, 03 Mar 2018 09:09:47 -0800 (PST)
Date: Sat, 3 Mar 2018 09:09:44 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v7 02/61] radix tree: Use bottom four bits of gfp_t for
 flags
Message-ID: <20180303170944.GB29990@bombadil.infradead.org>
References: <20180219194556.6575-1-willy@infradead.org>
 <20180219194556.6575-3-willy@infradead.org>
 <1520081076.4280.18.camel@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1520081076.4280.18.camel@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeff Layton <jlayton@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <mawilcox@microsoft.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

On Sat, Mar 03, 2018 at 07:44:36AM -0500, Jeff Layton wrote:
> > -	return root->gfp_mask & __GFP_BITS_MASK;
> > +	return root->gfp_mask & ((__GFP_BITS_MASK >> 4) << 4);
> 
> Maybe phrase this in terms of a constant like GFP_ZONEMASK here? Would
> this be more appropriate?

Yeah, that's a better idea.  This is only interim; once all radix tree users
are converted to the xarray, we stop storing GFP flags here.  So I hadn't
put much thought into it, but I'll change it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
