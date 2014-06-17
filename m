Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f51.google.com (mail-pb0-f51.google.com [209.85.160.51])
	by kanga.kvack.org (Postfix) with ESMTP id 50DBD6B0031
	for <linux-mm@kvack.org>; Mon, 16 Jun 2014 21:29:36 -0400 (EDT)
Received: by mail-pb0-f51.google.com with SMTP id rp16so5089637pbb.10
        for <linux-mm@kvack.org>; Mon, 16 Jun 2014 18:29:36 -0700 (PDT)
Received: from lgeamrelo04.lge.com (lgeamrelo04.lge.com. [156.147.1.127])
        by mx.google.com with ESMTP id pk4si1086777pbc.252.2014.06.16.18.29.34
        for <linux-mm@kvack.org>;
        Mon, 16 Jun 2014 18:29:35 -0700 (PDT)
Date: Tue, 17 Jun 2014 10:33:50 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH v3 -next 1/9] DMA, CMA: fix possible memory leak
Message-ID: <20140617013349.GB6825@js1304-P5Q-DELUXE>
References: <1402897251-23639-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1402897251-23639-2-git-send-email-iamjoonsoo.kim@lge.com>
 <20140616062719.GA18790@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140616062719.GA18790@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Paolo Bonzini <pbonzini@redhat.com>, Gleb Natapov <gleb@kernel.org>, Alexander Graf <agraf@suse.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, kvm@vger.kernel.org, kvm-ppc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>

On Mon, Jun 16, 2014 at 03:27:19PM +0900, Minchan Kim wrote:
> Hi, Joonsoo
> 
> On Mon, Jun 16, 2014 at 02:40:43PM +0900, Joonsoo Kim wrote:
> > We should free memory for bitmap when we find zone mis-match,
> > otherwise this memory will leak.
> > 
> > Additionally, I copy code comment from PPC KVM's CMA code to inform
> > why we need to check zone mis-match.
> > 
> > * Note
> > Minchan suggested to add a tag for the stable, but, I don't do it,
> > because I found this possibility during code-review and, IMO,
> > this patch isn't suitable for stable tree.
> 
> Nice idea to put the comment in here. Thanks Joonsoo.
> 
> It seems you obey "It must fix a real bug that bothers people"
> on Documentation/stable_kernel_rules.txt but it's a really obvious
> bug and hard to get a report from people because limited user and
> hard to detect small such small memory leak.
> 
> In my experince, Andrew perfered stable marking for such a obvious
> problem but simple fix like this but not sure so let's pass the decision
> to him and will learn a lesson from him and will follow the decision
> from now on.

Yes, I intended to pass the decision to others. :)

> 
> Thanks.
> 
> Acked-by: Minchan Kim <minchan@kernel.org>

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
