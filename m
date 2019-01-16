Return-Path: <SRS0=bSwl=PY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1DAA7C43612
	for <linux-mm@archiver.kernel.org>; Wed, 16 Jan 2019 05:34:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CD9442082F
	for <linux-mm@archiver.kernel.org>; Wed, 16 Jan 2019 05:34:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=linux-foundation.org header.i=@linux-foundation.org header.b="dMA7vAKe"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CD9442082F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6B1018E0003; Wed, 16 Jan 2019 00:34:23 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 635FB8E0002; Wed, 16 Jan 2019 00:34:23 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4D8C68E0003; Wed, 16 Jan 2019 00:34:23 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f200.google.com (mail-lj1-f200.google.com [209.85.208.200])
	by kanga.kvack.org (Postfix) with ESMTP id D25B98E0002
	for <linux-mm@kvack.org>; Wed, 16 Jan 2019 00:34:22 -0500 (EST)
Received: by mail-lj1-f200.google.com with SMTP id v74-v6so1299496lje.6
        for <linux-mm@kvack.org>; Tue, 15 Jan 2019 21:34:22 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=LDxDttklbhpkSSFdds0eF04wkYvET9AjjK+yF2ZuPzE=;
        b=Ca6NW6vuhNksHa8nO1taoE87b86ANZfauwJSjyLOP265wu6z0YXauM5SViTiqVkfzZ
         D/Zezfn1Scu/la9w8t3hJQ58zU3nAsPwKkWTi9DPt6K5gbMppZojaeZHWC15u/AHsmPA
         7SppfH9NxQawNXZ8/jVR5Hp83Wfh81mftaqZ5C3KK6Ah/2GnP8PY9/WyT7xoVwTNq2lL
         TvTrai7TLkgJFMTtNVK63iYZykG+B/nquReYUo+iZ1uz1AZ//z31tbhPCcLEcA3bownQ
         pIHBqjyNmtvy76vCulLhSRtVpa+y0IfTo84xTnhvqVD8VardzZrAQABMbsJTFKfK9sHS
         I3bw==
X-Gm-Message-State: AJcUukfveSpu66agJXmkRw08B+OBxx+rn7FySLslqqIB3Tac2aF3ip4c
	UsCI9MLhryy61/jtbfCwUttvqAeH+Ujx8s2K3FH3gyL1Vqyk2qGsli8RXAdCVf3CsbNefI/t4gv
	OhzlDc5DbiJTCxQKKUd95/wi0mZskJbZgbvx5iP4NnV6Yr+Ha2ej7MF5QRjfZPmrGM7YojtPKki
	TR0wDcabJJgbnJ1mjAWPHiAyGKnadiCab7hcKOshDdh8l8ZU3fBVtyTErsAjOiucZ0Z/IN6rHs8
	0T21WRjtc5S+HtkjD/reJ8bzEXhsfHCVEqZjpHDFYcQUOWTAr3o6fnf4SYT/WETgoeAkQtR0zKv
	e3naqcwMeGQwrEeHe1efc1Uvm20dsMeSUvI3N5x670jDUVpRVsaoZdFtCssfxo7BfisHd2uJLrC
	m
X-Received: by 2002:a2e:6595:: with SMTP id e21-v6mr5520217ljf.123.1547616862052;
        Tue, 15 Jan 2019 21:34:22 -0800 (PST)
X-Received: by 2002:a2e:6595:: with SMTP id e21-v6mr5520172ljf.123.1547616861006;
        Tue, 15 Jan 2019 21:34:21 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1547616861; cv=none;
        d=google.com; s=arc-20160816;
        b=BcbHzIJHucyPWBmQ91i+KiTkzWdHDIFNQL+wib0Jj6Q/VBqUvnYdMEKGgpYG+QEwm8
         DLeEtgG9CQnMXMfJZOcDtRht60g0HTxTDFd0se70bhTBahE9YJH+7CPQoVCvY2SASePA
         soq77Ct8hm8nM8hXbUTbQ9e0f+iuppc4F/Z+idRzkSAMTtsasYI9fVV6iEvA3u7W0OWj
         cdRiZzgFwxoi9ko/+lSCHayLALfbD5Ra9CLhf1jYegNIxl26Tj/w7qHgh3Lt2/SBjlYC
         lV1tlAFCOXaLzRRD80kRBCQUqtWDSP7wfYUJSW/Dv0VK9/6RMXy+Bra//asRhdErsDrg
         DWpQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=LDxDttklbhpkSSFdds0eF04wkYvET9AjjK+yF2ZuPzE=;
        b=dSuCobe26/N3lSZjULqDO5TP3sz3BZ8wCFPRI60uy5BkJxBSI6udPIeAI/u9b/hQVo
         J3gh+AlGPNj+QYK77b2sWGcCP2XJuv7WXyr1esrvLjyESRtN81v6ieTuYWL+IQwAbWDe
         qLuy/rz2qpojdcQwZm4BYPJX02JlRUq79DHvTOt0VtCSg5tU/513x8yzaJBsfaKJltST
         eDiiJ1tWWo/+OE1e9kwAtKswxtjwgtpyD9RufU9ZmbPw1WplRR6JK+eHsbz9/nyM4pDQ
         390KZnL3p0IcDJtn0EpfoPrYLtTlGf5nNTa4D5OBf0AggpFkMF7jShWbEHcLqkEW5shF
         PD7w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@linux-foundation.org header.s=google header.b=dMA7vAKe;
       spf=pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=torvalds@linuxfoundation.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e11-v6sor3836703ljg.24.2019.01.15.21.34.20
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 15 Jan 2019 21:34:20 -0800 (PST)
Received-SPF: pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@linux-foundation.org header.s=google header.b=dMA7vAKe;
       spf=pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=torvalds@linuxfoundation.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=linux-foundation.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=LDxDttklbhpkSSFdds0eF04wkYvET9AjjK+yF2ZuPzE=;
        b=dMA7vAKe4Uxo13jLl7fuE02FkWSO9VLEtIiC20q6ryh7qGuilSEBxz0+EQjqTdCvH1
         dfnnNIrDVHLAmspi+kEutDaiSBDCjQXDDZeWLIuw36P0qGup094crertM7FqgpCuwxbz
         NTB7xxRsm9w7aa4NUnH42wRZALAPuidJQR0qw=
X-Google-Smtp-Source: ALg8bN5DHgumFjynaOJSMlLax0mbQIzxdhZC910XxOWJaS2F7cpZSpBIqQWSBwH5Yi+EmQyoOiOnWg==
X-Received: by 2002:a2e:8156:: with SMTP id t22-v6mr5178525ljg.32.1547616859731;
        Tue, 15 Jan 2019 21:34:19 -0800 (PST)
Received: from mail-lj1-f174.google.com (mail-lj1-f174.google.com. [209.85.208.174])
        by smtp.gmail.com with ESMTPSA id o25sm959180lfd.29.2019.01.15.21.34.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Jan 2019 21:34:18 -0800 (PST)
Received: by mail-lj1-f174.google.com with SMTP id v15-v6so4317153ljh.13
        for <linux-mm@kvack.org>; Tue, 15 Jan 2019 21:34:18 -0800 (PST)
X-Received: by 2002:a2e:9c7:: with SMTP id 190-v6mr4899089ljj.120.1547616858160;
 Tue, 15 Jan 2019 21:34:18 -0800 (PST)
MIME-Version: 1.0
References: <20190108044336.GB27534@dastard> <CAHk-=wjvzEFQcTGJFh9cyV_MPQftNrjOLon8YMMxaX0G1TLqkg@mail.gmail.com>
 <20190109022430.GE27534@dastard> <nycvar.YFH.7.76.1901090326460.16954@cbobk.fhfr.pm>
 <20190109043906.GF27534@dastard> <CAHk-=wic28fSkwmPbBHZcJ3BGbiftprNy861M53k+=OAB9n0=w@mail.gmail.com>
 <20190110004424.GH27534@dastard> <CAHk-=wg1jSQ-gq-M3+HeTBbDs1VCjyiwF4gqnnBhHeWizyrigg@mail.gmail.com>
 <20190110070355.GJ27534@dastard> <CAHk-=wigwXV_G-V1VxLs6BAvVkvW5=Oj+xrNHxE_7yxEVwoe3w@mail.gmail.com>
 <20190110122442.GA21216@nautica> <CAHk-=wip2CPrdOwgF0z4n2tsdW7uu+Egtcx9Mxxe3gPfPW_JmQ@mail.gmail.com>
 <5c3e7de6.1c69fb81.4aebb.3fec@mx.google.com> <CAHk-=wgF9p9xNzZei_-ejGLy1bJf4VS1C5E9_V0kCTEpCkpCTQ@mail.gmail.com>
 <9E337EA6-7CDA-457B-96C6-E91F83742587@amacapital.net>
In-Reply-To: <9E337EA6-7CDA-457B-96C6-E91F83742587@amacapital.net>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 16 Jan 2019 17:34:01 +1200
X-Gmail-Original-Message-ID: <CAHk-=wjqkbjL2_BwUYxJxJhdadiw6Zx-Yu_mK3E6P7kG3wSGcQ@mail.gmail.com>
Message-ID:
 <CAHk-=wjqkbjL2_BwUYxJxJhdadiw6Zx-Yu_mK3E6P7kG3wSGcQ@mail.gmail.com>
Subject: Re: [PATCH] mm/mincore: allow for making sys_mincore() privileged
To: Andy Lutomirski <luto@amacapital.net>
Cc: Josh Snyder <joshs@netflix.com>, Dominique Martinet <asmadeus@codewreck.org>, 
	Dave Chinner <david@fromorbit.com>, Jiri Kosina <jikos@kernel.org>, 
	Matthew Wilcox <willy@infradead.org>, Jann Horn <jannh@google.com>, 
	Andrew Morton <akpm@linux-foundation.org>, Greg KH <gregkh@linuxfoundation.org>, 
	Peter Zijlstra <peterz@infradead.org>, Michal Hocko <mhocko@suse.com>, Linux-MM <linux-mm@kvack.org>, 
	kernel list <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190116053401.AXEg5clKz7SbYfvUIZbOtNAaybY5GQksCam6vxMkDYM@z>

On Wed, Jan 16, 2019 at 5:25 PM Andy Lutomirski <luto@amacapital.net> wrote:
>
> Something like CAP_DAC_READ_SEARCH might not be crazy.

I agree that it would work. In fact' it's what Jiri's patch basically
did. Except Jiri used CAP_SYS_ADMIN instead.

But that then basically limits it to root (or root-like with
capability masks), which is quite likely to not work in practice all
that well. That's why I wanted to find alternatives.

*Very* few people want to run their databases as root.

Jiri's original patch kind of acknowledged that by making the new test
be conditional, and off by default. So then it's a "only do this for
lockdown mode, because normal people won't find it acceptable".

And I'm not a huge fan of that approach. If you don't protect normal
people, then what's the point, really?

              Linus

