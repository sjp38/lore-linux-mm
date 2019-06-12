Return-Path: <SRS0=Ax9E=UL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 496B5C31E44
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 01:09:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 14D0420874
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 01:09:47 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=linux-foundation.org header.i=@linux-foundation.org header.b="gAjfSlHu"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 14D0420874
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 89C896B026B; Tue, 11 Jun 2019 21:09:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8267F6B026C; Tue, 11 Jun 2019 21:09:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 69F1F6B026D; Tue, 11 Jun 2019 21:09:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f71.google.com (mail-lf1-f71.google.com [209.85.167.71])
	by kanga.kvack.org (Postfix) with ESMTP id 023806B026B
	for <linux-mm@kvack.org>; Tue, 11 Jun 2019 21:09:47 -0400 (EDT)
Received: by mail-lf1-f71.google.com with SMTP id j27so2260964lfh.4
        for <linux-mm@kvack.org>; Tue, 11 Jun 2019 18:09:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=SZXVeOYEeW/t6moRL6yl166/GZV1HqW8qo9aOqBVN+Q=;
        b=JXa6/LOZu5pnVKGnh+11gQN6Zo0gFD1g7fWocvtA5xhmYhl24cg1lx7vsmpcgLpN4w
         m56td4sgxWr88TcPd82AOqzJJbk8M38F90/LbsqiZW7Bf+rNZkCNbpRV8QAbD72csh23
         b5X9VwxekqcU7k3Lbz5ypc5wFJ4U8ksCi589JZMF81WjRtr2uLvUHPjDhRhUVo4R0ssM
         hj9sj5ufjRhu83M2ltozRmfZYRrwBCun3cPeyzFW4TvGcAHOYNRLkpa5RIHpxhEB8iXT
         PTnLsTZuV+wSwrxqqIriUAxrm/ZGycwwbZavFFYmO3VjlGhXecZ95nZXG/1id3MYjsoS
         UZKQ==
X-Gm-Message-State: APjAAAV04lSqGpP/+PaaDz5g1+qYRc+w83lSh1CTaxJNI0dA61uyrf6O
	jbHLcw3Y0lNITySihvMYDY/Qn8kJqnB6tNpPexR62Cu45Wli3aFuQUtBAp0r5r0yo2OaztdBt1P
	0wZvK6btvjMUJs55hot3jfnOrxr+rYYC6byGZsER8V3FcxTifXr9RLWgZ8pnUNhQzYg==
X-Received: by 2002:a19:f506:: with SMTP id j6mr15102852lfb.168.1560301786168;
        Tue, 11 Jun 2019 18:09:46 -0700 (PDT)
X-Received: by 2002:a19:f506:: with SMTP id j6mr15102818lfb.168.1560301785236;
        Tue, 11 Jun 2019 18:09:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560301785; cv=none;
        d=google.com; s=arc-20160816;
        b=dLPsTTeLLJPvqTUnCr839/ipyOgWLTFV7dAxSI7E+Arg56T8GxaYwuJMD1LHjDHMj6
         UeU+wFtZVXMkAA37m4ii5rmyiWSrCQpNhu0lMn8x1gvBr0VNFyls3QjPEQFT7O9bmx6u
         afiu2ItKuzh9UU2mI+A70bP2PC3zQfvNlrh+cF4AB2VmoGBNNMwO6sfCP63uYbIXcBla
         FCgLOqJT2QzpCtkgn5EPyeTU6S6SipiOdWZVLZtKFPZrDus2hdAOHPXb1WGbayjWbirf
         p44Y9lIFEo6u4kT58sB03Ia2tICX2Gn7XTHMVN0uhrZVwWzpGBuIwSR8vDXviGSry+ME
         p2+w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=SZXVeOYEeW/t6moRL6yl166/GZV1HqW8qo9aOqBVN+Q=;
        b=T+KDKXTOdXHcwqIsFsAUwQQiZPniznYgComYRIiVyVe808bwip6wXb8HQQPtLYP2+S
         Yi2lU4hIUHEx2ynDGqccbxyGUSb4iA8gT6jPLnIsy4LN+R13NKzTQXafcIf9gBeboBCN
         590VZ2v66xC9oU80MInoj9WJNWnSWEoBJ1aZnCUuotZoW6UYg3e41ZOvYCsr3vu8tENw
         v+7wzvaQADJ2yVf9TW5prtPLh8FW/qHdc6C1FmQicLt9vrLaMkCxi+1KTA4kjcTgvQqP
         hq7PD9R1gWWKDGukQMa7O3j8Ym+EoK250okLz1aQ53X+1vEJSnFgv8VBfWFQmPaq9tOf
         Wglg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@linux-foundation.org header.s=google header.b=gAjfSlHu;
       spf=pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=torvalds@linuxfoundation.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z6sor8731356ljk.17.2019.06.11.18.09.45
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 11 Jun 2019 18:09:45 -0700 (PDT)
Received-SPF: pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@linux-foundation.org header.s=google header.b=gAjfSlHu;
       spf=pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=torvalds@linuxfoundation.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=linux-foundation.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=SZXVeOYEeW/t6moRL6yl166/GZV1HqW8qo9aOqBVN+Q=;
        b=gAjfSlHuLsIpxvb8lF0RyxQXzEhYSHQJnAZ4as99A8GBRPKGt8LtILDEijhajNv2fV
         FXhIx40OUX4WPq1W1eQvis0UNqIoFt7tkihxVZ4QyREYOfVPuleZ/0Zq1i4TWCfQY/NA
         AhmvmJi02EHwj98eCflp9T4F3Jku2HpzQgXkw=
X-Google-Smtp-Source: APXvYqzUMCAb3sGveCpRgIuq7hlU4dtuGeGQ4uaCcoXuElosX+7dR9MrIMxYytuZz5i0EkbJy6NqmQ==
X-Received: by 2002:a05:651c:150:: with SMTP id c16mr134667ljd.193.1560301784353;
        Tue, 11 Jun 2019 18:09:44 -0700 (PDT)
Received: from mail-lf1-f48.google.com (mail-lf1-f48.google.com. [209.85.167.48])
        by smtp.gmail.com with ESMTPSA id f16sm3405810lfc.81.2019.06.11.18.09.40
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Jun 2019 18:09:41 -0700 (PDT)
Received: by mail-lf1-f48.google.com with SMTP id z15so8008427lfh.13
        for <linux-mm@kvack.org>; Tue, 11 Jun 2019 18:09:40 -0700 (PDT)
X-Received: by 2002:ac2:50c4:: with SMTP id h4mr26185312lfm.61.1560301780325;
 Tue, 11 Jun 2019 18:09:40 -0700 (PDT)
MIME-Version: 1.0
References: <20190611144102.8848-1-hch@lst.de> <20190611144102.8848-17-hch@lst.de>
 <1560300464.nijubslu3h.astroid@bobo.none>
In-Reply-To: <1560300464.nijubslu3h.astroid@bobo.none>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Tue, 11 Jun 2019 15:09:24 -1000
X-Gmail-Original-Message-ID: <CAHk-=wjSo+TzkvYnAqrp=eFgzzc058DhSMTPr4-2quZTbGLfnw@mail.gmail.com>
Message-ID: <CAHk-=wjSo+TzkvYnAqrp=eFgzzc058DhSMTPr4-2quZTbGLfnw@mail.gmail.com>
Subject: Re: [PATCH 16/16] mm: pass get_user_pages_fast iterator arguments in
 a structure
To: Nicholas Piggin <npiggin@gmail.com>
Cc: Rich Felker <dalias@libc.org>, "David S. Miller" <davem@davemloft.net>, Christoph Hellwig <hch@lst.de>, 
	James Hogan <jhogan@kernel.org>, Paul Burton <paul.burton@mips.com>, 
	Yoshinori Sato <ysato@users.sourceforge.jp>, Andrey Konovalov <andreyknvl@google.com>, 
	Benjamin Herrenschmidt <benh@kernel.crashing.org>, Khalid Aziz <khalid.aziz@oracle.com>, 
	Linux List Kernel Mailing <linux-kernel@vger.kernel.org>, linux-mips@vger.kernel.org, 
	Linux-MM <linux-mm@kvack.org>, linuxppc-dev@lists.ozlabs.org, 
	Linux-sh list <linux-sh@vger.kernel.org>, Michael Ellerman <mpe@ellerman.id.au>, 
	Paul Mackerras <paulus@samba.org>, sparclinux@vger.kernel.org, 
	"the arch/x86 maintainers" <x86@kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jun 11, 2019 at 2:55 PM Nicholas Piggin <npiggin@gmail.com> wrote:
>
> What does this do for performance? I've found this pattern can be
> bad for store aliasing detection.

I wouldn't expect it to be noticeable, and the lack of argument
reloading etc should make up for it. Plus inlining makes it a
non-issue when that happens.

But I guess we could also at least look at using "restrict", if that
ends up helping. Unlike the completely bogus type-based aliasing rules
(that we disable because I think the C people were on some bad bad
drugs when they came up with them), restricted pointers are a real
thing that makes sense.

That said, we haven't traditionally used it, and I don't know how much
it helps gcc. Maybe gcc ignores it entirely? S

               Linus

