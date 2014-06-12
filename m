Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f45.google.com (mail-pb0-f45.google.com [209.85.160.45])
	by kanga.kvack.org (Postfix) with ESMTP id 468A0900002
	for <linux-mm@kvack.org>; Thu, 12 Jun 2014 03:39:33 -0400 (EDT)
Received: by mail-pb0-f45.google.com with SMTP id um1so719525pbc.32
        for <linux-mm@kvack.org>; Thu, 12 Jun 2014 00:39:32 -0700 (PDT)
Received: from lgemrelse7q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id x4si40633913pbw.180.2014.06.12.00.39.31
        for <linux-mm@kvack.org>;
        Thu, 12 Jun 2014 00:39:32 -0700 (PDT)
Date: Thu, 12 Jun 2014 16:43:29 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH v2 09/10] mm, cma: move output param to the end of param
 list
Message-ID: <20140612074329.GC20199@js1304-P5Q-DELUXE>
References: <1402543307-29800-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1402543307-29800-10-git-send-email-iamjoonsoo.kim@lge.com>
 <20140612071930.GL12415@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140612071930.GL12415@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, Russell King - ARM Linux <linux@arm.linux.org.uk>, kvm@vger.kernel.org, linux-mm@kvack.org, Gleb Natapov <gleb@kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Alexander Graf <agraf@suse.de>, kvm-ppc@vger.kernel.org, linux-kernel@vger.kernel.org, Paul Mackerras <paulus@samba.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paolo Bonzini <pbonzini@redhat.com>, linuxppc-dev@lists.ozlabs.org, linux-arm-kernel@lists.infradead.org

On Thu, Jun 12, 2014 at 04:19:31PM +0900, Minchan Kim wrote:
> On Thu, Jun 12, 2014 at 12:21:46PM +0900, Joonsoo Kim wrote:
> > Conventionally, we put output param to the end of param list.
> > cma_declare_contiguous() doesn't look like that, so change it.
> 
> If you says "Conventionally", I'd like to suggest one more thing.
> Conventionally, we put 'base' ahead 'size' but dma_contiguous_reserve_area
> is opposite.

Okay. I will do it. :)

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
