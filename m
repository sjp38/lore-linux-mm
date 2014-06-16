Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id BB9BA6B0038
	for <linux-mm@kvack.org>; Mon, 16 Jun 2014 01:27:58 -0400 (EDT)
Received: by mail-pa0-f52.google.com with SMTP id eu11so4115154pac.11
        for <linux-mm@kvack.org>; Sun, 15 Jun 2014 22:27:58 -0700 (PDT)
Received: from lgemrelse7q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id yc9si12372983pab.221.2014.06.15.22.27.56
        for <linux-mm@kvack.org>;
        Sun, 15 Jun 2014 22:27:57 -0700 (PDT)
Date: Mon, 16 Jun 2014 14:32:09 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH v2 00/10] CMA: generalize CMA reserved area management
 code
Message-ID: <20140616053209.GG23210@js1304-P5Q-DELUXE>
References: <1402543307-29800-1-git-send-email-iamjoonsoo.kim@lge.com>
 <87r42seyvg.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87r42seyvg.fsf@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, Minchan Kim <minchan@kernel.org>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Paolo Bonzini <pbonzini@redhat.com>, Gleb Natapov <gleb@kernel.org>, Alexander Graf <agraf@suse.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, kvm@vger.kernel.org, kvm-ppc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org

On Sat, Jun 14, 2014 at 12:55:39PM +0530, Aneesh Kumar K.V wrote:
> Joonsoo Kim <iamjoonsoo.kim@lge.com> writes:
> 
> > Currently, there are two users on CMA functionality, one is the DMA
> > subsystem and the other is the kvm on powerpc. They have their own code
> > to manage CMA reserved area even if they looks really similar.
> > From my guess, it is caused by some needs on bitmap management. Kvm side
> > wants to maintain bitmap not for 1 page, but for more size. Eventually it
> > use bitmap where one bit represents 64 pages.
> >
> > When I implement CMA related patches, I should change those two places
> > to apply my change and it seem to be painful to me. I want to change
> > this situation and reduce future code management overhead through
> > this patch.
> >
> > This change could also help developer who want to use CMA in their
> > new feature development, since they can use CMA easily without
> > copying & pasting this reserved area management code.
> >
> > v2:
> >   Although this patchset looks very different with v1, the end result,
> >   that is, mm/cma.c is same with v1's one. So I carry Ack to patch 6-7.
> >
> > Patch 1-5 prepare some features to cover ppc kvm's requirements.
> > Patch 6-7 generalize CMA reserved area management code and change users
> > to use it.
> > Patch 8-10 clean-up minor things.
> 
> 
> I wanted to test the ppc changes and found that the patch series doesn't apply
> against v3.15 . Do you have a kernel tree which I can clone to test this
> series ?

This is based on linux-next -next-20140610.
And my tree is on following link.

https://github.com/JoonsooKim/linux/tree/cma-general-v2.0-next-20140610

But, I think I'm late, because you have already added a Tested-by tag.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
