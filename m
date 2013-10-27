Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 1CCB06B00DB
	for <linux-mm@kvack.org>; Sun, 27 Oct 2013 09:48:01 -0400 (EDT)
Received: by mail-pa0-f46.google.com with SMTP id rd3so5722660pab.33
        for <linux-mm@kvack.org>; Sun, 27 Oct 2013 06:48:00 -0700 (PDT)
Received: from psmtp.com ([74.125.245.116])
        by mx.google.com with SMTP id ln9si10470966pab.15.2013.10.27.06.47.58
        for <linux-mm@kvack.org>;
        Sun, 27 Oct 2013 06:47:59 -0700 (PDT)
Date: Sun, 27 Oct 2013 13:47:19 +0000
From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: ARM/kirkwood: v3.12-rc6: kernel BUG at mm/util.c:390!
Message-ID: <20131027134718.GC16735@n2100.arm.linux.org.uk>
References: <20131024200730.GB17447@blackmetal.musicnaut.iki.fi> <20131026143617.GA14034@mudshark.cambridge.arm.com> <20131027195115.208f40f3@tom-ThinkPad-T410> <20131027125036.GJ17447@blackmetal.musicnaut.iki.fi> <CACVXFVP2B3=82m_+DfA_oAEW86c=oxQ52G+yj5ncTU1DzP26Bw@mail.gmail.com> <20131027134257.GB30783@mtj.dyndns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131027134257.GB30783@mtj.dyndns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Ming Lei <tom.leiming@gmail.com>, Aaro Koskinen <aaro.koskinen@iki.fi>, Will Deacon <will.deacon@arm.com>, Simon Baatz <gmbnomis@gmail.com>, Catalin Marinas <catalin.marinas@arm.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Andrew Morton <akpm@linux-foundation.org>, FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>, "James E.J. Bottomley" <JBottomley@parallels.com>, Jens Axboe <axboe@kernel.dk>

On Sun, Oct 27, 2013 at 09:42:57AM -0400, Tejun Heo wrote:
> On Sun, Oct 27, 2013 at 09:16:53PM +0800, Ming Lei wrote:
> > On Sun, Oct 27, 2013 at 8:50 PM, Aaro Koskinen <aaro.koskinen@iki.fi> wrote:
> > >
> > > On ARM v3.9 or older kernels do not trigger this BUG, at seems it only
> > > started to appear with the following commit (bisected):
> > >
> > > commit 1bc39742aab09248169ef9d3727c9def3528b3f3
> > > Author: Simon Baatz <gmbnomis@gmail.com>
> > > Date:   Mon Jun 10 21:10:12 2013 +0100
> > >
> > >     ARM: 7755/1: handle user space mapped pages in flush_kernel_dcache_page
> > 
> > The above commit only starts to implement the helper on ARM,
> > but according to Documentation/cachetlb.txt, looks caller of
> > flush_kernel_dcache_page() should make sure the passed
> > 'page' is a user space page.
> 
> I don't think PageSlab() is the right test tho.  Wouldn't testing
> against user_addr_max() make more sense?

How does that help for a function passed a struct page pointer?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
