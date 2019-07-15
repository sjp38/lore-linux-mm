Return-Path: <SRS0=FHqE=VM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 49746C76195
	for <linux-mm@archiver.kernel.org>; Mon, 15 Jul 2019 18:05:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 04BAF206B8
	for <linux-mm@archiver.kernel.org>; Mon, 15 Jul 2019 18:05:13 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="PwR1EtCr"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 04BAF206B8
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7DE2A6B0003; Mon, 15 Jul 2019 14:05:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 766AB6B0005; Mon, 15 Jul 2019 14:05:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 607AE6B0006; Mon, 15 Jul 2019 14:05:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3E1F16B0003
	for <linux-mm@kvack.org>; Mon, 15 Jul 2019 14:05:13 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id t124so14436097qkh.3
        for <linux-mm@kvack.org>; Mon, 15 Jul 2019 11:05:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=oQ4K7j9A7KZ0nbwdC0yOxg3aR/aRtjl8qzNQbwacYqI=;
        b=d8PSSKei1zfRh5l1eQeXsY9ejPJQAHsX2GyB5/3zKUqkKAH4EpzHe2kRD46221MjE6
         dR4XMD1FMTe6uY8UkDJERg/7UUTCZMOK5CzAQyY6U4aM2YZbucgwmBj7R1LSPESBoRVu
         1vpAn4FJzkyo/SwD2gqEBlBkjj2+mCNOLzRCMrvw5Fm8H0I7CR6tc+WR02wsd1rr6b11
         FUNHqMFjR43yFdwM04tthwbwb3Dj01Eig/DRO1JQjV5pLAhL1Kuve9NFSymiIQj1PLbm
         n2L9L/62Bz4wD9Q8OhHCya29DCWEtrnLtv466ILFHKjrSoOCxAWRwMAnzzcDf5m6gVJP
         dPig==
X-Gm-Message-State: APjAAAUC5DzEV3v1vB25iUXIlQxetrzsjdRwWAo8ulkZ9Teh/P4vhY+R
	oV7Fx89dwagJF3Ar/sZ5lmgb5f6Eq/HpV8QXxF5lUZqrfPqleXzAax6xyfqcn/q9WFH5sSv3dqL
	QWZOmU3ux3xE01OJEf8ztkDpj68+iVksYwe4Z5XSs+loZEo4x4OoiElSIOtvCREaRLw==
X-Received: by 2002:a0c:d01b:: with SMTP id u27mr20336426qvg.88.1563213913025;
        Mon, 15 Jul 2019 11:05:13 -0700 (PDT)
X-Received: by 2002:a0c:d01b:: with SMTP id u27mr20336367qvg.88.1563213912347;
        Mon, 15 Jul 2019 11:05:12 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563213912; cv=none;
        d=google.com; s=arc-20160816;
        b=0J3UObsq80RTa5HlTsbQUYM/yFAozP9tdUmPmFFSt6gBB0WmFaFGo8wfbpc8ExnxxP
         IS2i+K2/iTqub7s5U+nGC8QMk7WoywHIqdUXZ5zVU2JUkDS1xzOA+y/zcI/5zahTOKye
         NavNMzyy3jGcVJroZP6py+5kSqQJZx1FTzzC/ORwNPT6cLEOliqEWANK/PDXBjLcX2qT
         tGJip9MepqYUuro7EsVkfDmRoy1kxGtcGLAhxYDxlzveFhV7SXqczOmFpS//rSANnvb+
         GSXR8TwdB1IZBlWXdm31r3sEst2l5R0/gYFKlCmBpVW9G+EQJf8iuZMkhQG5K2qg8oGI
         Nh7A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=oQ4K7j9A7KZ0nbwdC0yOxg3aR/aRtjl8qzNQbwacYqI=;
        b=HrV4mFruBbAr31QJSeEdxqw1HsRrpUKglVol9s5gEt8z2kgCRKBr/K95xEwXOmmTNp
         eV56MYIAXH02x5cick3+fPTSuhg//nG2VjZisOnc+0maKTWNA8ivlPwZDuh42E9LWTdA
         ddFQrnWSdwzeE27mYWDzAcfjh3B73XaaH7yTxTDhXr2GFyZB14AeBEU+mc5H2BvgLFYg
         0AQEn+EmB2/t1eEGrXXy9m6adhphFFZvx7c9u8FIaD2i0kVXHjfKLQbpsN/LeSUfw77M
         2Fx5RzHIZKNB2JDHjyX1a4U8m1xiQJ13MNlIkHmfCbqmWzDfKnKHlsFMP+ZmV9AGL0Mz
         et1A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=PwR1EtCr;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k26sor16483882qvc.30.2019.07.15.11.05.12
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 15 Jul 2019 11:05:12 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=PwR1EtCr;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=oQ4K7j9A7KZ0nbwdC0yOxg3aR/aRtjl8qzNQbwacYqI=;
        b=PwR1EtCrURwrbo7TpqHuOvhX3LIycbjKkBb4iZ6+YCuC60ErzFmtlkMrRo9GfbX0ep
         bOPWg9HzO0UREAz1sjKJFk3TljxpYwzvCkuA0H8lubNfJCvY2ASmYBnxIKBySJaciMh9
         IWCtA6vd68VwBDPGY07TF40sWdRGtt46+KtuhJCf3Dkv+hk0kDlTClc7v0FgkXnm9Td6
         i1yxqpRiKWqC8epriEnPtS7rhozNGFmNJhWNANw7o2ytOh0Tu6qDWMUojtH/q6UpZnph
         8NNcHVz4Emezex9wQTSbQUH4N9LwFgHNyRTzxKvxiscGagPT01BlLq6kMX4xBhj5skGH
         0P7g==
X-Google-Smtp-Source: APXvYqzV3YFI+MpwRBSBS9L25rk8A7XfyA1gAg9YfhwBzidc1Vfy+exQVLzBpqEA6++D83b7IWLy1g==
X-Received: by 2002:a05:6214:3a5:: with SMTP id m5mr19973542qvy.7.1563213911969;
        Mon, 15 Jul 2019 11:05:11 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id l80sm8277974qke.24.2019.07.15.11.05.11
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 15 Jul 2019 11:05:11 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hn5La-0001zV-SL; Mon, 15 Jul 2019 15:05:10 -0300
Date: Mon, 15 Jul 2019 15:05:10 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Andrey Konovalov <andreyknvl@google.com>
Cc: Linux ARM <linux-arm-kernel@lists.infradead.org>,
	Linux Memory Management List <linux-mm@kvack.org>,
	LKML <linux-kernel@vger.kernel.org>, amd-gfx@lists.freedesktop.org,
	dri-devel@lists.freedesktop.org, linux-rdma@vger.kernel.org,
	linux-media@vger.kernel.org, kvm@vger.kernel.org,
	"open list:KERNEL SELFTEST FRAMEWORK" <linux-kselftest@vger.kernel.org>,
	Vincenzo Frascino <vincenzo.frascino@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Kees Cook <keescook@chromium.org>,
	Yishai Hadas <yishaih@mellanox.com>,
	Felix Kuehling <Felix.Kuehling@amd.com>,
	Alexander Deucher <Alexander.Deucher@amd.com>,
	Christian Koenig <Christian.Koenig@amd.com>,
	Mauro Carvalho Chehab <mchehab@kernel.org>,
	Jens Wiklander <jens.wiklander@linaro.org>,
	Alex Williamson <alex.williamson@redhat.com>,
	Leon Romanovsky <leon@kernel.org>,
	Luc Van Oostenryck <luc.vanoostenryck@gmail.com>,
	Dave Martin <Dave.Martin@arm.com>,
	Khalid Aziz <khalid.aziz@oracle.com>, enh <enh@google.com>,
	Christoph Hellwig <hch@infradead.org>,
	Dmitry Vyukov <dvyukov@google.com>,
	Kostya Serebryany <kcc@google.com>,
	Evgeniy Stepanov <eugenis@google.com>,
	Lee Smith <Lee.Smith@arm.com>,
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>,
	Jacob Bramley <Jacob.Bramley@arm.com>,
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>,
	Robin Murphy <robin.murphy@arm.com>,
	Kevin Brodsky <kevin.brodsky@arm.com>,
	Szabolcs Nagy <Szabolcs.Nagy@arm.com>,
	Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCH v18 11/15] IB/mlx4: untag user pointers in
 mlx4_get_umem_mr
Message-ID: <20190715180510.GC4970@ziepe.ca>
References: <cover.1561386715.git.andreyknvl@google.com>
 <ea0ff94ef2b8af12ea6c222c5ebd970e0849b6dd.1561386715.git.andreyknvl@google.com>
 <20190624174015.GL29120@arrakis.emea.arm.com>
 <CAAeHK+y8vE=G_odK6KH=H064nSQcVgkQkNwb2zQD9swXxKSyUQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAAeHK+y8vE=G_odK6KH=H064nSQcVgkQkNwb2zQD9swXxKSyUQ@mail.gmail.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jul 15, 2019 at 06:01:29PM +0200, Andrey Konovalov wrote:
> On Mon, Jun 24, 2019 at 7:40 PM Catalin Marinas <catalin.marinas@arm.com> wrote:
> >
> > On Mon, Jun 24, 2019 at 04:32:56PM +0200, Andrey Konovalov wrote:
> > > This patch is a part of a series that extends kernel ABI to allow to pass
> > > tagged user pointers (with the top byte set to something else other than
> > > 0x00) as syscall arguments.
> > >
> > > mlx4_get_umem_mr() uses provided user pointers for vma lookups, which can
> > > only by done with untagged pointers.
> > >
> > > Untag user pointers in this function.
> > >
> > > Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
> > >  drivers/infiniband/hw/mlx4/mr.c | 7 ++++---
> > >  1 file changed, 4 insertions(+), 3 deletions(-)
> >
> > Acked-by: Catalin Marinas <catalin.marinas@arm.com>
> >
> > This patch also needs an ack from the infiniband maintainers (Jason).
> 
> Hi Jason,
> 
> Could you take a look and give your acked-by?

Oh, I think I did this a long time ago. Still looks OK. You will send
it?

Reviewed-by: Jason Gunthorpe <jgg@mellanox.com>

Jason

