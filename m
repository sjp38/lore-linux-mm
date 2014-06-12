Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id C64FC900002
	for <linux-mm@kvack.org>; Thu, 12 Jun 2014 01:51:58 -0400 (EDT)
Received: by mail-pa0-f43.google.com with SMTP id lf10so614792pab.30
        for <linux-mm@kvack.org>; Wed, 11 Jun 2014 22:51:58 -0700 (PDT)
Received: from lgemrelse7q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id yj9si9029731pab.135.2014.06.11.22.51.56
        for <linux-mm@kvack.org>;
        Wed, 11 Jun 2014 22:51:57 -0700 (PDT)
Date: Thu, 12 Jun 2014 14:55:55 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH v2 01/10] DMA, CMA: clean-up log message
Message-ID: <20140612055555.GB30128@js1304-P5Q-DELUXE>
References: <1402543307-29800-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1402543307-29800-2-git-send-email-iamjoonsoo.kim@lge.com>
 <20140612051853.GD12415@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140612051853.GD12415@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, Russell King - ARM Linux <linux@arm.linux.org.uk>, kvm@vger.kernel.org, linux-mm@kvack.org, Gleb Natapov <gleb@kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Alexander Graf <agraf@suse.de>, kvm-ppc@vger.kernel.org, linux-kernel@vger.kernel.org, Paul Mackerras <paulus@samba.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paolo Bonzini <pbonzini@redhat.com>, linuxppc-dev@lists.ozlabs.org, linux-arm-kernel@lists.infradead.org

On Thu, Jun 12, 2014 at 02:18:53PM +0900, Minchan Kim wrote:
> Hi Joonsoo,
> 
> On Thu, Jun 12, 2014 at 12:21:38PM +0900, Joonsoo Kim wrote:
> > We don't need explicit 'CMA:' prefix, since we already define prefix
> > 'cma:' in pr_fmt. So remove it.
> > 
> > And, some logs print function name and others doesn't. This looks
> > bad to me, so I unify log format to print function name consistently.
> > 
> > Lastly, I add one more debug log on cma_activate_area().
> 
> When I take a look, it just indicates cma_activate_area was called or not,
> without what range for the area was reserved successfully so I couldn't see
> the intention for new message. Description should explain it so that everybody
> can agree on your claim.
> 

Hello,

I paste the answer in other thread.

This pr_debug() comes from ppc kvm's kvm_cma_init_reserved_areas().
I want to maintain all log messages as much as possible to reduce
confusion with this generalization.

If I need to respin this patchset, I will explain more about it.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
