Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id E53506B0036
	for <linux-mm@kvack.org>; Mon, 25 Aug 2014 22:23:47 -0400 (EDT)
Received: by mail-pa0-f54.google.com with SMTP id fa1so22455389pad.13
        for <linux-mm@kvack.org>; Mon, 25 Aug 2014 19:23:47 -0700 (PDT)
Received: from lgemrelse7q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id gp10si2285709pbc.44.2014.08.25.19.23.45
        for <linux-mm@kvack.org>;
        Mon, 25 Aug 2014 19:23:47 -0700 (PDT)
Date: Tue, 26 Aug 2014 11:23:59 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 2/3] mm/slab_common: commonize slab merge logic
Message-ID: <20140826022359.GB1035@js1304-P5Q-DELUXE>
References: <1408608675-20420-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1408608675-20420-2-git-send-email-iamjoonsoo.kim@lge.com>
 <alpine.DEB.2.11.1408251026110.27302@gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.11.1408251026110.27302@gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Aug 25, 2014 at 10:27:58AM -0500, Christoph Lameter wrote:
> On Thu, 21 Aug 2014, Joonsoo Kim wrote:
> 
> > +static int __init setup_slab_nomerge(char *str)
> > +{
> > +	slab_nomerge = 1;
> > +	return 1;
> > +}
> > +__setup("slub_nomerge", setup_slab_nomerge);
> 
> Uhh.. You would have to specify "slub_nomerge" to get slab to not merge
> slab caches?

Should fix it. How about following change?

#ifdef CONFIG_SLUB
__setup("slub_nomerge", setup_slab_nomerge);
#endif

__setup("slab_nomerge", setup_slab_nomerge);

This makes "slab_nomerge" works for all SL[aou]B.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
