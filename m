Return-Path: <SRS0=HICI=RB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 19EE4C43381
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 15:15:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B10FB217F5
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 15:15:52 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=amazonses.com header.i=@amazonses.com header.b="JuyoTIIc"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B10FB217F5
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 65E0E8E0003; Tue, 26 Feb 2019 10:15:52 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 60E178E0001; Tue, 26 Feb 2019 10:15:52 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 524778E0003; Tue, 26 Feb 2019 10:15:52 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2A5348E0001
	for <linux-mm@kvack.org>; Tue, 26 Feb 2019 10:15:52 -0500 (EST)
Received: by mail-qt1-f198.google.com with SMTP id 43so12330780qtz.8
        for <linux-mm@kvack.org>; Tue, 26 Feb 2019 07:15:52 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version
         :feedback-id;
        bh=45Qew3QBnmu7ojYaW6YmM69wuPKibVm0GTOcIA8Iu7Q=;
        b=Yp8qBsLMiSf0NU6OWwYW+0CHs+tUyqQEbkbKwdh1aSnG9wRTRa1kU9HCGtNvzDnEG9
         JtzosEv/cdiYgs+ymtRjOnxjFynLqv5/iteML9pQ5XoHoNhJWpoarjuXCybHKn4ciOPo
         DwA1Xb1lkFWM54qyV4bDSW+otJ+DNR7AKN1/gZvNPqsBYKxXCkucwbXVUsB1fJe5nUPy
         qXDaYNbq+vuv9sF1nQj5YUFkFHX6QV6BYtgibRv+m8/FFf6j6487rTxsBqSlTHddtWJH
         BXsgklZMDaM6rCVIp6cg7F9EhGMnziaxxUbxDf54CHPK5f93erARZVwvziTz1yJMg2m/
         tuuQ==
X-Gm-Message-State: AHQUAuYFprzTeKfZLL/o+vR2m64NDxNnOMv8zTp6ws+p8L9OWpDNeGtn
	dTFCdLQQnuteL6IppVqLoZL4uLM0qT/BZTshwiXwkx9ZxtTxJv7AMkECGZqkQAWvc5rKQGsZxbR
	EsLZniI5xDYFmQlTRVHEEKj/s3ioI+MQuYULfV5+sDDIPM+ZF94x5uoH1GLpZuzg=
X-Received: by 2002:ac8:2ca1:: with SMTP id 30mr18865913qtw.245.1551194151863;
        Tue, 26 Feb 2019 07:15:51 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZdbSYjzAx89UIv7kYvjs+/FM5ohAMJINMiB3m/uF/wLNylsrbxcSyxQizC3V60QYg5sFgo
X-Received: by 2002:ac8:2ca1:: with SMTP id 30mr18865871qtw.245.1551194151233;
        Tue, 26 Feb 2019 07:15:51 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551194151; cv=none;
        d=google.com; s=arc-20160816;
        b=RkwDnBL+7iHHKYeW9k+vOpG7FLQ/2XPerqunl1UP0bHxGfIkEt25mr663CduC2EW79
         QhziXas7kM5K0M2KVCOTNZ4fcJ+SZ2FS6a2OOEBQCMfSdWzOnZyWQe5fGNsR/BA903j2
         Rfi7/F1ApYuxkaB4fGjRx3FqAPqyOWi5YrxaYugBBggo8jhavCnjuH/Slroy9kVdOJnI
         IlX/FNQEBpa/y2jTyXmbH1uusgqAJRrZIRwG4OwdFbtRHYeAmPEKLtDSTDpm6svwreVs
         Wj8L+FYjmc/0TYooBxaPfDDl8No0rlY1Ln7oDiGCTpNu5nZ6j6taLhQ7uOERKAEH0p++
         c5Nw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=feedback-id:mime-version:user-agent:references:message-id
         :in-reply-to:subject:cc:to:from:date:dkim-signature;
        bh=45Qew3QBnmu7ojYaW6YmM69wuPKibVm0GTOcIA8Iu7Q=;
        b=X+vyu1M6hDsObSXnTDpHG2krT/hnaNzBcZSj1M72xnE3H7APqv8cwUJB6w+M/+dIJb
         bioQZGU5mePcSfxcElXY/Wd5+XZusdpOreTDvdNjhEpTdw1zXpxI8RsNgJFokoEdNzsh
         CuP/1q00C0S98VKxfhGSeIGTPXTp7zU9l/tLkr3VSAr6nXoe1niCTy8AYy5sfnF5e9CF
         xbgbfrTZFBQQhs2mO/L+ISzcpaEWsZsJSvB1MqQdvmAJZuOLbY4F0mL12sIsQw+GcwdC
         YNVXdpFsmyqVtSmc4MgCGVU9f87miLYap6TM/FGGQAhIl1e1YYZBxyURFlTMd/b3p5yX
         qy5A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=ug7nbtf4gccmlpwj322ax3p6ow6yfsug header.b=JuyoTIIc;
       spf=pass (google.com: domain of 010001692a605709-407cf476-e7b6-43be-8551-66c54059e92f-000000@amazonses.com designates 54.240.9.37 as permitted sender) smtp.mailfrom=010001692a605709-407cf476-e7b6-43be-8551-66c54059e92f-000000@amazonses.com
Received: from a9-37.smtp-out.amazonses.com (a9-37.smtp-out.amazonses.com. [54.240.9.37])
        by mx.google.com with ESMTPS id 38si5534842qtt.194.2019.02.26.07.15.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 26 Feb 2019 07:15:51 -0800 (PST)
Received-SPF: pass (google.com: domain of 010001692a605709-407cf476-e7b6-43be-8551-66c54059e92f-000000@amazonses.com designates 54.240.9.37 as permitted sender) client-ip=54.240.9.37;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=ug7nbtf4gccmlpwj322ax3p6ow6yfsug header.b=JuyoTIIc;
       spf=pass (google.com: domain of 010001692a605709-407cf476-e7b6-43be-8551-66c54059e92f-000000@amazonses.com designates 54.240.9.37 as permitted sender) smtp.mailfrom=010001692a605709-407cf476-e7b6-43be-8551-66c54059e92f-000000@amazonses.com
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/simple;
	s=ug7nbtf4gccmlpwj322ax3p6ow6yfsug; d=amazonses.com; t=1551194150;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:MIME-Version:Content-Type:Feedback-ID;
	bh=PLVgO+c/ksXQb0z1YKKNh9eSmG21/bkZ8P7aGZVkmZE=;
	b=JuyoTIIcD8txoIZN2v41dqigGwuCwFeamHQYH1nFqXaLUN6ydM49m8YpFEO1SW/V
	fS5QE5vWi9q9Edfw/orCnpJeZugTmcjKEix+fxI9r4jk+bE2EKkKw4ao5sviXIZHQRQ
	vdMUA5jYCL1JzaULPCIgrIMBqQG2rBy5/xcfNGIY=
Date: Tue, 26 Feb 2019 15:15:50 +0000
From: Christopher Lameter <cl@linux.com>
X-X-Sender: cl@nuc-kabylake
To: "dennis@kernel.org" <dennis@kernel.org>
cc: Peng Fan <peng.fan@nxp.com>, "tj@kernel.org" <tj@kernel.org>, 
    "linux-mm@kvack.org" <linux-mm@kvack.org>, 
    "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, 
    "van.freenix@gmail.com" <van.freenix@gmail.com>
Subject: Re: [PATCH 2/2] percpu: km: no need to consider
 pcpu_group_offsets[0]
In-Reply-To: <20190225151616.GB49611@dennisz-mbp.dhcp.thefacebook.com>
Message-ID: <010001692a605709-407cf476-e7b6-43be-8551-66c54059e92f-000000@email.amazonses.com>
References: <20190224132518.20586-1-peng.fan@nxp.com> <20190224132518.20586-2-peng.fan@nxp.com> <20190225151616.GB49611@dennisz-mbp.dhcp.thefacebook.com>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-SES-Outgoing: 2019.02.26-54.240.9.37
Feedback-ID: 1.us-east-1.fQZZZ0Xtj2+TD7V5apTT/NrT6QKuPgzCT/IC7XYgDKI=:AmazonSES
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000030, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 25 Feb 2019, dennis@kernel.org wrote:

> > @@ -67,7 +67,7 @@ static struct pcpu_chunk *pcpu_create_chunk(gfp_t gfp)
> >  		pcpu_set_page_chunk(nth_page(pages, i), chunk);
> >
> >  	chunk->data = pages;
> > -	chunk->base_addr = page_address(pages) - pcpu_group_offsets[0];
> > +	chunk->base_addr = page_address(pages);
> >
> >  	spin_lock_irqsave(&pcpu_lock, flags);
> >  	pcpu_chunk_populated(chunk, 0, nr_pages, false);
> > --
> > 2.16.4
> >
>
> While I do think you're right, creating a chunk is not a part of the
> critical path and subtracting 0 is incredibly minor overhead. So I'd
> rather keep the code as is to maintain consistency between percpu-vm.c
> and percpu-km.c.

Well it is confusing if there the expression is there but never used. It
is clearer with the patch.

