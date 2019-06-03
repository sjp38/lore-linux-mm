Return-Path: <SRS0=ZkFZ=UC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 76596C04AB5
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 19:19:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 396C92719B
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 19:19:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="B6Luh7lF"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 396C92719B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C8FAA6B026B; Mon,  3 Jun 2019 15:19:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C401B6B026C; Mon,  3 Jun 2019 15:19:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B558F6B0270; Mon,  3 Jun 2019 15:19:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8096A6B026B
	for <linux-mm@kvack.org>; Mon,  3 Jun 2019 15:19:38 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id b127so14283946pfb.8
        for <linux-mm@kvack.org>; Mon, 03 Jun 2019 12:19:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=y1POYuY5yv6TKMl+TVizfTG3p/FI2fRpGzaKg8qUjGU=;
        b=PMdQ228KuTyvZtLXyunYIFGnvbCUBt8iEmlMp3ZB69Ky7ylHQQrmjkQLS6bulZ5nEP
         9trKLlsJW+qaz3GOaFQDLObTN64pB7QMhauH0RbwqbIdV+pUIoDUtKhLcZS4aWU6vdoa
         MQQK2gXZ/kwWLrwUy2838RCi2olG8oEcUGXHERtnURYnuqAcQC5kopHDMOxm6vXPoSla
         pBIXTxQoP0Mv2Q+olRPJ5W4v0X4obJT9AXCXit0OFhGImbwtkk6UMVolBeCTvZr4FHbC
         iBuHxi372pi8bUG2qaqn3rx76TwIYljibUNw7ZQYdJzK3sz+K6h0VM389iQ4mQ4N7hyU
         dx9Q==
X-Gm-Message-State: APjAAAU7mbxbrGh1Ggmo6c/rsZ6f8crapkx+2PwZsWwmffL92aZYm9LU
	ixQK9EfxpZcJ4N8SXcNR86U3i9mu9uXCjRRhrNBbx8hfnVeye2R9HCTsly2LGiuH45RDh/aSb8h
	/Ecsg3C+t0xIeN8+VG2gUlyvAZxqWg0PDpyV5jX/8SWXGuItvc0OAI+EddRIbuCIopQ==
X-Received: by 2002:a65:4c07:: with SMTP id u7mr29342301pgq.93.1559589578151;
        Mon, 03 Jun 2019 12:19:38 -0700 (PDT)
X-Received: by 2002:a65:4c07:: with SMTP id u7mr29342213pgq.93.1559589577340;
        Mon, 03 Jun 2019 12:19:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559589577; cv=none;
        d=google.com; s=arc-20160816;
        b=rT3YCZA/jORvucJaxHEZDFjseGtCUtKdjTCEKNUIKuu8MxhFqMRkPzTnGswJKgA78m
         s4tj05phn05Frv1+WdHMBgnIwi5iEiexRLAdRoKwpurGQZYigQjNSTYR2MO2y4t4BIkf
         lv/MS6EY0gHMnS2xBamWEAGnzvd8KZBm1+N+i6wyZoFqLZsDyUkOxZzEFqGeDBLaA507
         zduVFS3mhOcM8g5wRjlUMCAIYk/EquzwLxg0m89FuV0JWXKAhhXGjCmLCs3iTHKw4yn2
         94o2r+zuoDvSA+RyRuyzGvfFUeZtBMNLpckJ0sAhqixdITtPnu4ZtQg/ySIUofleocEw
         gEhQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=y1POYuY5yv6TKMl+TVizfTG3p/FI2fRpGzaKg8qUjGU=;
        b=hv+XAWy8S3XNBR+inAbpDCBYsX5EaUanFc5tKcRCbHBwFAnSXMheA9kcIOnXcWwMNJ
         s0+m95Q3qfTaH2zas0yYFsBg7l3BJnENxIOA7uEYkAUuLOZgGDa2bzNllpFTkT2KqxLy
         yFHB0L4c211XTxsSWnFTGhltb31U8UYx50T0BW1dT2uRI5mcfMiIdQNYza1yWtfJ+nJ1
         ZXlkwr0gRT1YtVsbVA8mjv+KanO5crxbPEW+m2EakQS9Zoc1KKRFA4CTG2DfebfTWOfF
         mYblnTLGQ54Y4As3hXHxUjDBPs0qr3+ZSMCitiB9f4WSSyn4jbPOKLezS/6bt9gIvPXi
         f1Zw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=B6Luh7lF;
       spf=pass (google.com: domain of dexuan.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dexuan.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c2sor15693512pgd.67.2019.06.03.12.19.37
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 03 Jun 2019 12:19:37 -0700 (PDT)
Received-SPF: pass (google.com: domain of dexuan.linux@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=B6Luh7lF;
       spf=pass (google.com: domain of dexuan.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dexuan.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=y1POYuY5yv6TKMl+TVizfTG3p/FI2fRpGzaKg8qUjGU=;
        b=B6Luh7lFrEGKMS0YaCVBv8YPdG1mQ6kipZMlOOIWg7PtGkDH5BzB5dbwoj+XazEPrQ
         gW4udVF7MtZdA8ZcHF04cxCgpkQ1Bq+DjrhRoEue0Qwkffa0UKyhVn5PZvC7IVcn+W0q
         jqKBgtw0etiOYNrWWIaxWusHOxiXee9ERSe2jvi8PwAE8XbNewSlVh9Po8LFTzZu1W4g
         URBPlLPp80M14E+DSIZklLmwiFd9NcKnayxknqEJMYSwethFJ+YjK+IXhoO/vhD5bTaY
         MiuHszmiwHy9XAa3KIJdZDvcPAXfPUzPE7AqYAr8j2favgR6jg2YNM4ih6TJ08VXIxUL
         fEMA==
X-Google-Smtp-Source: APXvYqyxiiO0bsYaQbImkXitEOhDYoQvgmXhCfueX9MbGIWAyuoj8TggJ5ZITYx8TlJOta8cZTfOSJeb38kdARJg9LI=
X-Received: by 2002:a63:81c6:: with SMTP id t189mr14722226pgd.293.1559589576950;
 Mon, 03 Jun 2019 12:19:36 -0700 (PDT)
MIME-Version: 1.0
References: <CAJKOXPcTVpLtSSs=Q0G3fQgXYoVa=kHxWcWXyvS13ie73ByZBw@mail.gmail.com>
 <20190603135939.e2mb7vkxp64qairr@pc636> <CAJKOXPdczUnsaBeXTuutZXCQ70ejDT68xnVm-e+SSdLZi-vyCA@mail.gmail.com>
 <20190604003153.76f33dd2@canb.auug.org.au> <CAJKOXPed=npnfk0H2WUDityHg5cPLH_zwShyRd+B2RS8h6C7SQ@mail.gmail.com>
In-Reply-To: <CAJKOXPed=npnfk0H2WUDityHg5cPLH_zwShyRd+B2RS8h6C7SQ@mail.gmail.com>
From: Dexuan-Linux Cui <dexuan.linux@gmail.com>
Date: Mon, 3 Jun 2019 12:19:25 -0700
Message-ID: <CAA42JLZa4OgiEYk7d+gM9pu-gvVbOfQj3-VfEb8kvx538-atew@mail.gmail.com>
Subject: Re: [BUG BISECT] bug mm/vmalloc.c:470 (mm/vmalloc.c: get rid of one
 single unlink_va() when merge)
To: Krzysztof Kozlowski <krzk@kernel.org>
Cc: Stephen Rothwell <sfr@canb.auug.org.au>, Uladzislau Rezki <urezki@gmail.com>, 
	Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, linux-mm@kvack.org, 
	Marek Szyprowski <m.szyprowski@samsung.com>, 
	"linux-samsung-soc@vger.kernel.org" <linux-samsung-soc@vger.kernel.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Hillf Danton <hdanton@sina.com>, 
	Thomas Gleixner <tglx@linutronix.de>, Tejun Heo <tj@kernel.org>, Andrei Vagin <avagin@gmail.com>, 
	Dexuan Cui <decui@microsoft.com>, v-lide@microsoft.com
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 3, 2019 at 7:37 AM Krzysztof Kozlowski <krzk@kernel.org> wrote:
>
> On Mon, 3 Jun 2019 at 16:32, Stephen Rothwell <sfr@canb.auug.org.au> wrote:
> >
> > Hi Krzysztof,
> >
> > On Mon, 3 Jun 2019 16:10:40 +0200 Krzysztof Kozlowski <krzk@kernel.org> wrote:
> > >
> > > Indeed it looks like effect of merge conflict resolution or applying.
> > > When I look at MMOTS, it is the same as yours:
> > > http://git.cmpxchg.org/cgit.cgi/linux-mmots.git/commit/?id=b77b8cce67f246109f9d87417a32cd38f0398f2f
> > >
> > > However in linux-next it is different.
> > >
> > > Stephen, any thoughts?
> >
> > Have you had a look at today's linux-next?  It looks correct in
> > there.  Andrew updated his patch series over the weekend.
>
> Yes, I am looking at today's next. Both the source code and the commit
> 728e0fbf263e3ed359c10cb13623390564102881 have wrong "if (merged)" (put
> in wrong hunk).
>
> Best regards,
> Krzysztof

FYI, we also see the issue in our x86 VM running on Hyper-V.

Thanks,
Dexuan

