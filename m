Return-Path: <SRS0=jfnU=U6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 88727C0650E
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 18:07:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 522E921479
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 18:07:37 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="B+mTkh6V"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 522E921479
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CBF866B0008; Mon,  1 Jul 2019 14:07:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C71348E0003; Mon,  1 Jul 2019 14:07:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B382A8E0002; Mon,  1 Jul 2019 14:07:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ua1-f78.google.com (mail-ua1-f78.google.com [209.85.222.78])
	by kanga.kvack.org (Postfix) with ESMTP id 915346B0008
	for <linux-mm@kvack.org>; Mon,  1 Jul 2019 14:07:36 -0400 (EDT)
Received: by mail-ua1-f78.google.com with SMTP id 3so2462099uag.14
        for <linux-mm@kvack.org>; Mon, 01 Jul 2019 11:07:36 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=lWONYKiUC+xNG+v0x99Ltv7YhSq18V7iywQoniSnrLY=;
        b=uKF3ms9z209/hzMa9stsPwQcwmAcAq+JZzp6QmiWKKQ0e0VIRmj+sG+ep1w2+mkkdk
         w25j4dI6HF/1ypN0sBse2RTwWABsNpISuTbYviT+m3G+TWVFeR5LwOMUmBoPV+3+xNPm
         XxfP0GwSbfW9WiKTBhBCBl2A+UZHFOF/KEWMozbVyz1naShCHuFVuMFLSBWNcvqgmgYb
         09OnQAUUzPbl2T/F7G2Cgk7EPpQFrucK/Jb/g+wDX3r4JyRWI54CfQ/XhXb23l99/WP0
         ttFDVehQkYFbDhFudpci3Id6ehZ4LqfKF7pZxgFySSzpvXoLoC28Q070BeCBN3+zAJAc
         9LPw==
X-Gm-Message-State: APjAAAW/HTca5UUEHCvB0BDW0crHt1bRzM9hEV36kR3y7fbi5jqZUx2/
	dPAxVbcpJeKyqQ2LbeWXN/WcUhsUk0LaxeyxuQcovZzLS/XFHIdD1KrRzZyd8Af/i08ctNcZ5f/
	0hpYwpj5KsPWSIAg/2AKCFC9+43y23Uc63v6Bfe7xy9K6APTN83BCU4bG4tnE9AmDHA==
X-Received: by 2002:a67:1a81:: with SMTP id a123mr15311603vsa.162.1562004456391;
        Mon, 01 Jul 2019 11:07:36 -0700 (PDT)
X-Received: by 2002:a67:1a81:: with SMTP id a123mr15311571vsa.162.1562004455847;
        Mon, 01 Jul 2019 11:07:35 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562004455; cv=none;
        d=google.com; s=arc-20160816;
        b=BRjPDgvRZAkObmHai7SsiY6gtzryQ3/lsl4jYQ+YxQletU+FqF5lzhpIgFhRM8KFwY
         x63xuRUOE0UZpZmOIoUrK4sD4cRXZi5ASnyIGrAwSa7tN1i2B9zYqWFJA0DkIY67hqaG
         TZ9YoTkmSX7bEpwvXEBA/2hxQJ9AgiEcBe/7O9scrBgH2ZlbfMbb6n7ySTc27XNTOLre
         uflRXAoT8AHibMPdhnQ6OXwpcgUfQN3H4VTjKQenCZlGELgTIfuWwyn/AYu04TPzD6X9
         mmGa1Tvm4tnzElKyZQObsXdMI08sEO5BeRw01YSPo4j/ZI8PB8aWKZQJPp2OrLW7luLA
         2rFw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=lWONYKiUC+xNG+v0x99Ltv7YhSq18V7iywQoniSnrLY=;
        b=Iy2ZF4ONLuTkHOjZBgPn8fmjm8Tk86g56EiKKrAvqT8gpia3YI9srLmG3DKWa18nTA
         bdpyTtYt7wjudmv4EbodFZoLkdiPZvcaVUZBcfe6seco/zFGi2YGbLjs/Vo0Evrcf2Ly
         EKu+oG49xqyqE9v3iRzk5njYARaMqm9IhDarp/JX8FMJ/0wGfn9UJn/X2F+6R4horLqK
         ASBwSB+ZRFAceTZCyEr6rk3w1nFpOQ7I+DM9m1xLhgo4X/dYTVC5o0No7ETzx88TtDud
         mQmhstc+QlJ0nmJHlVG273khLKZaFRkTvx9xMPUy0eYxQ5pC+74qnX0s0jqdG7sLWhpA
         UCtw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=B+mTkh6V;
       spf=pass (google.com: domain of pankajssuryawanshi@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=pankajssuryawanshi@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l190sor3178680vkl.34.2019.07.01.11.07.35
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 01 Jul 2019 11:07:35 -0700 (PDT)
Received-SPF: pass (google.com: domain of pankajssuryawanshi@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=B+mTkh6V;
       spf=pass (google.com: domain of pankajssuryawanshi@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=pankajssuryawanshi@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=lWONYKiUC+xNG+v0x99Ltv7YhSq18V7iywQoniSnrLY=;
        b=B+mTkh6VPC/HVnQ/2aPY6tcq2AbxaF1Ieqvp+5l4ijk9/nrIuBAJwhSsYqD/Lkik4W
         x+k4pLd8gMGKtMhht3Fll8Z+BbzMOMLQb/FqBjxPYlLYt2xkivfIRECPwxqWvzkYSwms
         q78SVjZsa2BdoiPBS9C0KhLfSN7Sh4cMPnid6WAwR0eh962wv/tCSUypcmIQJbluwuBd
         pqNgcsOw/e/yvw1i7IGN1XsbMx3m2art1A/7FZf8nLPSrCuoPP/PtgwZ2stipavisg9I
         t2MwBx7coZG+aEcR35I2h4h1t/ZprqqwTewkKoYWgFEBsg6qwTAj0pnUZtGPsqbMR/tb
         PXqg==
X-Google-Smtp-Source: APXvYqwRJwKQv7q3x+bK0rhEHYsq3B5RUxQ/uPaJ6fmEtHv4AFhRjDw9aFEkw+axhgsNwnA0UOwULvb0Zrsqeu6li5Q=
X-Received: by 2002:a1f:2896:: with SMTP id o144mr3222112vko.73.1562004455408;
 Mon, 01 Jul 2019 11:07:35 -0700 (PDT)
MIME-Version: 1.0
References: <CACDBo564RoWpi8y2pOxoddnn0s3f3sA-fmNxpiXuxebV5TFBJA@mail.gmail.com>
 <CACDBo55GfomD4yAJ1qaOvdm8EQaD-28=etsRHb39goh+5VAeqw@mail.gmail.com>
 <20190626175131.GA17250@infradead.org> <CACDBo56fNVxVyNEGtKM+2R0X7DyZrrHMQr6Yw4NwJ6USjD5Png@mail.gmail.com>
 <c9fe4253-5698-a226-c643-32a21df8520a@arm.com> <CACDBo57CcYQmNrsTdMbax27nbLyeMQu4kfKZOzNczNcnde9g3Q@mail.gmail.com>
 <0725b9aa-0523-daef-b4ff-7e2dd910cf3c@arm.com>
In-Reply-To: <0725b9aa-0523-daef-b4ff-7e2dd910cf3c@arm.com>
From: Pankaj Suryawanshi <pankajssuryawanshi@gmail.com>
Date: Mon, 1 Jul 2019 23:37:24 +0530
Message-ID: <CACDBo56taTYwSvzH9ZPbTzPM6gMzknki94QsAoo+oNkyCLkTMA@mail.gmail.com>
Subject: Re: DMA-API attr - DMA_ATTR_NO_KERNEL_MAPPING
To: Robin Murphy <robin.murphy@arm.com>
Cc: Christoph Hellwig <hch@infradead.org>, linux-mm@kvack.org, iommu@lists.linux-foundation.org, 
	linux-kernel@vger.kernel.org, Vlastimil Babka <vbabka@suse.cz>, 
	Michal Hocko <mhocko@kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jul 1, 2019 at 11:24 PM Robin Murphy <robin.murphy@arm.com> wrote:
>
> On 01/07/2019 18:47, Pankaj Suryawanshi wrote:
> >> If you want a kernel mapping, *don't* explicitly request not to have a
> >> kernel mapping in the first place. It's that simple.
> >>
> >
> > Do you mean do not use dma-api ? because if i used dma-api it will give you
> > mapped virtual address.
> > or i have to use directly cma_alloc() in my driver. // if i used this
> > approach i need to reserved more vmalloc area.
>
> No, I mean just call dma_alloc_attrs() normally *without* adding the
> DMA_ATTR_NO_KERNEL_MAPPING flag. That flag means "I never ever want to
> make CPU accesses to this buffer from the kernel" - that is clearly not
> the case for your code, so it is utterly nonsensical to still pass the
> flag but try to hack around it later.


Actually my use case is that i want virtual mapping only when i will
play video as my vpu/gpu driver is design like that.
and  i am using 32-bit so virtual memory is splitted as 3G/1G so dont
have enough memory for all the time to mapped with kernel space.

Lets say i am allocating 400MB for driver but i want only 30MB for
virtual mapping (not everytime) that is the case.
>
>
> Robin.

