Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id E63636B0253
	for <linux-mm@kvack.org>; Mon, 11 Apr 2016 06:40:18 -0400 (EDT)
Received: by mail-pa0-f48.google.com with SMTP id zm5so119490969pac.0
        for <linux-mm@kvack.org>; Mon, 11 Apr 2016 03:40:18 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id b90si2858241pfd.128.2016.04.11.03.40.18
        for <linux-mm@kvack.org>;
        Mon, 11 Apr 2016 03:40:18 -0700 (PDT)
Date: Mon, 11 Apr 2016 11:40:13 +0100
From: Will Deacon <will.deacon@arm.com>
Subject: Re: [PATCH 1/2] arm64: mem-model: add flatmem model for arm64
Message-ID: <20160411104013.GG15729@arm.com>
References: <1459844572-53069-1-git-send-email-puck.chen@hisilicon.com>
 <20160407142148.GI5657@arm.com>
 <570B10B2.2000000@hisilicon.com>
 <CAKv+Gu8iQ0NzLFWHy9Ggyv+jL-BqJ3x-KaRD1SZ1mU6yU3c7UQ@mail.gmail.com>
 <570B5875.20804@hisilicon.com>
 <CAKv+Gu9aqR=E3TmbPDFEUC+Q13bAJTU5wVTTHkOr6aX6BZ1OVA@mail.gmail.com>
 <570B758E.7070005@hisilicon.com>
 <CAKv+Gu-cWWUi6fCiveqaZRVhGCpEasCLEs7wq6t+C-x65g4cgQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAKv+Gu-cWWUi6fCiveqaZRVhGCpEasCLEs7wq6t+C-x65g4cgQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Cc: Chen Feng <puck.chen@hisilicon.com>, Mark Rutland <mark.rutland@arm.com>, mhocko@suse.com, Laura Abbott <labbott@redhat.com>, Dan Zhao <dan.zhao@hisilicon.com>, Yiping Xu <xuyiping@hisilicon.com>, puck.chen@foxmail.com, albert.lubing@hisilicon.com, Catalin Marinas <catalin.marinas@arm.com>, suzhuangluan@hisilicon.com, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linuxarm@huawei.com, "linux-mm@kvack.org" <linux-mm@kvack.org>, kirill.shutemov@linux.intel.com, David Rientjes <rientjes@google.com>, oliver.fu@hisilicon.com, Andrew Morton <akpm@linux-foundation.org>, robin.murphy@arm.com, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, saberlily.xia@hisilicon.com

On Mon, Apr 11, 2016 at 12:31:53PM +0200, Ard Biesheuvel wrote:
> On 11 April 2016 at 11:59, Chen Feng <puck.chen@hisilicon.com> wrote:
> > Please see the pg-tables below.
> >
> >
> > With sparse and vmemmap enable.
> >
> > ---[ vmemmap start ]---
> > 0xffffffbdc0200000-0xffffffbdc4800000          70M     RW NX SHD AF    UXN MEM/NORMAL
> > ---[ vmemmap end ]---
> >
> 
> OK, I see what you mean now. Sorry for taking so long to catch up.
> 
> > The board is 4GB, and the memap is 70MB
> > 1G memory --- 14MB mem_map array.
> 
> No, this is incorrect. 1 GB corresponds with 16 MB worth of struct
> pages assuming sizeof(struct page) == 64
> 
> So you are losing 6 MB to rounding here, which I agree is significant.
> I wonder if it makes sense to use a lower value for SECTION_SIZE_BITS
> on 4k pages kernels, but perhaps we're better off asking the opinion
> of the other cc'ees.

You need to be really careful making SECTION_SIZE_BITS smaller because
it has a direct correlation on the use of page->flags and you can end up
running out of bits fairly easily.

Will

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
