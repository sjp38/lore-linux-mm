Return-Path: <SRS0=7Cer=U3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A931FC4321A
	for <linux-mm@archiver.kernel.org>; Fri, 28 Jun 2019 16:29:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 61DB22083B
	for <linux-mm@archiver.kernel.org>; Fri, 28 Jun 2019 16:29:36 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="qtBdXq0X"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 61DB22083B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 05D248E0003; Fri, 28 Jun 2019 12:29:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 00E5B8E0002; Fri, 28 Jun 2019 12:29:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E181C8E0003; Fri, 28 Jun 2019 12:29:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vs1-f69.google.com (mail-vs1-f69.google.com [209.85.217.69])
	by kanga.kvack.org (Postfix) with ESMTP id C0D148E0002
	for <linux-mm@kvack.org>; Fri, 28 Jun 2019 12:29:35 -0400 (EDT)
Received: by mail-vs1-f69.google.com with SMTP id j186so2054495vsc.11
        for <linux-mm@kvack.org>; Fri, 28 Jun 2019 09:29:35 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=bKHVDCcXPiE05peODNTqmlPBXDlbWR2UFo/K1we8S9c=;
        b=BTpiZMBFnDgftbCWD4S1rmKZ4Cdp035FjACzfR9KHMhQxdpys7S0B3xGdYt1L/v2ae
         zd5PUasHSWdqhYg72H4BwBH1K5YmDw4KEWnSDBTZ8SJIf51zYmf4ZQp9oWTXRxY69EFX
         RXe1mX2ms4Ulbst7ctZ6qpTl5JRdXUD8cMsXbRFG+y7wgg4HGqNE8La6cGFv+nPywLvB
         5x3gZMclpq9ozZ0Lz27zoYjkmQ+mIPIJe62/otzG7JFprJNR7p24xY+7ZnWP42QbwjDi
         sylKGWscyl/2EazgiEJTt8XFJ64btgDFDyN94TBqImZIA0ipk7Vn4xF92VJnLdcl3TZP
         lRZQ==
X-Gm-Message-State: APjAAAUKe7JXLfDswQ7sWl2TfEb7yKS5Yvd4U5pdeBeHV23esIDCHyST
	+wnmCedcfik3PAVQ7X49WmJ1/JZLp34XBsgGRpJ//3RpHoJQ8vWRrd4oywHphmFgZ5QAp1R5szY
	h8bSx2b0o6m4n32wwS2Fmg4CwNPpooLfcbbqW4GX/9YDM+pPWJsQHVHvlXpTrrkcxYA==
X-Received: by 2002:a9f:2e0e:: with SMTP id t14mr3523465uaj.119.1561739375429;
        Fri, 28 Jun 2019 09:29:35 -0700 (PDT)
X-Received: by 2002:a9f:2e0e:: with SMTP id t14mr3523432uaj.119.1561739374883;
        Fri, 28 Jun 2019 09:29:34 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561739374; cv=none;
        d=google.com; s=arc-20160816;
        b=u4reFbbxMw7rMwD13zhGiTeYqO7/Em+Gkl0pewyuGQ8O714DMkVPYR9Aa9S04GLoii
         CoJGc/YPSb72SsMIoEUnZrQPJ0OLbOJw8MSQCUSC6B75b6a2w3NGulxx2DfamRCjMAJl
         ibqbHAU9Ban0GFWAkeGZES/ZsFZVj36rm3H/ta8GU3fj4/JHI1tGan2RNNz/Vi+8EZjE
         7/aiQPXzPfz4TPV4YtGaSC6/0mm1kCEVa/+PmBf8w2EL5a6QP2Z7NkQByPvIi3YYA8kN
         pTQdk1Iuy5c811zT5K8wWoGzx15UlxfJEnmqPCbb6RfIHFwoNUNjCWthNtXgtlWD4wsu
         dreA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=bKHVDCcXPiE05peODNTqmlPBXDlbWR2UFo/K1we8S9c=;
        b=n9gF9bd0ae4MbwQZXdAKTVfarbPknQazsOh80t4BSM9HIx9wuK+ISdQn7sjH2JQvfY
         CoHVN2uKOfC5HReRBKLJOAsKkscfAI+BjrlmGg/Q6JuQegMHlcZHP9eIEKGL07FeJ7uR
         I8BpY8rg1YpZMmK4KCIQlkJyHrV80r3o1FNA7xbZ2HiYcRq6voAkSFpyWnPRgBtAKD1K
         F7QAujj/oZeD1+/SWp4zg+uG3lmcDoIbBYj30J4cs00wA70TBv1Eby9y32EMaSQggkWi
         E/PcXkYntpmObY/75Dgujswpol3vGkC8bImsX19CgRZzBni/BoPO9zOcN1hwOOQ7lO/e
         76Kw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=qtBdXq0X;
       spf=pass (google.com: domain of pankajssuryawanshi@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=pankajssuryawanshi@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c23sor1468926uaq.59.2019.06.28.09.29.34
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 28 Jun 2019 09:29:34 -0700 (PDT)
Received-SPF: pass (google.com: domain of pankajssuryawanshi@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=qtBdXq0X;
       spf=pass (google.com: domain of pankajssuryawanshi@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=pankajssuryawanshi@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=bKHVDCcXPiE05peODNTqmlPBXDlbWR2UFo/K1we8S9c=;
        b=qtBdXq0XLD8BVGshscddAtfmjvkM+6vEB2fci5h7bCZ4QPj0ESqwfWXwFxyvi/bgia
         kVGVlU7Y0ZWBE++KzRXh3A/3Gu2lZ6RKr5PHf9WlBNxfOS/5/Wksj1RUTJ3ZKca12D/4
         ANk8oVjWBNAZ/5GUBCJqzKYf2rE9XPxBdJRUy5pynMcNABwPp+fWCNWF5kWfpv7cLuLn
         vsaPOk1Yunt+fZc8Mu0zuBdVCGK6Qg2DiX1apJzz/2NKU4KK3bNQNLYP9dAJ/JRswrfv
         VGLqYs5PjFjamcmAkCZV8ESowBAs/QIf/5reFutLohfqT+K9aTmiLimgGzHTcp7qqn+t
         Hmrw==
X-Google-Smtp-Source: APXvYqydPIyXvwKpPrZ8ZcD8HVaLsCpFTpEJpv8to51zjquBaIgU+1LKqb+TWKruUHtHlmYHoUFwJbecHP4cb9e2WiU=
X-Received: by 2002:ab0:67d6:: with SMTP id w22mr339818uar.68.1561739374480;
 Fri, 28 Jun 2019 09:29:34 -0700 (PDT)
MIME-Version: 1.0
References: <CACDBo564RoWpi8y2pOxoddnn0s3f3sA-fmNxpiXuxebV5TFBJA@mail.gmail.com>
 <CACDBo55GfomD4yAJ1qaOvdm8EQaD-28=etsRHb39goh+5VAeqw@mail.gmail.com> <20190626175131.GA17250@infradead.org>
In-Reply-To: <20190626175131.GA17250@infradead.org>
From: Pankaj Suryawanshi <pankajssuryawanshi@gmail.com>
Date: Fri, 28 Jun 2019 21:59:25 +0530
Message-ID: <CACDBo56fNVxVyNEGtKM+2R0X7DyZrrHMQr6Yw4NwJ6USjD5Png@mail.gmail.com>
Subject: Re: DMA-API attr - DMA_ATTR_NO_KERNEL_MAPPING
To: Christoph Hellwig <hch@infradead.org>
Cc: linux-mm@kvack.org, Michal Hocko <mhocko@kernel.org>, linux-kernel@vger.kernel.org, 
	Vlastimil Babka <vbabka@suse.cz>, iommu@lists.linux-foundation.org
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jun 26, 2019 at 11:21 PM Christoph Hellwig <hch@infradead.org> wrote:
>
> On Wed, Jun 26, 2019 at 10:12:45PM +0530, Pankaj Suryawanshi wrote:
> > [CC: linux kernel and Vlastimil Babka]
>
> The right list is the list for the DMA mapping subsystem, which is
> iommu@lists.linux-foundation.org.  I've also added that.
>
> > > I am writing driver in which I used DMA_ATTR_NO_KERNEL_MAPPING attribute
> > > for cma allocation using dma_alloc_attr(), as per kernel docs
> > > https://www.kernel.org/doc/Documentation/DMA-attributes.txt  buffers
> > > allocated with this attribute can be only passed to user space by calling
> > > dma_mmap_attrs().
> > >
> > > how can I mapped in kernel space (after dma_alloc_attr with
> > > DMA_ATTR_NO_KERNEL_MAPPING ) ?
>
> You can't.  And that is the whole point of that API.

1. We can again mapped in kernel space using dma_remap() api , because
when we are using  DMA_ATTR_NO_KERNEL_MAPPING for dma_alloc_attr it
returns the page as virtual address(in case of CMA) so we can mapped
it again using dma_remap().

2. We can mapped in kernel space using vmap() as used for ion-cma
https://github.com/torvalds/linux/tree/master/drivers/staging/android/ion
 as used in function ion_heap_map_kernel().

Please let me know if i am missing anything.

