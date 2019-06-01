Return-Path: <SRS0=MiGm=UA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B1BAEC28CC1
	for <linux-mm@archiver.kernel.org>; Sat,  1 Jun 2019 16:14:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5E5762774C
	for <linux-mm@archiver.kernel.org>; Sat,  1 Jun 2019 16:14:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=linux-foundation.org header.i=@linux-foundation.org header.b="RdmXCPI1"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5E5762774C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C3AAC6B0005; Sat,  1 Jun 2019 12:14:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BC4776B0006; Sat,  1 Jun 2019 12:14:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AB4046B0007; Sat,  1 Jun 2019 12:14:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f70.google.com (mail-lf1-f70.google.com [209.85.167.70])
	by kanga.kvack.org (Postfix) with ESMTP id 475116B0005
	for <linux-mm@kvack.org>; Sat,  1 Jun 2019 12:14:39 -0400 (EDT)
Received: by mail-lf1-f70.google.com with SMTP id a1so319205lfi.16
        for <linux-mm@kvack.org>; Sat, 01 Jun 2019 09:14:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=TKTAJ8E7sNy2vEZhocfTI/IVyiugHenGqfHPAGmTqUU=;
        b=p3Sz/0xGXIPWc6FSph1YCyINyqmb2MCKJGPdJdcMJlMwc7xrb+v5G3d2ULwktiydF8
         B6Y6WNPy/M0R8xibO2IOLRarzEgDxDxEzlFpiZPQxdfpY8XOcKxSMlXOonUk9NPWRogP
         JEiMUIdcNuYcjjbk8q6LDEZMZp6asuesGC25oq9Udf1amvqfU7ruzmgWEpzyDS0RvIXN
         afOSigb3Kc/vSICTHjpViBYJsUnIEVonuI5lSQBFkOd96AE6ZLRavJUlVD6YojadKK1S
         vECmwjaa1EnUZZO1Xfa6Bqf0O3/hyozSPlUov3+newxKJ1T/j/jNRfjgLYBVBnCIEBhm
         RWEg==
X-Gm-Message-State: APjAAAXzknsM43C7zD7Md8Q0vWLNZjw96C+YjUQaHYrCBT0CxN+h9t/D
	78523QRGZ4XyELYYbmDIjEHKAtk1+lBoTSkc7AdFuFI6bj+kfmyaqsTPJBxSFca90j+GMTN1chf
	P5lCHTSPMBYr7H9+um6mTh8VTbPcVMB1kzzltDCVcTdfYdYGRg6EHmrmaMniA6VjuXA==
X-Received: by 2002:a2e:97d8:: with SMTP id m24mr9245754ljj.52.1559405678353;
        Sat, 01 Jun 2019 09:14:38 -0700 (PDT)
X-Received: by 2002:a2e:97d8:: with SMTP id m24mr9245713ljj.52.1559405677077;
        Sat, 01 Jun 2019 09:14:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559405677; cv=none;
        d=google.com; s=arc-20160816;
        b=o8Cad3kf9XDwesSpj/EeR0W2tpANWKsJGgaUUXrawWWTK9kvKdeWeVizCplap7IsWh
         vNDykNnh+J8md15OEosE/hN+KZgbJawVQ5VTgIVKJfbTHBnpY/3rescW3dlhGaV7Ampc
         4lm7JlWH4oQXh7Li2vOt8G0V9eEevtKwS+4qXav2SWcCUN++0PrccFV6+hMKgO443/yR
         Jgj53jPBulrEIS1wYK2zzPcxP0Kk5mLUd1A+S0AjPRSXbbUYefFaHU4E2LANS10o61fB
         LqJ4mOQXS536EwsUaPsFY4/5FNufDvLs6JGZvI8mdFgmWAphHDY86Zgs0BSguPTc4MrP
         l5ng==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=TKTAJ8E7sNy2vEZhocfTI/IVyiugHenGqfHPAGmTqUU=;
        b=LeZY42in52MQhfPu6mx6R5se9ZfxMMnY8PXQiptGYnbsSBen6Oxji3j+5txeERLuDV
         WWd1FsxyhXC/93tyuJ0fq4XAwxg0bjoBqRr2S2CexmepsIra0D+ENqTkMuAH5kuFS6JG
         TVS05JQlC+sXtpD59kFyffqGdhwgLHDzWdcX8C2Uyh0O2cs1u7Ollee8bzYyc6MBgmvX
         x4fX68cgklp9cmYul8dflae19YN6pAdkyYrifzolLx1i6LogckhqgdiiC6FWNJ6btRWA
         m6Fiu84xeVGMaxjxNJXHCR3BucvZSvCF/WEKpG7iVP3jIONQa+ZmNWkl6e1A/43tporg
         GQyA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@linux-foundation.org header.s=google header.b=RdmXCPI1;
       spf=pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=torvalds@linuxfoundation.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n1sor2982387lfg.31.2019.06.01.09.14.36
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 01 Jun 2019 09:14:36 -0700 (PDT)
Received-SPF: pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@linux-foundation.org header.s=google header.b=RdmXCPI1;
       spf=pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=torvalds@linuxfoundation.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=linux-foundation.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=TKTAJ8E7sNy2vEZhocfTI/IVyiugHenGqfHPAGmTqUU=;
        b=RdmXCPI1V+CWEuQQLIpoDnZHvNbMKl90LuqFIcI1YnEKXhPCSK5AUEFPNd650/ERUV
         Qh10sm7MSlB6HnOBHykL5KhchRGHirJ9ssAdIkVcDYKPumYo1Zi2YYM6BhTRVFDVSg7U
         Nczzjs9o+pp1b0tTsgtO9YPvDZ1uwi7oKCdAA=
X-Google-Smtp-Source: APXvYqz3zoFzjBnAHI9hKd3dD0a7uCC0BGm9xUKMHXjCA5n8ZypusR9CLT/fEUYcSc7FI8NXKWTxKg==
X-Received: by 2002:ac2:4908:: with SMTP id n8mr8693805lfi.10.1559405675463;
        Sat, 01 Jun 2019 09:14:35 -0700 (PDT)
Received: from mail-lf1-f42.google.com (mail-lf1-f42.google.com. [209.85.167.42])
        by smtp.gmail.com with ESMTPSA id j11sm1868593lfm.29.2019.06.01.09.14.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 01 Jun 2019 09:14:34 -0700 (PDT)
Received: by mail-lf1-f42.google.com with SMTP id r15so10335815lfm.11
        for <linux-mm@kvack.org>; Sat, 01 Jun 2019 09:14:33 -0700 (PDT)
X-Received: by 2002:a19:ae01:: with SMTP id f1mr8899724lfc.29.1559405673566;
 Sat, 01 Jun 2019 09:14:33 -0700 (PDT)
MIME-Version: 1.0
References: <20190601074959.14036-1-hch@lst.de> <20190601074959.14036-4-hch@lst.de>
In-Reply-To: <20190601074959.14036-4-hch@lst.de>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Sat, 1 Jun 2019 09:14:17 -0700
X-Gmail-Original-Message-ID: <CAHk-=whusWKhS=SYoC9f9HjVmPvR5uP51Mq=ZCtktqTBT2qiBw@mail.gmail.com>
Message-ID: <CAHk-=whusWKhS=SYoC9f9HjVmPvR5uP51Mq=ZCtktqTBT2qiBw@mail.gmail.com>
Subject: Re: [PATCH 03/16] mm: simplify gup_fast_permitted
To: Christoph Hellwig <hch@lst.de>
Cc: Paul Burton <paul.burton@mips.com>, James Hogan <jhogan@kernel.org>, 
	Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, 
	"David S. Miller" <davem@davemloft.net>, Nicholas Piggin <npiggin@gmail.com>, 
	Khalid Aziz <khalid.aziz@oracle.com>, Andrey Konovalov <andreyknvl@google.com>, 
	Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, 
	Michael Ellerman <mpe@ellerman.id.au>, linux-mips@vger.kernel.org, 
	Linux-sh list <linux-sh@vger.kernel.org>, sparclinux@vger.kernel.org, 
	linuxppc-dev@lists.ozlabs.org, Linux-MM <linux-mm@kvack.org>, 
	"the arch/x86 maintainers" <x86@kernel.org>, Linux List Kernel Mailing <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Jun 1, 2019 at 12:50 AM Christoph Hellwig <hch@lst.de> wrote:
>
> Pass in the already calculated end value instead of recomputing it, and
> leave the end > start check in the callers instead of duplicating them
> in the arch code.

Good cleanup, except it's wrong.

> -       if (nr_pages <= 0)
> +       if (end < start)
>                 return 0;

You moved the overflow test to generic code - good.

You removed the sign and zero test on nr_pages - bad.

The zero test in particular is _important_ - the GUP range operators
know and depend on the fact that they are passed a non-empty range.

The sign test it less so, but is definitely appropriate. It might be
even better to check that the "<< PAGE_SHIFT" doesn't overflow in
"long", of course, but with callers being supposed to be trusted, the
sign test at least checks for stupid underflow issues.

So at the very least that "(end < start)" needs to be "(end <=
start)", but honestly, I think the sign of the nr_pages should be
continued to be checked.

                      Linus

