Return-Path: <SRS0=h8p8=S5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A3330C43219
	for <linux-mm@archiver.kernel.org>; Sat, 27 Apr 2019 00:32:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3B9C6206C1
	for <linux-mm@archiver.kernel.org>; Sat, 27 Apr 2019 00:32:00 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="GRQvaMYd"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3B9C6206C1
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7EEBA6B0003; Fri, 26 Apr 2019 20:31:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 79E8C6B0005; Fri, 26 Apr 2019 20:31:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 68DB96B0006; Fri, 26 Apr 2019 20:31:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id 4A93A6B0003
	for <linux-mm@kvack.org>; Fri, 26 Apr 2019 20:31:59 -0400 (EDT)
Received: by mail-io1-f70.google.com with SMTP id k17so3964917ior.4
        for <linux-mm@kvack.org>; Fri, 26 Apr 2019 17:31:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=2QgVvbOTbiGvVrZQMKzKXcCYAFgho+lUOq5aSkENeLo=;
        b=I/G214PQx3uu/ot13g1R12zi8aglpu1DLtmwDFd2rTi2tFF08J432ldFKkH2/vDb9L
         5uT445qqbb3D0/xw0h6YBUJr0XJceUxY6/I384tsVwXhvttOOG+KudQrTACFiI3vmWcd
         HjLKqRfNqvoZMSdvV/UZWpV1LD2d87QW4COF7H9Db+9PteNYPhHmO8lbL8FwBfuh/FFD
         f92kA+ZSnbPUwyYy2zRs03VBj8Yj1SSg9nDfz+en+K5HObnIM7SP8Uc5N2KSdqDlaEb1
         GJhQr7Nx5OIDxgcoZktq71Edd5IxA+f7qu7XmhiMlLlUZal6aEofi0ZBvJ03+4svv0HW
         rCZg==
X-Gm-Message-State: APjAAAWkXu8tFcjbgqN7GsGkKYuf3Svb8/9BOvNZ48yHFsj8GwsAvWG9
	9pfQd3G/q6uF5bifZe/ikXcri3noQPE/YcM3Wpi8uHQZXogwj9jv4tjxgRMFKbjaNW3HvE1Ojbf
	+HBIxNALKUuNl981W2+5nzvBKdS4jCrqSBt73LuC5MKT0iG+sA792O64C9LxOpcLe8A==
X-Received: by 2002:a5d:9d48:: with SMTP id k8mr10475176iok.194.1556325118852;
        Fri, 26 Apr 2019 17:31:58 -0700 (PDT)
X-Received: by 2002:a5d:9d48:: with SMTP id k8mr10475129iok.194.1556325118128;
        Fri, 26 Apr 2019 17:31:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556325118; cv=none;
        d=google.com; s=arc-20160816;
        b=UmbEA3U82itvoMruMRVuSN3X39pPnBRRCoo8TjaTXQpI7hHdeqVQjoSSs/V0jEeKxU
         zJkj2jNzdPB7Nw/dX12k3LUd/cJu/EH+/DtUaYvTnRpm+oE6f0cjVA++b0piaeBnOeub
         rlLVSsoxQ8f+xR/eNQx2xtj+efNh8j8ydOyY+AucAjvxo9TVjOFKczBXuTRHvmYQJs6p
         u/gXM7XBxie/Gx7KFNA+nt8AS1+pTN/MaZ+OvSIowcZTSc1soHdQ3MwXSL4kxW7VtONE
         /IB/hAJ76/tyTxPixwboBxF3BcwRDu48heJsDT3HJdzcS8eotkvgIXfpd61+fSFCHWFX
         XzzQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=2QgVvbOTbiGvVrZQMKzKXcCYAFgho+lUOq5aSkENeLo=;
        b=aJsJ8FVdnV5cbreoIQuVwoV5h/vwJoskrsp5zXSdpaB9FRHi//YYNckRvxOkUE3F0G
         8dpWuwJTUQ6p4AQh/2UM6t1yxpsHA3errvQT8Xj4DODiqC+/ydWNHsqLq5+jq5bh6AOK
         fRUqvJrR49xzK8/lIlKntnVO02KnpRNXWiSIexrc6vWZIF1BxISMfOqZ3o6trNQRTERu
         HfI/Qtg79mNQkS8Ao52oeWez7b0cYfbsiTAqlIzZR3jevBRstlpo9Bw+TtCvVU3/5KGg
         hwHB6RFUaQ884bLLjQLT52h2aggGo/02qtJHJjv5cDsuavUAgQttI75S0W8d4oc1MJN8
         xADg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=GRQvaMYd;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d11sor15123283ioq.48.2019.04.26.17.31.57
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 26 Apr 2019 17:31:58 -0700 (PDT)
Received-SPF: pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=GRQvaMYd;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=2QgVvbOTbiGvVrZQMKzKXcCYAFgho+lUOq5aSkENeLo=;
        b=GRQvaMYd89KGckS1pHpP6tqOAL11CzuNh3uCFo5i2WlGp0J7SuHKnNADOSm2OB4ga1
         PxuWwLb1xhy9Im1iGI99EpbquIzVWmLcGNM7e3CYUH7Alf6T0ZFFIxcQudgmkhZGLKNN
         2bMaFfERZx/lv/HH03TiwbuLwC7iq+y0vl56KOCQFmz1KciED9xvStf0BrZOJStCzfZG
         /VZmN3HIcJ1p1SOzDPzbG/PBoEA9aPpVQO9qIGOZ3qlnUzZHN/k1RTsoJNg5FYDJrk/d
         M7gZB46NJ7m2l/pb8WQ7kxMwSvM2gZBo+UwMaQEfa3I0bytcoZr7LSyA60XdiaM/PbLo
         0MHw==
X-Google-Smtp-Source: APXvYqyxEKGXgzDcIfMQFY3G/X2LzeY/zhXeNH2wVvrkadH4IJQYFv/j/2aH6a/YIqdaXLJMN756YoXQbe1Vzy7YiGI=
X-Received: by 2002:a5d:9a90:: with SMTP id c16mr3477445iom.295.1556325117664;
 Fri, 26 Apr 2019 17:31:57 -0700 (PDT)
MIME-Version: 1.0
References: <1556274402-19018-1-git-send-email-laoar.shao@gmail.com> <20190426112542.bf1cd9fe8e9ed7a659642643@linux-foundation.org>
In-Reply-To: <20190426112542.bf1cd9fe8e9ed7a659642643@linux-foundation.org>
From: Yafang Shao <laoar.shao@gmail.com>
Date: Sat, 27 Apr 2019 08:31:42 +0800
Message-ID: <CALOAHbDek6g7D+gK79_T-saTvT6gdbtd-ksb13BX3YqvV9TP5Q@mail.gmail.com>
Subject: Re: [PATCH] mm/page-writeback: introduce tracepoint for wait_on_page_writeback
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jan Kara <jack@suse.cz>, Michal Hocko <mhocko@suse.com>, Linux MM <linux-mm@kvack.org>, 
	shaoyafang@didiglobal.com
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Apr 27, 2019 at 2:25 AM Andrew Morton <akpm@linux-foundation.org> wrote:
>
> On Fri, 26 Apr 2019 18:26:42 +0800 Yafang Shao <laoar.shao@gmail.com> wrote:
>
> > Recently there're some hungtasks on our server due to
> > wait_on_page_writeback, and we want to know the details of this
> > PG_writeback, i.e. this page is writing back to which device.
> > But it is not so convenient to get the details.
> >
> > I think it would be better to introduce a tracepoint for diagnosing
> > the writeback details.
>
> Fair enough, I guess.
>
> > --- a/include/linux/pagemap.h
> > +++ b/include/linux/pagemap.h
> > @@ -537,15 +537,7 @@ static inline int wait_on_page_locked_killable(struct page *page)
> >
> >  extern void put_and_wait_on_page_locked(struct page *page);
> >
> > -/*
> > - * Wait for a page to complete writeback
> > - */
> > -static inline void wait_on_page_writeback(struct page *page)
> > -{
> > -     if (PageWriteback(page))
> > -             wait_on_page_bit(page, PG_writeback);
> > -}
> > -
> > +void wait_on_page_writeback(struct page *page);
> >  extern void end_page_writeback(struct page *page);
> >  void wait_for_stable_page(struct page *page);
> >
> > ...
> >
> > +/*
> > + * Wait for a page to complete writeback
> > + */
> > +void wait_on_page_writeback(struct page *page)
> > +{
> > +     if (PageWriteback(page)) {
> > +             trace_wait_on_page_writeback(page, page_mapping(page));
> > +             wait_on_page_bit(page, PG_writeback);
> > +     }
> > +}
> > +EXPORT_SYMBOL_GPL(wait_on_page_writeback);
>
> But this is a stealth change to the wait_on_page_writeback() licensing.
> I will get sad emails from developers of accidentally-broken
> out-of-tree filesystems.
>
> We can discuss changing the licensing, but this isn't the way to do it!
>

Got it.
Thanks for your explatation.

Thanks
Yafang

