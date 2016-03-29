Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f176.google.com (mail-ig0-f176.google.com [209.85.213.176])
	by kanga.kvack.org (Postfix) with ESMTP id 2F0A76B007E
	for <linux-mm@kvack.org>; Mon, 28 Mar 2016 20:53:45 -0400 (EDT)
Received: by mail-ig0-f176.google.com with SMTP id l20so2813304igf.0
        for <linux-mm@kvack.org>; Mon, 28 Mar 2016 17:53:45 -0700 (PDT)
Received: from resqmta-po-03v.sys.comcast.net (resqmta-po-03v.sys.comcast.net. [2001:558:fe16:19:96:114:154:162])
        by mx.google.com with ESMTPS id l87si889131iod.62.2016.03.28.17.53.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Mar 2016 17:53:43 -0700 (PDT)
Date: Mon, 28 Mar 2016 19:53:39 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 02/11] mm/slab: remove BAD_ALIEN_MAGIC again
In-Reply-To: <20160328141911.3048ab8d406b86a6e5b9f910@linux-foundation.org>
Message-ID: <alpine.DEB.2.20.1603281951380.31323@east.gentwo.org>
References: <1459142821-20303-1-git-send-email-iamjoonsoo.kim@lge.com> <1459142821-20303-3-git-send-email-iamjoonsoo.kim@lge.com> <20160328141911.3048ab8d406b86a6e5b9f910@linux-foundation.org>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: js1304@gmail.com, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Jesper Dangaard Brouer <brouer@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On Mon, 28 Mar 2016, Andrew Morton wrote:

> On Mon, 28 Mar 2016 14:26:52 +0900 js1304@gmail.com wrote:
>
> > From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> >
> > Initial attemp to remove BAD_ALIEN_MAGIC is once reverted by
> > 'commit edcad2509550 ("Revert "slab: remove BAD_ALIEN_MAGIC"")'
> > because it causes a problem on m68k which has many node
> > but !CONFIG_NUMA.
>
> Whaaa?  How is that even possible?  I'd have thought that everything
> would break at compile time (at least) with such a setup.

Yes we have that and the support for this caused numerous issues. Can we
stop supporting such a configuration?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
