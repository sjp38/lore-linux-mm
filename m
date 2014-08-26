Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 2D3C46B0035
	for <linux-mm@kvack.org>; Tue, 26 Aug 2014 17:23:18 -0400 (EDT)
Received: by mail-pd0-f174.google.com with SMTP id fp1so23073538pdb.5
        for <linux-mm@kvack.org>; Tue, 26 Aug 2014 14:23:17 -0700 (PDT)
Received: from qmta03.emeryville.ca.mail.comcast.net (qmta03.emeryville.ca.mail.comcast.net. [2001:558:fe2d:43:76:96:30:32])
        by mx.google.com with ESMTP id to5si6346899pac.7.2014.08.26.14.23.16
        for <linux-mm@kvack.org>;
        Tue, 26 Aug 2014 14:23:17 -0700 (PDT)
Date: Tue, 26 Aug 2014 16:23:14 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 2/3] mm/slab_common: commonize slab merge logic
In-Reply-To: <20140826022359.GB1035@js1304-P5Q-DELUXE>
Message-ID: <alpine.DEB.2.11.1408261622420.4609@gentwo.org>
References: <1408608675-20420-1-git-send-email-iamjoonsoo.kim@lge.com> <1408608675-20420-2-git-send-email-iamjoonsoo.kim@lge.com> <alpine.DEB.2.11.1408251026110.27302@gentwo.org> <20140826022359.GB1035@js1304-P5Q-DELUXE>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, 26 Aug 2014, Joonsoo Kim wrote:

> On Mon, Aug 25, 2014 at 10:27:58AM -0500, Christoph Lameter wrote:
> > Uhh.. You would have to specify "slub_nomerge" to get slab to not merge
> > slab caches?
>
> Should fix it. How about following change?
>
> #ifdef CONFIG_SLUB
> __setup("slub_nomerge", setup_slab_nomerge);
> #endif
>
> __setup("slab_nomerge", setup_slab_nomerge);
>
> This makes "slab_nomerge" works for all SL[aou]B.

Ok. At some point we need to make slub_nomerge legacy then.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
