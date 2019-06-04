Return-Path: <SRS0=7ZCb=UD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 83340C28CC6
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 07:13:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 49D0524A6F
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 07:13:34 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="SQM6/EJd"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 49D0524A6F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E97D36B000D; Tue,  4 Jun 2019 03:13:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E486F6B0266; Tue,  4 Jun 2019 03:13:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D36636B0269; Tue,  4 Jun 2019 03:13:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f71.google.com (mail-io1-f71.google.com [209.85.166.71])
	by kanga.kvack.org (Postfix) with ESMTP id B0A766B000D
	for <linux-mm@kvack.org>; Tue,  4 Jun 2019 03:13:33 -0400 (EDT)
Received: by mail-io1-f71.google.com with SMTP id h4so6615360iol.5
        for <linux-mm@kvack.org>; Tue, 04 Jun 2019 00:13:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=Anyl5LfgBc3g4Qq9ThwWzuBDfxB1rHp0Hliwmm1saaE=;
        b=OBfFBmMIKy/Vcgvn+4xiB6TT7uqbvfRupiumsH1yTNJD9+rHTgeaZl8fC3bv75YNsw
         HgqVTSznl8Gf0THTvNS1x2er9DVysBSC0NsQFxtCHj+iPyD4DK3kFybzHyx4TfheuX3m
         4NSMzJbWdC1rL5q+6XiJVsw7gxk9oE3uE1ZRojHzhAowv276la0/1yCmQ+DS4OBm4f1m
         dxBBATOBzVN7pINyp+UQOwVBy8wnYXurGr/bPPFvYgOW1aWVs8t2F6dEuVQJf4u6SztL
         R45RspdgAU3Q3nu3NZ1a96MCzrDr0X/UUKwpLRm08pyB9pnKmxafd3pJs4W85/08QeO7
         VHow==
X-Gm-Message-State: APjAAAW7aULucIjr803tAnRQH2ktuuv3QqYkUYcACUXlqrh/1B9+/Yii
	yoSVi+VWvPK+Yp2HVpneRKszftXtweI8iuMG/qr70S/XeyDIK9YXm0u5qOrJuMG3ohX+P8IiyTu
	eFvpcNHF0V3w+730sExNITcY3PY+b1mD12WvjbqFF5b7WzYpO+dUL7YTrJWJOpwzOkA==
X-Received: by 2002:a5e:8306:: with SMTP id x6mr2944616iom.130.1559632413496;
        Tue, 04 Jun 2019 00:13:33 -0700 (PDT)
X-Received: by 2002:a5e:8306:: with SMTP id x6mr2944579iom.130.1559632412717;
        Tue, 04 Jun 2019 00:13:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559632412; cv=none;
        d=google.com; s=arc-20160816;
        b=yxnjWBNjsC1GsaIyi00NURY4MDjwQDT+UBtJHsEFfFrcVL0vE5Yi693jC5/pWGPOIE
         C7cCQTw5ixu9oHFUh07FG5STaF2nd6NnPToIxDlypl4ukocr2guHl67aFYVO3X6S66pT
         k18g8JwSRciWxOcGXSiK9f83PRkknPslcnOlqH8SoFDVeYqV3DxrHe5q3BXc7k1FXs2F
         D0X3O0lmr4MQJ0mUWyxBIqzoT22azOhFWoG8D4KiTUJR+f2mxSae0093rL4S8z2MdPtJ
         Pe3YLIZgnNif4CfZy4jZgiGJy6PxDSKt+ouRAoF30Hz6gZBPmZg2z332DZBYymAJRLWW
         lD3g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=Anyl5LfgBc3g4Qq9ThwWzuBDfxB1rHp0Hliwmm1saaE=;
        b=kxNIlHhJcksUHmrPsCOpTtDKavHW8veYtabGGZOMGZ7hIX9Bf45LyBBfOo/ciGe+WP
         4aMSvjU6quqWv+NGGHa1Iq3Q1KM/9k2oaUaf5ISATHpps1Q4pnaLaEmDQAMBEdrdXtwk
         fJPRdX90ToKv7aWcIou2f42VH+tzjEGwC1jGHi+fnT5cqLyunOemEdQ54OUMI/GT9LfN
         6eIhATWowdJD7hWuhUM4nlzubhcMSmvib9ss3xsab79C/QSe54SOReCW0uaPCnWOVFci
         8RnuhrLSJsSI7UEjKDklxc6l1CtnsmLl9fXeWzPj1WBieKnvWKC6aW0N5GWSR0Cc1yiL
         2IWA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="SQM6/EJd";
       spf=pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=kernelfans@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id w20sor2149499ioc.43.2019.06.04.00.13.32
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 04 Jun 2019 00:13:32 -0700 (PDT)
Received-SPF: pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="SQM6/EJd";
       spf=pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=kernelfans@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=Anyl5LfgBc3g4Qq9ThwWzuBDfxB1rHp0Hliwmm1saaE=;
        b=SQM6/EJdbswwlNhwv+y8Id3fvVx/4iyLP4qfZC+3BW6uS/hQpRfKnOscwF/5nkMtlu
         wP/RuvF7g/8qDceeXJJ3juses1hBi71YdrDlnzqN9CYcaKg4TPN2zP18J99DP/QbAnS5
         qM15EasngRB8DXCvUNyQc82WzxDeNV4t1EQB+tmN7olJqEodZIMWRfm0ci9SnX0ydoN3
         nSR8+XUIH7y+1DKUyix+FfriPayor5gVRpcW0/1KTJJzzh6+S6cg0KRhUM4Hg8rNUmNR
         Gp7Jgll28g9QJ/LWU6uyM38nppXr00RJSeAFhAhYmZU2q0BFoNlkpgM8qb+lZCoXZjPG
         q1sA==
X-Google-Smtp-Source: APXvYqzzLbGvTakDXi6vbfCj78A6wjQwggKbm8stb2Ai5YrIxlb+17oF2AfZtomYgKnHaH+lWAwAHuc23uwdrVucDEg=
X-Received: by 2002:a6b:e005:: with SMTP id z5mr4088171iog.161.1559632412460;
 Tue, 04 Jun 2019 00:13:32 -0700 (PDT)
MIME-Version: 1.0
References: <1559543653-13185-1-git-send-email-kernelfans@gmail.com> <20190603164206.GB29719@infradead.org>
In-Reply-To: <20190603164206.GB29719@infradead.org>
From: Pingfan Liu <kernelfans@gmail.com>
Date: Tue, 4 Jun 2019 15:13:21 +0800
Message-ID: <CAFgQCTtUdeq=M=SrVwvggR15Yk+i=ndLkhkw1dxJa7miuDp_AA@mail.gmail.com>
Subject: Re: [PATCHv2 1/2] mm/gup: fix omission of check on FOLL_LONGTERM in get_user_pages_fast()
To: Christoph Hellwig <hch@infradead.org>
Cc: linux-mm@kvack.org, Ira Weiny <ira.weiny@intel.com>, 
	Andrew Morton <akpm@linux-foundation.org>, Mike Rapoport <rppt@linux.ibm.com>, 
	Dan Williams <dan.j.williams@intel.com>, Matthew Wilcox <willy@infradead.org>, 
	John Hubbard <jhubbard@nvidia.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>, 
	Keith Busch <keith.busch@intel.com>, LKML <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jun 4, 2019 at 12:42 AM Christoph Hellwig <hch@infradead.org> wrote:
>
> > +#if defined(CONFIG_CMA)
>
> You can just use #ifdef here.
>
OK.
> > +static inline int reject_cma_pages(int nr_pinned, unsigned int gup_flags,
> > +     struct page **pages)
>
> Please use two instead of one tab to indent the continuing line of
> a function declaration.
>
Is it a convention? scripts/checkpatch.pl can not detect it. Could you
show me some light so later I can avoid it?

Thanks for your review.

Regards,
  Pingfan
> > +{
> > +     if (unlikely(gup_flags & FOLL_LONGTERM)) {
>
> IMHO it would be a little nicer if we could move this into the caller.

