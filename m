Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7BD576B026C
	for <linux-mm@kvack.org>; Wed, 22 Nov 2017 17:24:05 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id s11so17420932pgc.15
        for <linux-mm@kvack.org>; Wed, 22 Nov 2017 14:24:05 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id h9si13090847pli.42.2017.11.22.14.24.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Nov 2017 14:24:04 -0800 (PST)
Date: Wed, 22 Nov 2017 14:24:02 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH 05/62] radix tree: Add a missing cast to gfp_t
Message-ID: <20171122222402.GA13634@bombadil.infradead.org>
References: <20171122210739.29916-1-willy@infradead.org>
 <20171122210739.29916-6-willy@infradead.org>
 <20171122212847.axib6ito23sldlbe@ltop.local>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171122212847.axib6ito23sldlbe@ltop.local>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Luc Van Oostenryck <luc.vanoostenryck@gmail.com>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Matthew Wilcox <mawilcox@microsoft.com>

On Wed, Nov 22, 2017 at 10:28:48PM +0100, Luc Van Oostenryck wrote:
> > -	root->gfp_mask &= (1 << ROOT_TAG_SHIFT) - 1;
> > +	root->gfp_mask &= (__force gfp_t)((1 << ROOT_TAG_SHIFT) - 1);
> 
> IMO, it would be better to define something for that in radix-tree.h,
> like it has been done for ROOT_IS_IDR.

If we were keeping the radix tree around, I'd agree, but the point of
the rest of this patch set is replacing it ;-)  I should probably have
just dropped this patch, to be honest.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
