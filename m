Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f48.google.com (mail-pb0-f48.google.com [209.85.160.48])
	by kanga.kvack.org (Postfix) with ESMTP id 1F0456B00D9
	for <linux-mm@kvack.org>; Sun, 27 Oct 2013 09:16:56 -0400 (EDT)
Received: by mail-pb0-f48.google.com with SMTP id mc17so453037pbc.21
        for <linux-mm@kvack.org>; Sun, 27 Oct 2013 06:16:55 -0700 (PDT)
Received: from psmtp.com ([74.125.245.125])
        by mx.google.com with SMTP id yj4si10396031pac.166.2013.10.27.06.16.54
        for <linux-mm@kvack.org>;
        Sun, 27 Oct 2013 06:16:55 -0700 (PDT)
Received: by mail-ve0-f182.google.com with SMTP id c14so2758513vea.13
        for <linux-mm@kvack.org>; Sun, 27 Oct 2013 06:16:53 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20131027125036.GJ17447@blackmetal.musicnaut.iki.fi>
References: <20131024200730.GB17447@blackmetal.musicnaut.iki.fi>
	<20131026143617.GA14034@mudshark.cambridge.arm.com>
	<20131027195115.208f40f3@tom-ThinkPad-T410>
	<20131027125036.GJ17447@blackmetal.musicnaut.iki.fi>
Date: Sun, 27 Oct 2013 21:16:53 +0800
Message-ID: <CACVXFVP2B3=82m_+DfA_oAEW86c=oxQ52G+yj5ncTU1DzP26Bw@mail.gmail.com>
Subject: Re: ARM/kirkwood: v3.12-rc6: kernel BUG at mm/util.c:390!
From: Ming Lei <tom.leiming@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Aaro Koskinen <aaro.koskinen@iki.fi>
Cc: Will Deacon <will.deacon@arm.com>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Simon Baatz <gmbnomis@gmail.com>, Catalin Marinas <catalin.marinas@arm.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Andrew Morton <akpm@linux-foundation.org>, FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>, Tejun Heo <tj@kernel.org>, "James E.J. Bottomley" <JBottomley@parallels.com>, Jens Axboe <axboe@kernel.dk>

On Sun, Oct 27, 2013 at 8:50 PM, Aaro Koskinen <aaro.koskinen@iki.fi> wrote:
>
> On ARM v3.9 or older kernels do not trigger this BUG, at seems it only
> started to appear with the following commit (bisected):
>
> commit 1bc39742aab09248169ef9d3727c9def3528b3f3
> Author: Simon Baatz <gmbnomis@gmail.com>
> Date:   Mon Jun 10 21:10:12 2013 +0100
>
>     ARM: 7755/1: handle user space mapped pages in flush_kernel_dcache_page

The above commit only starts to implement the helper on ARM,
but according to Documentation/cachetlb.txt, looks caller of
flush_kernel_dcache_page() should make sure the passed
'page' is a user space page.

Thanks,
-- 
Ming Lei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
