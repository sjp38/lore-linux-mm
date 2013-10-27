Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f43.google.com (mail-pb0-f43.google.com [209.85.160.43])
	by kanga.kvack.org (Postfix) with ESMTP id 370ED6B00DA
	for <linux-mm@kvack.org>; Sun, 27 Oct 2013 09:43:05 -0400 (EDT)
Received: by mail-pb0-f43.google.com with SMTP id md4so898207pbc.30
        for <linux-mm@kvack.org>; Sun, 27 Oct 2013 06:43:04 -0700 (PDT)
Received: from psmtp.com ([74.125.245.176])
        by mx.google.com with SMTP id gw3si10406303pac.317.2013.10.27.06.43.03
        for <linux-mm@kvack.org>;
        Sun, 27 Oct 2013 06:43:04 -0700 (PDT)
Received: by mail-qe0-f49.google.com with SMTP id a11so3383232qen.22
        for <linux-mm@kvack.org>; Sun, 27 Oct 2013 06:43:02 -0700 (PDT)
Date: Sun, 27 Oct 2013 09:42:57 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: ARM/kirkwood: v3.12-rc6: kernel BUG at mm/util.c:390!
Message-ID: <20131027134257.GB30783@mtj.dyndns.org>
References: <20131024200730.GB17447@blackmetal.musicnaut.iki.fi>
 <20131026143617.GA14034@mudshark.cambridge.arm.com>
 <20131027195115.208f40f3@tom-ThinkPad-T410>
 <20131027125036.GJ17447@blackmetal.musicnaut.iki.fi>
 <CACVXFVP2B3=82m_+DfA_oAEW86c=oxQ52G+yj5ncTU1DzP26Bw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CACVXFVP2B3=82m_+DfA_oAEW86c=oxQ52G+yj5ncTU1DzP26Bw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ming Lei <tom.leiming@gmail.com>
Cc: Aaro Koskinen <aaro.koskinen@iki.fi>, Will Deacon <will.deacon@arm.com>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Simon Baatz <gmbnomis@gmail.com>, Catalin Marinas <catalin.marinas@arm.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Andrew Morton <akpm@linux-foundation.org>, FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>, "James E.J. Bottomley" <JBottomley@parallels.com>, Jens Axboe <axboe@kernel.dk>

On Sun, Oct 27, 2013 at 09:16:53PM +0800, Ming Lei wrote:
> On Sun, Oct 27, 2013 at 8:50 PM, Aaro Koskinen <aaro.koskinen@iki.fi> wrote:
> >
> > On ARM v3.9 or older kernels do not trigger this BUG, at seems it only
> > started to appear with the following commit (bisected):
> >
> > commit 1bc39742aab09248169ef9d3727c9def3528b3f3
> > Author: Simon Baatz <gmbnomis@gmail.com>
> > Date:   Mon Jun 10 21:10:12 2013 +0100
> >
> >     ARM: 7755/1: handle user space mapped pages in flush_kernel_dcache_page
> 
> The above commit only starts to implement the helper on ARM,
> but according to Documentation/cachetlb.txt, looks caller of
> flush_kernel_dcache_page() should make sure the passed
> 'page' is a user space page.

I don't think PageSlab() is the right test tho.  Wouldn't testing
against user_addr_max() make more sense?

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
