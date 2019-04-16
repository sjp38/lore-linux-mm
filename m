Return-Path: <SRS0=AiS9=SS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0FD63C10F0E
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 03:15:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 96D6E20868
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 03:15:10 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="Y8xqOZaS"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 96D6E20868
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 075426B0003; Mon, 15 Apr 2019 23:15:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F406B6B0006; Mon, 15 Apr 2019 23:15:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E095C6B0007; Mon, 15 Apr 2019 23:15:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vs1-f70.google.com (mail-vs1-f70.google.com [209.85.217.70])
	by kanga.kvack.org (Postfix) with ESMTP id B7D3E6B0003
	for <linux-mm@kvack.org>; Mon, 15 Apr 2019 23:15:09 -0400 (EDT)
Received: by mail-vs1-f70.google.com with SMTP id l6so3691490vsl.7
        for <linux-mm@kvack.org>; Mon, 15 Apr 2019 20:15:09 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=Mk6BIBLLGO0U80tLWMVE0489EqA725xprr9VtegXBQw=;
        b=s4zOCXt/5tnfX3VPxty6AkxVLIojCdhEJCalX9y4JpF7NiyXfMn+psgEzh3590TkyU
         SlyamS9Q2R5qr+pUiIqRX9KxhoKfbSrnnU4JfI1wS9Nvqm5mm+qZfYseiWpUZT/Rxnq2
         UP+FOmlJw0UMiaiv18SYSj39bPjpgpYVWFyMXrCnIuVQQHR9aoL/mCs0Yl1SZrNRW4Kg
         fkVM9D/nTPqls12bNQ2oAApwt3gakSDAFpTu14Nsm5gNpFpycKZaSBV2meSjjh/tl5XU
         sBof1mn/2xcG3sTvbMe4K2dc/smQeArtWiwI8FI4wJoyxD0ztEMyxh/yxCz6tNZDFFr4
         USAw==
X-Gm-Message-State: APjAAAVudYnUdD60fTvycR0zTXoBKVVvC+RAsHPtdtNhBCDP6q+NCAxm
	tyPOJu8G1P96q7MjGUnPLJ+6+TxUyUnP4dFd9PvAPGKVEx/IiWPvDeyBHU9cpUv5jhGfMg7y4Re
	vRHb4yZ3iCX76ygkBCL/sPCpauRc8fr/EP6bfiUMy5/qZlZbrF1rbYR9dUOBzjcpL5Q==
X-Received: by 2002:ab0:208d:: with SMTP id r13mr38522849uak.128.1555384509323;
        Mon, 15 Apr 2019 20:15:09 -0700 (PDT)
X-Received: by 2002:ab0:208d:: with SMTP id r13mr38522813uak.128.1555384508614;
        Mon, 15 Apr 2019 20:15:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555384508; cv=none;
        d=google.com; s=arc-20160816;
        b=GSNC0Po7fEaPVHfJ281fNVQYP/RMUKLhhfJT++LeeQgK3T/oNutsyQWxJyQyXDc/4A
         fhMIHFYM203dkgySOTG5sBG98uUMsAJ6Jt0Dsh21A6D4FPT6EBZyFKo/SotE+/J3RJb3
         /iuvdw5ItRYuIw+iCaHfwNq4zyNdIoJdg8/mq5+/zdClXSA9hZq+D64Z1TuMBcd6ewEQ
         LwZGlZ9KTvwxdaF4x4K+ePsQhRulm4qSOtdI76EvKuA+fDxaHXty7dJKDO4yU4sViFEa
         MwVKIMCI+y46bd8FRrucm1Jn9tv3DQlknI78oRVQrzCtbOn4DA81ZG5rpD6TlQQX3WNx
         B0gA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=Mk6BIBLLGO0U80tLWMVE0489EqA725xprr9VtegXBQw=;
        b=bDSi5hvjp+GCd2d2YhVvhb74PJx9iXDbFeshr/9WxkJbxhu4xNLvTeoypoYBMToCOT
         KMo035Mq2sEIqGdl28WzwbBt1vw5Wz6LypU8oGSqVMdkAqFMbgCkA6n2nY45r5l3ZhOo
         E5WC61t5zVKAdx20iaaAY3c9gn1Acao3Csyr5ZxhExtpCShQwd5qilS7y50e2on7oBKJ
         7atXUX9UEkR/b/6O9w/OG0/jQJ322f1/gPYbDLpmHe9OiGF7NBambBK69FSUrEgqoUK3
         R2a/+FjZwWN7vru2ZqrPmT119g1l4voYIzVqD1xaHziAr4WOpS7QsxjGYsci4uXvXdXo
         KMWw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=Y8xqOZaS;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 4sor25989934vsz.67.2019.04.15.20.15.08
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 15 Apr 2019 20:15:08 -0700 (PDT)
Received-SPF: pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=Y8xqOZaS;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chromium.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=Mk6BIBLLGO0U80tLWMVE0489EqA725xprr9VtegXBQw=;
        b=Y8xqOZaS7jkwKovka8QtC0wCgsNCE4WBE8pK3EDq4eKI6sO+T80f/S1bmRcL3mxz/l
         Cvk05b4RCyjWoI0j+pNA99L3vDReq81bLIvF4e378eH+fFvsHhaQpkt9P2QwQ9zEhlaW
         p792GG7NkrUjaFmz8u13GMr+5hDAtUDZo0rY4=
X-Google-Smtp-Source: APXvYqy+uMwv9hMixul/PYGPdMP8/KNBizKptw1gQ8E+sv66MkDxcj99Zqqths+buoLUw8KFqlS23g==
X-Received: by 2002:a05:6102:147:: with SMTP id a7mr38129283vsr.210.1555384507803;
        Mon, 15 Apr 2019 20:15:07 -0700 (PDT)
Received: from mail-vs1-f44.google.com (mail-vs1-f44.google.com. [209.85.217.44])
        by smtp.gmail.com with ESMTPSA id b197sm65542475vkd.9.2019.04.15.20.15.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Apr 2019 20:15:04 -0700 (PDT)
Received: by mail-vs1-f44.google.com with SMTP id t78so10721009vsc.1
        for <linux-mm@kvack.org>; Mon, 15 Apr 2019 20:15:04 -0700 (PDT)
X-Received: by 2002:a67:f04e:: with SMTP id q14mr43541834vsm.133.1555384503717;
 Mon, 15 Apr 2019 20:15:03 -0700 (PDT)
MIME-Version: 1.0
References: <20190411192607.GD225654@gmail.com> <20190411192827.72551-1-ebiggers@kernel.org>
 <CAGXu5jJ8k7fP5Vb=ygmQ0B45GfrK2PeaV04bPWmcZ6Vb+swgyA@mail.gmail.com>
 <20190415022412.GA29714@bombadil.infradead.org> <20190415024615.f765e7oagw26ezam@gondor.apana.org.au>
 <20190416021852.GA18616@bombadil.infradead.org>
In-Reply-To: <20190416021852.GA18616@bombadil.infradead.org>
From: Kees Cook <keescook@chromium.org>
Date: Mon, 15 Apr 2019 22:14:51 -0500
X-Gmail-Original-Message-ID: <CAGXu5jKaVB=bTJCBWhsxAny7-OkzXQ+8KCd5O+_-7hKcJFiqKw@mail.gmail.com>
Message-ID: <CAGXu5jKaVB=bTJCBWhsxAny7-OkzXQ+8KCd5O+_-7hKcJFiqKw@mail.gmail.com>
Subject: Re: [PATCH] crypto: testmgr - allocate buffers with __GFP_COMP
To: Matthew Wilcox <willy@infradead.org>
Cc: Herbert Xu <herbert@gondor.apana.org.au>, Kees Cook <keescook@chromium.org>, 
	Eric Biggers <ebiggers@kernel.org>, Rik van Riel <riel@surriel.com>, 
	linux-crypto <linux-crypto@vger.kernel.org>, Dmitry Vyukov <dvyukov@google.com>, 
	Geert Uytterhoeven <geert@linux-m68k.org>, 
	linux-security-module <linux-security-module@vger.kernel.org>, 
	Linux ARM <linux-arm-kernel@lists.infradead.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Laura Abbott <labbott@redhat.com>, 
	Linux-MM <linux-mm@kvack.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Apr 15, 2019 at 9:18 PM Matthew Wilcox <willy@infradead.org> wrote:
> I agree; if the crypto code is never going to try to go from the address of
> a byte in the allocation back to the head page, then there's no need to
> specify GFP_COMP.
>
> But that leaves us in the awkward situation where
> HARDENED_USERCOPY_PAGESPAN does need to be able to figure out whether
> 'ptr + n - 1' lies within the same allocation as ptr.  Without using
> a compound page, there's no indication in the VM structures that these
> two pages were allocated as part of the same allocation.
>
> We could force all multi-page allocations to be compound pages if
> HARDENED_USERCOPY_PAGESPAN is enabled, but I worry that could break
> something.  We could make it catch fewer problems by succeeding if the
> page is not compound.  I don't know, these all seem like bad choices
> to me.

If GFP_COMP is _not_ the correct signal about adjacent pages being
part of the same allocation, then I agree: we need to drop this check
entirely from PAGESPAN. Is there anything else that indicates this
property? (Or where might we be able to store that info?)

There are other pagespan checks, though, so those could stay. But I'd
really love to gain page allocator allocation size checking ...

-- 
Kees Cook

