Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f177.google.com (mail-pf0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 66DC46B025E
	for <linux-mm@kvack.org>; Tue, 12 Apr 2016 10:44:42 -0400 (EDT)
Received: by mail-pf0-f177.google.com with SMTP id e128so15027257pfe.3
        for <linux-mm@kvack.org>; Tue, 12 Apr 2016 07:44:42 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id qm9si10650900pac.165.2016.04.12.07.44.41
        for <linux-mm@kvack.org>;
        Tue, 12 Apr 2016 07:44:41 -0700 (PDT)
Date: Tue, 12 Apr 2016 15:44:35 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCH 1/2] arm64: mem-model: add flatmem model for arm64
Message-ID: <20160412144434.GE8066@e104818-lin.cambridge.arm.com>
References: <1459844572-53069-1-git-send-email-puck.chen@hisilicon.com>
 <20160407142148.GI5657@arm.com>
 <570B10B2.2000000@hisilicon.com>
 <CAKv+Gu8iQ0NzLFWHy9Ggyv+jL-BqJ3x-KaRD1SZ1mU6yU3c7UQ@mail.gmail.com>
 <570B5875.20804@hisilicon.com>
 <CAKv+Gu9aqR=E3TmbPDFEUC+Q13bAJTU5wVTTHkOr6aX6BZ1OVA@mail.gmail.com>
 <570B758E.7070005@hisilicon.com>
 <CAKv+Gu-cWWUi6fCiveqaZRVhGCpEasCLEs7wq6t+C-x65g4cgQ@mail.gmail.com>
 <20160411104013.GG15729@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160411104013.GG15729@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Will Deacon <will.deacon@arm.com>
Cc: Ard Biesheuvel <ard.biesheuvel@linaro.org>, Mark Rutland <mark.rutland@arm.com>, Dan Zhao <dan.zhao@hisilicon.com>, mhocko@suse.com, Yiping Xu <xuyiping@hisilicon.com>, puck.chen@foxmail.com, "linux-mm@kvack.org" <linux-mm@kvack.org>, Chen Feng <puck.chen@hisilicon.com>, suzhuangluan@hisilicon.com, David Rientjes <rientjes@google.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linuxarm@huawei.com, albert.lubing@hisilicon.com, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, oliver.fu@hisilicon.com, Andrew Morton <akpm@linux-foundation.org>, Laura Abbott <labbott@redhat.com>, robin.murphy@arm.com, kirill.shutemov@linux.intel.com, saberlily.xia@hisilicon.com

On Mon, Apr 11, 2016 at 11:40:13AM +0100, Will Deacon wrote:
> On Mon, Apr 11, 2016 at 12:31:53PM +0200, Ard Biesheuvel wrote:
> > On 11 April 2016 at 11:59, Chen Feng <puck.chen@hisilicon.com> wrote:
> > > Please see the pg-tables below.
> > >
> > >
> > > With sparse and vmemmap enable.
> > >
> > > ---[ vmemmap start ]---
> > > 0xffffffbdc0200000-0xffffffbdc4800000          70M     RW NX SHD AF    UXN MEM/NORMAL
> > > ---[ vmemmap end ]---
> > >
> > 
> > OK, I see what you mean now. Sorry for taking so long to catch up.
> > 
> > > The board is 4GB, and the memap is 70MB
> > > 1G memory --- 14MB mem_map array.
> > 
> > No, this is incorrect. 1 GB corresponds with 16 MB worth of struct
> > pages assuming sizeof(struct page) == 64
> > 
> > So you are losing 6 MB to rounding here, which I agree is significant.
> > I wonder if it makes sense to use a lower value for SECTION_SIZE_BITS
> > on 4k pages kernels, but perhaps we're better off asking the opinion
> > of the other cc'ees.
> 
> You need to be really careful making SECTION_SIZE_BITS smaller because
> it has a direct correlation on the use of page->flags and you can end up
> running out of bits fairly easily.

With SPARSEMEM_VMEMMAP, SECTION_SIZE_BITS no longer affect the page
flags since we no longer need to encode the section number in
page->flags.

-- 
Catalin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
