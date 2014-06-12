Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f53.google.com (mail-pb0-f53.google.com [209.85.160.53])
	by kanga.kvack.org (Postfix) with ESMTP id 3E589900002
	for <linux-mm@kvack.org>; Thu, 12 Jun 2014 03:16:08 -0400 (EDT)
Received: by mail-pb0-f53.google.com with SMTP id uo5so437798pbc.26
        for <linux-mm@kvack.org>; Thu, 12 Jun 2014 00:16:07 -0700 (PDT)
Received: from lgemrelse6q.lge.com (LGEMRELSE6Q.lge.com. [156.147.1.121])
        by mx.google.com with ESMTP id oh6si40663802pbb.12.2014.06.12.00.16.05
        for <linux-mm@kvack.org>;
        Thu, 12 Jun 2014 00:16:07 -0700 (PDT)
Date: Thu, 12 Jun 2014 16:16:15 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v2 08/10] mm, cma: clean-up cma allocation error path
Message-ID: <20140612071615.GK12415@bbox>
References: <1402543307-29800-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1402543307-29800-9-git-send-email-iamjoonsoo.kim@lge.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1402543307-29800-9-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, Russell King - ARM Linux <linux@arm.linux.org.uk>, kvm@vger.kernel.org, linux-mm@kvack.org, Gleb Natapov <gleb@kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Alexander Graf <agraf@suse.de>, kvm-ppc@vger.kernel.org, linux-kernel@vger.kernel.org, Paul Mackerras <paulus@samba.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paolo Bonzini <pbonzini@redhat.com>, linuxppc-dev@lists.ozlabs.org, linux-arm-kernel@lists.infradead.org

On Thu, Jun 12, 2014 at 12:21:45PM +0900, Joonsoo Kim wrote:
> We can remove one call sites for clear_cma_bitmap() if we first
> call it before checking error number.
> 
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Acked-by: Minchan Kim <minchan@kernel.org>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
