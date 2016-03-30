Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f180.google.com (mail-io0-f180.google.com [209.85.223.180])
	by kanga.kvack.org (Postfix) with ESMTP id 73D976B007E
	for <linux-mm@kvack.org>; Wed, 30 Mar 2016 04:09:37 -0400 (EDT)
Received: by mail-io0-f180.google.com with SMTP id e3so56231156ioa.1
        for <linux-mm@kvack.org>; Wed, 30 Mar 2016 01:09:37 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id qf2si18177614igb.91.2016.03.30.01.09.36
        for <linux-mm@kvack.org>;
        Wed, 30 Mar 2016 01:09:36 -0700 (PDT)
Date: Wed, 30 Mar 2016 17:11:35 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 02/11] mm/slab: remove BAD_ALIEN_MAGIC again
Message-ID: <20160330081135.GB1678@js1304-P5Q-DELUXE>
References: <1459142821-20303-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1459142821-20303-3-git-send-email-iamjoonsoo.kim@lge.com>
 <CAMuHMdU7WzkTccN_wa_LB+qx=1f_4V0SSRF+XqNdgYvCb2o5Ng@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAMuHMdU7WzkTccN_wa_LB+qx=1f_4V0SSRF+XqNdgYvCb2o5Ng@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Geert Uytterhoeven <geert@linux-m68k.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Linux MM <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Mon, Mar 28, 2016 at 10:58:38AM +0200, Geert Uytterhoeven wrote:
> Hi Jonsoo,
> 
> On Mon, Mar 28, 2016 at 7:26 AM,  <js1304@gmail.com> wrote:
> > From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> >
> > Initial attemp to remove BAD_ALIEN_MAGIC is once reverted by
> > 'commit edcad2509550 ("Revert "slab: remove BAD_ALIEN_MAGIC"")'
> > because it causes a problem on m68k which has many node
> > but !CONFIG_NUMA. In this case, although alien cache isn't used
> > at all but to cope with some initialization path, garbage value
> > is used and that is BAD_ALIEN_MAGIC. Now, this patch set
> > use_alien_caches to 0 when !CONFIG_NUMA, there is no initialization
> > path problem so we don't need BAD_ALIEN_MAGIC at all. So remove it.
> >
> > Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> 
> I gave this a try on m68k/ARAnyM, and it didn't crash, unlike the previous
> version that was reverted, so
> Tested-by: Geert Uytterhoeven <geert@linux-m68k.org>

Thanks for testing!!!

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
