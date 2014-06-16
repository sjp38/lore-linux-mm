Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f42.google.com (mail-pb0-f42.google.com [209.85.160.42])
	by kanga.kvack.org (Postfix) with ESMTP id 0AE4B6B0031
	for <linux-mm@kvack.org>; Mon, 16 Jun 2014 01:14:21 -0400 (EDT)
Received: by mail-pb0-f42.google.com with SMTP id ma3so3828050pbc.1
        for <linux-mm@kvack.org>; Sun, 15 Jun 2014 22:14:21 -0700 (PDT)
Received: from lgemrelse6q.lge.com (LGEMRELSE6Q.lge.com. [156.147.1.121])
        by mx.google.com with ESMTP id ib4si12393172pad.70.2014.06.15.22.14.19
        for <linux-mm@kvack.org>;
        Sun, 15 Jun 2014 22:14:21 -0700 (PDT)
Date: Mon, 16 Jun 2014 14:18:31 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH v2 01/10] DMA, CMA: clean-up log message
Message-ID: <20140616051830.GA23210@js1304-P5Q-DELUXE>
References: <1402543307-29800-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1402543307-29800-2-git-send-email-iamjoonsoo.kim@lge.com>
 <87y4x2pwnk.fsf@linux.vnet.ibm.com>
 <20140612055358.GA30128@js1304-P5Q-DELUXE>
 <xa1toaxyjym3.fsf@mina86.com>
 <xa1tegyujvxv.fsf@mina86.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <xa1tegyujvxv.fsf@mina86.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Nazarewicz <mina86@mina86.com>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Minchan Kim <minchan@kernel.org>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Paolo Bonzini <pbonzini@redhat.com>, Gleb Natapov <gleb@kernel.org>, Alexander Graf <agraf@suse.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, kvm@vger.kernel.org, kvm-ppc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org

On Thu, Jun 12, 2014 at 11:53:16AM +0200, Michal Nazarewicz wrote:
> On Thu, Jun 12 2014, Michal Nazarewicz <mina86@mina86.com> wrote:
> > I used a??function(arg1, arg2, a?|)a?? at the *beginning* of functions when
> > the arguments passed to the function were included in the message.  In
> > all other cases I left it at just a??function:a?? (or just no additional
> > prefix).  IMO that's a reasonable strategy.
> 
> At closer inspection, I realised drivers/base/dma-contiguous.c is
> Marek's code, but the above I think is still reasonable thing to do, so
> I'd rather standardise on having a??function(a?|)a?? only at the beginning of
> a function.  Just my 0.02 CHF.

Hello,

Now, I realize that these changes aren't needed in this patchset, so I
simplify this patch just to remove redundant 'CMA' prefix. Other things
can be done after merging if we need.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
