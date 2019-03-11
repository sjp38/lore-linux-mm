Return-Path: <SRS0=4gxf=RO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 85058C43381
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 14:20:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4BED62075C
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 14:20:24 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4BED62075C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arndb.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CC4838E0003; Mon, 11 Mar 2019 10:20:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C71B88E0002; Mon, 11 Mar 2019 10:20:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B87298E0003; Mon, 11 Mar 2019 10:20:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9EA278E0002
	for <linux-mm@kvack.org>; Mon, 11 Mar 2019 10:20:23 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id g17so1474833qte.17
        for <linux-mm@kvack.org>; Mon, 11 Mar 2019 07:20:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:mime-version
         :references:in-reply-to:from:date:message-id:subject:to:cc;
        bh=1Y3MYVOh5XrWx8jyQqXUdSXlpmDeQ4BYs/m6bZ/MDUg=;
        b=gCzj4STERBslM6xd47XtbYuwL59dBrHWj7LH/THHAR/G6tH80yVe5KC7JJGaxlm3Cu
         qoGut8XYQ8auBm9JfjwXmCUNwu8+zLBaNxHq4fbEbMYIxajQ4VBm3GbhyiuITEyxgyZg
         7e/SYgmhO6K66EcexdMtyb4TNzSC/Iludg6VOAxIgkYNTNskfHoYSfb9HhARGqZtoQHw
         jVALn2qc52Q72vK/GJ3RZhLhO500vU5EA+Zy6AsvWi4Lf7g4jovSD37gibZpAuZFYryF
         rnpy1TUfdmKnDWgqYnXiRHfYN34bnuC6DokoftOdfZWSUivSp+2ZeJzyCtb0pmouAXwm
         o9/A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of arndbergmann@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=arndbergmann@gmail.com
X-Gm-Message-State: APjAAAUszl3EwSDabEDdiZS7kjtTxMw+IZkc/KJLygswTJwQ2Z/1lXYN
	eszFJbM99xdx8jNz4Nl+c3EAJG0HqIv4OR53ae50jv8ZMsbbsuSHZ/IMatPtR65Ta7eCMCoMZjJ
	jJwI8TJ5bl16keTfdLw7KKnwTqK/Lu/N030dmWCjJ7VuYd+UzJST7ro4HFBo+yQV/qz2lvGR53d
	ksH0ee66daS1MCL779wTA0PTy1mKpTnsW1NfNKXk8BLA+5utFI+kcW2tW5aN5n7gblLY5CIaLdM
	eulYM5v5g12qn48dygUlL3ElxAXdi+biaFwkPgu1m6V49Sv7prJqVXW1CkxDcnXsfEfS3N980nh
	3Aqy1Ig2j3qQr5P6xICZqbl07tlGpvBn+pa0sR5FoTgNn6JaxLZUQyfF3FZIhQ+/bxcSnG3YJg=
	=
X-Received: by 2002:a05:620a:1189:: with SMTP id b9mr9266536qkk.44.1552314023432;
        Mon, 11 Mar 2019 07:20:23 -0700 (PDT)
X-Received: by 2002:a05:620a:1189:: with SMTP id b9mr9266463qkk.44.1552314022378;
        Mon, 11 Mar 2019 07:20:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552314022; cv=none;
        d=google.com; s=arc-20160816;
        b=pao5zQHomIFTxVBPOgzwK+P0vRwf0KiEgOJkohbAEYwEFjR27hdekBOzpuM6yFp4lz
         UiEF+hwBj521VdFhT2AlkeI3X1aHrzFBsFJNEZC/1ic0JzGcV6AHpiiEZxaPUdn741IW
         1xx/VWBPaoKB+N4OTmk0IklHGDiO1Emuj0LZ74F8iXD2y7tda7rDAWbGRakvRSj6u91C
         H4AuA0Vj0IPDQ6tQ+h4vC0q+LSgbYqMHNzg63HxD/PUMpN0J3uOKORc14ZtKBtcZedCW
         tVcsR/bQqf0yZPDLEGZIoCxCHulozZxpBE306ZRpdMPr40RjIeJFahto2yLXhX74Nw+h
         w5pA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version;
        bh=1Y3MYVOh5XrWx8jyQqXUdSXlpmDeQ4BYs/m6bZ/MDUg=;
        b=ivUutXWaBg8MtLTahMYHY+wmiRfvQztxpS6X/J9XqmmeqpCf5J6GjUQBT0Qh6RM5gA
         SCKUQYB4GcvDUTg2DijLRg7kxMRqYg77Pp7O+WFioLoaiuIAg1R4M0rAU7GzBnJ/mc6t
         00lPlsr6RdR7VijwgRt8AJ6Sm4awdynGqNELW8WcoNdaSpArOWvqEXCUcfZI9Zm2RZbt
         ApbMOfJnB02rhEO+403XgIV5/Fxh3ImdKlbVTVLB8YISKDfDJsB4KQY80VPi2PGlIqb0
         OLz8PNeBIs1FoK1hqsvVIQcI6r6Jc1POpk0Y27d6zacrQ4xaBOLCTAsZo0ZcerupZgII
         v0ww==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of arndbergmann@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=arndbergmann@gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j76sor3311122qke.88.2019.03.11.07.20.22
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 11 Mar 2019 07:20:22 -0700 (PDT)
Received-SPF: pass (google.com: domain of arndbergmann@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of arndbergmann@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=arndbergmann@gmail.com
X-Google-Smtp-Source: APXvYqwEkNkObrgu0s7jgf1NG7rEFN32sPNQ5/QbDS3VJOqC4lzuD8NgGXPrL7k6qfcPkHcn4TLzbDTZ2u/bnfvHI6s=
X-Received: by 2002:a05:620a:158c:: with SMTP id d12mr7991661qkk.173.1552314021843;
 Mon, 11 Mar 2019 07:20:21 -0700 (PDT)
MIME-Version: 1.0
References: <20190310183051.87303-1-cai@lca.pw> <20190311035815.kq7ftc6vphy6vwen@linux-r8p5>
 <20190311122100.GF22862@mellanox.com> <1552312822.7087.11.camel@lca.pw>
In-Reply-To: <1552312822.7087.11.camel@lca.pw>
From: Arnd Bergmann <arnd@arndb.de>
Date: Mon, 11 Mar 2019 15:20:04 +0100
Message-ID: <CAK8P3a0QB7+oPz4sfbW_g2EGZZmC=LMEnkMNLCW_FD=fEZoQPA@mail.gmail.com>
Subject: Re: [PATCH] mm/debug: add a cast to u64 for atomic64_read()
To: Qian Cai <cai@lca.pw>
Cc: Jason Gunthorpe <jgg@mellanox.com>, 
	"akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, 
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Mark Rutland <mark.rutland@arm.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Mar 11, 2019 at 3:00 PM Qian Cai <cai@lca.pw> wrote:
>
> On Mon, 2019-03-11 at 12:21 +0000, Jason Gunthorpe wrote:
> > On Sun, Mar 10, 2019 at 08:58:15PM -0700, Davidlohr Bueso wrote:
> > > On Sun, 10 Mar 2019, Qian Cai wrote:
> >
> > Not saying this patch shouldn't go ahead..
> >
> > But is there a special reason the atomic64*'s on ppc don't use the u64
> > type like other archs? Seems like a better thing to fix than adding
> > casts all over the place.
> >
>
> A bit of history here,
>
> https://patchwork.kernel.org/patch/7344011/#15495901

Ah, I had already forgotten about that discussion.

At least the atomic_long part we discussed there has been resolved now
as part of commit b5d47ef9ea5c ("locking/atomics: Switch to generated
atomic-long").

Adding Mark Rutland to Cc, maybe he has some ideas of how to use
the infrastructure he added to use consistent types for atomic64()
on the remaining 64-bit architectures.

     Arnd

