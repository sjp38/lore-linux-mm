Return-Path: <SRS0=pbvW=UU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CE501C43613
	for <linux-mm@archiver.kernel.org>; Fri, 21 Jun 2019 14:56:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8F087208C3
	for <linux-mm@archiver.kernel.org>; Fri, 21 Jun 2019 14:56:11 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="gYgr6uvq"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8F087208C3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2B44A6B0005; Fri, 21 Jun 2019 10:56:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 264E48E0003; Fri, 21 Jun 2019 10:56:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 154AB8E0001; Fri, 21 Jun 2019 10:56:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id EC3946B0005
	for <linux-mm@kvack.org>; Fri, 21 Jun 2019 10:56:10 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id g56so8165168qte.4
        for <linux-mm@kvack.org>; Fri, 21 Jun 2019 07:56:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:subject:from:to:cc
         :date:in-reply-to:references:mime-version:content-transfer-encoding;
        bh=Y2jSEi8sxGbtd9XqToa9O5z6ODlBTruzPgaOmq/wTns=;
        b=V75E/YETRdJSPGYj/5MQHCn42ZOokgoErjerdaBIQDU3hLn7Vcm1WcQ/T7/HGd4ypL
         n7In8vz5GTBfJX4QN8nZNpKQFr40AapmVCNoYOVRmuXNilVM7VUUK77VoyvBwkPqCOv2
         rniYJHarDt7I26jlL6oNnXRD6fgGYnOM2hAcj9ZndE1/tEScO9Cl7ioL0xJxS8eUJTLO
         A7yz+uAlSRVUfDch0ewfKsmi8mpxGCcPlFkjcu1heaosFdgMQUiqGr3VvAPj8vurfXDc
         vVqhtvNy+9r64tYfGp5f8TlaAEH6h42xDBeUPBdpalb55HMb2mNOHK/YGpqY9wH71185
         P+Eg==
X-Gm-Message-State: APjAAAX9Sx35lBFRz1aOkPjpUQmB/gnd0/E6FZ79dFa2uGstrW/shKk5
	3d0FtDvhYRUX83qLzqOWsw9RxtLWZy14VqDqhEletxxCc812e+jgjKpNENqpQ7CQq99ltrsbGu9
	Z9GimAAsFKcbYBsjHw0JNBl2klYmJVbYR6V/Ym9ZzcLGqOkGcrV50/1tKt4517UyeDQ==
X-Received: by 2002:a37:6982:: with SMTP id e124mr1343163qkc.291.1561128970690;
        Fri, 21 Jun 2019 07:56:10 -0700 (PDT)
X-Received: by 2002:a37:6982:: with SMTP id e124mr1343103qkc.291.1561128969945;
        Fri, 21 Jun 2019 07:56:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561128969; cv=none;
        d=google.com; s=arc-20160816;
        b=EVUfZhU/YJxL0Yak9h37qiozbN+yoQ6b3Um6JVctsJvh8qGO4wyUhrg+VljmpmZjrD
         n180qGHfghyIuN1mpedRzvDJFfbjCMTVWYfyKvZf0bdKUOd98kEUM7ZfhMixN4m4ht1o
         w72PYIouj0+N/sVoTrUGWAmCZCWxt94usgAlF/lSkrUZ16zJgWe/Nl/L9ofdDbRQZ0h2
         jjNh92TtXFFP7LdpOtzfMxbpe6ZCIyI44tKTUi+CIbHFulD94wAC+KyFAfw47PUeFpzg
         BhsCg96gLMciZTCo0xpOClcVQ38aKaUE4NUzoD8labxcMSEeDFWrgQjGTUofTab4OgHv
         MAIQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:date
         :cc:to:from:subject:message-id:dkim-signature;
        bh=Y2jSEi8sxGbtd9XqToa9O5z6ODlBTruzPgaOmq/wTns=;
        b=N82/aikbb69H/tGqjkl6joy0cjZb0jfzeJdl5XGz5jfgpvtcbHdAHlvCYf1EH13sW7
         mQYW7zdzNSVNKa3/D+YSsVGh60SmGGhmK48lB15fmwlrti06lNn7dAuC95NoS2h8H6+O
         FIraXqEV+IkncMrdbonVGb75dASxjobc5M3kDNsTRnsyf7qlUuYimgDKdafKnugWk84K
         kXxMbSshZPQ01n2haN0yqYf9AD7Wp+AkS0fDJkbLx0eNcP8bkSZSRCAGrMOkmaS/P1d2
         ZnVsoJlDUNSuyj0Y2dZ10/Pcy/QpxPc02aS4sB4yGqA2fDyGb0qMlr0v1ANX9eH5gc6f
         f34A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=gYgr6uvq;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i6sor1721931qkc.47.2019.06.21.07.56.09
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 21 Jun 2019 07:56:09 -0700 (PDT)
Received-SPF: pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=gYgr6uvq;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=message-id:subject:from:to:cc:date:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=Y2jSEi8sxGbtd9XqToa9O5z6ODlBTruzPgaOmq/wTns=;
        b=gYgr6uvq3e99g5z1DITZTTDDikIDoeGMeREh38wawLs+nFJeAz5Xqj77bM3E910xFY
         +ZAljwkmUjsGIH1/zKjIY5Kt5vwDNvzTLF+OcYMgBOPGNGMmofaJuh9npl22zdMgU63z
         3VlBAKlSAzMm5bCEcaus7JH8AgTRPo9UiWQCTdh/hVUITLZsbCXOTUiA+KSsvcKnLeyw
         XWPY1KH2xf6Q/jSvqhmfHPlR+HqqngalxnndIi1832DfEBUWObiL0psTtreV3quiOdlH
         ds245fuvJ0nzAOKfIhEQfnP9gyLRKZbx2fRQhzQ61g+3/XorYHntg8sYaq9p6YCu+GZx
         oO9A==
X-Google-Smtp-Source: APXvYqwdtqGL7/0XnZ/6BRHrf7rNtb/EZiHjW12ga0UDVJnzJXCNm+v/P4zmsKvDmcfrhdhHGLYA1Q==
X-Received: by 2002:a37:680e:: with SMTP id d14mr15417323qkc.287.1561128969542;
        Fri, 21 Jun 2019 07:56:09 -0700 (PDT)
Received: from dhcp-41-57.bos.redhat.com (nat-pool-bos-t.redhat.com. [66.187.233.206])
        by smtp.gmail.com with ESMTPSA id g54sm2143489qtc.61.2019.06.21.07.56.08
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Jun 2019 07:56:08 -0700 (PDT)
Message-ID: <1561128967.5154.45.camel@lca.pw>
Subject: Re: [PATCH -next v2] mm/page_alloc: fix a false memory corruption
From: Qian Cai <cai@lca.pw>
To: Alexander Potapenko <glider@google.com>
Cc: Kees Cook <keescook@chromium.org>, Andrew Morton
 <akpm@linux-foundation.org>,  Linux Memory Management List
 <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
Date: Fri, 21 Jun 2019 10:56:07 -0400
In-Reply-To: <CAG_fn=WGdFZNrUCeMtbx4wbHhxWqM2s7Vq_GvnMC-9WJZ_mioQ@mail.gmail.com>
References: <1561063566-16335-1-git-send-email-cai@lca.pw>
	 <201906201801.9CFC9225@keescook>
	 <CAG_fn=VRehbrhvNRg0igZ==YvONug_nAYMqyrOXh3kO2+JaszQ@mail.gmail.com>
	 <1561119983.5154.33.camel@lca.pw>
	 <CAG_fn=WGdFZNrUCeMtbx4wbHhxWqM2s7Vq_GvnMC-9WJZ_mioQ@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.22.6 (3.22.6-10.el7) 
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 2019-06-21 at 16:37 +0200, Alexander Potapenko wrote:
> On Fri, Jun 21, 2019 at 2:26 PM Qian Cai <cai@lca.pw> wrote:
> > 
> > On Fri, 2019-06-21 at 12:39 +0200, Alexander Potapenko wrote:
> > > On Fri, Jun 21, 2019 at 3:01 AM Kees Cook <keescook@chromium.org> wrote:
> > > > 
> > > > On Thu, Jun 20, 2019 at 04:46:06PM -0400, Qian Cai wrote:
> > > > > The linux-next commit "mm: security: introduce init_on_alloc=1 and
> > > > > init_on_free=1 boot options" [1] introduced a false positive when
> > > > > init_on_free=1 and page_poison=on, due to the page_poison expects the
> > > > > pattern 0xaa when allocating pages which were overwritten by
> > > > > init_on_free=1 with 0.
> > > > > 
> > > > > Fix it by switching the order between kernel_init_free_pages() and
> > > > > kernel_poison_pages() in free_pages_prepare().
> > > > 
> > > > Cool; this seems like the right approach. Alexander, what do you think?
> > > 
> > > Can using init_on_free together with page_poison bring any value at all?
> > > Isn't it better to decide at boot time which of the two features we're
> > > going to enable?
> > 
> > I think the typical use case is people are using init_on_free=1, and then
> > decide
> > to debug something by enabling page_poison=on. Definitely, don't want
> > init_on_free=1 to disable page_poison as the later has additional checking
> > in
> > the allocation time to make sure that poison pattern set in the free time is
> > still there.
> 
> In addition to information lifetime reduction the idea of init_on_free
> is to ensure the newly allocated objects have predictable contents.
> Therefore it's handy (although not strictly necessary) to keep them
> zero-initialized regardless of other boot-time flags.
> Right now free_pages_prezeroed() relies on that, though this can be changed.
> 
> On the other hand, since page_poison already initializes freed memory,
> we can probably make want_init_on_free() return false in that case to
> avoid extra initialization.
> 
> Side note: if we make it possible to switch betwen 0x00 and 0xAA in
> init_on_free mode, we can merge it with page_poison, performing the
> initialization depending on a boot-time flag and doing heavyweight
> checks under a separate config.

Yes, that would be great which will reduce code duplication.

