Return-Path: <SRS0=AeVH=PN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E8E29C43387
	for <linux-mm@archiver.kernel.org>; Sat,  5 Jan 2019 23:28:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A40E6222BB
	for <linux-mm@archiver.kernel.org>; Sat,  5 Jan 2019 23:28:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=linux-foundation.org header.i=@linux-foundation.org header.b="Vy1s/+P5"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A40E6222BB
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 551C58E0134; Sat,  5 Jan 2019 18:28:40 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4D8E28E00F9; Sat,  5 Jan 2019 18:28:40 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 37A578E0134; Sat,  5 Jan 2019 18:28:40 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f200.google.com (mail-lj1-f200.google.com [209.85.208.200])
	by kanga.kvack.org (Postfix) with ESMTP id B8BB28E00F9
	for <linux-mm@kvack.org>; Sat,  5 Jan 2019 18:28:39 -0500 (EST)
Received: by mail-lj1-f200.google.com with SMTP id t22-v6so10816122lji.14
        for <linux-mm@kvack.org>; Sat, 05 Jan 2019 15:28:39 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=5UH4pfWyQs4/o8iN9usZb3uixTnpzedXbZLwZju+Xnw=;
        b=NMHkyy9dVThDTJz9uKq39fzvEuhKpJXtjeTHESZQ0xbiv5pOBbuHyGrJVcXpi21c5j
         p0ZurxQURxcj6a3VGfV1oWSYUAhGAaVwZ7LTqL0eCwjbn4SLtxxlzi2xrVciUxSxZCdF
         N1gbOj78PDenbg70Djtdb5XjdH/ylY6cLXBrar8/OIp63WMz68877yMG/MtfGuo43IQZ
         aON2QxsHNOb0gzRBdwijO/nFk75yWuIiw45hA1ZsWkDuOmI0nkDx5ljX3cRPwVmh5UdQ
         90j1W4OVNlGYI8uyMGc7x+KsmfI1ecoqkcYRZZ7FKv2l21FVsuE6f2ndLb42/GEatBxh
         n5lw==
X-Gm-Message-State: AJcUukcL6kDFY19rgO8LaEyr7pmnDUjqWK1g+rMDC/3jzkQwnIPZvu4F
	GiXhrIw/1sJBCKR6RdP1Qp8j/E7JcA4Q7GRBkh5U0OK62hdIIxve8f6K7EZJ7Hoz+/YJRxJRft3
	iwvcsBSYjw7eNaGWL0LdK1lB8qUNvUtmmLBSKcQOj5uz5rST9DT23DIvz9jlv6ClADh6ljjJvzz
	m/13T4RVGCp+gMcdIzJEBgWN093UQPUayalNQdwIyn+diqq1uVLQecTNn/MYDSxmsfCz1tcvxRJ
	bGTTYSJkr1Ca1TFxcgGYrlzb+VR0Q445DEU8WddVflkxoekEThRUi0+mgecInwRQrC0I913SkgN
	kttSnKuCOWt3iU2bLKdS35l8tcH0WlAJc2ja0Y6fsKVwteaggCBPdhPjH2/gA3O7L8m1uHOhpz7
	S
X-Received: by 2002:a2e:9c52:: with SMTP id t18-v6mr26063190ljj.149.1546730919175;
        Sat, 05 Jan 2019 15:28:39 -0800 (PST)
X-Received: by 2002:a2e:9c52:: with SMTP id t18-v6mr26063180ljj.149.1546730918339;
        Sat, 05 Jan 2019 15:28:38 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1546730918; cv=none;
        d=google.com; s=arc-20160816;
        b=qwyt/9SYabCGcn6h8I0yywVJUWAWOMjkzqbzF33ZDkILXsO3wYMQe+/Tk0FFrav8uq
         7Db7Hu42lV1iboOvrv9okQrHEbMvkW3m+8xsAQ7udJ3ZblGwxX6Ltv97dj4Inp4pXvyz
         /DNSJ9+2U/AxTsSvTVbkKvG+NqT3yghk8iKmuPpNmhj2W5zF68jYfGDWR/cfDB23+ujc
         fvFGHtWCGHR89TerVSm75A0iVsKfkl/y5UDKHlPat+Fs0ISdVD+m09B9dM8vrZUQOaY6
         38wQnvD9kGmq4jhi4Itlg4FkSISI+jHcXnB9zRluMNDtxf+plMDr1d889uo/3LC9rSB/
         neyw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=5UH4pfWyQs4/o8iN9usZb3uixTnpzedXbZLwZju+Xnw=;
        b=wxaSCDidB2CXpxSVlzC3Ldyq41ziDQiotGa637vbBfT/IDsjNoYhYL6y+2/txcuBnv
         Jyu1uMEkrml4wavEn8rkiEDDKckEUIluoXKI5KibZmOC/yjHJmbDQTd0qt6nVd4FqqvM
         PWeNyrdokqnTl41Ixurw+eW347TW217l/c4blWBOandbQzrpMa2EIxzUiyqRgTVGXvmY
         zrnRKbdcLnvBHUBCsPvAqy6rx6G2t2v8f7sArgT6LPAx3CMHA97jhvyb1AVlt1EVKhG5
         mbuGkoHqojB5r1Ay6nEX8cS90rVMBHrAJaI8kTgbSmQLOIowjVSWOmUBaW0F3oXpjqGc
         /27A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@linux-foundation.org header.s=google header.b="Vy1s/+P5";
       spf=pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=torvalds@linuxfoundation.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x66-v6sor35490602ljb.20.2019.01.05.15.28.38
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 05 Jan 2019 15:28:38 -0800 (PST)
Received-SPF: pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@linux-foundation.org header.s=google header.b="Vy1s/+P5";
       spf=pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=torvalds@linuxfoundation.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=linux-foundation.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=5UH4pfWyQs4/o8iN9usZb3uixTnpzedXbZLwZju+Xnw=;
        b=Vy1s/+P5NMNsFNOwWt1LLInuk+ntWVFTDJtSxCVKVIIYg1AEnMy9K7h69QPpXAn/rN
         UOhyNwMdL3pZ6oNf2UkegmPg7nFD7KFdUN8yQWn4bRLdByG5iKDgxoDp9kYFnb9VIw38
         l3rvFtZebFJMWoGj3bmBaOAakkxYuwAU1ZZUc=
X-Google-Smtp-Source: ALg8bN7BWj6WrLxjD13TgH3Fatry3gY9IYji4Gbf7r2+jJSsgzZqLJkBBNmkDzarvIwEGM6Dvp4AKQ==
X-Received: by 2002:a2e:5b1d:: with SMTP id p29-v6mr31276172ljb.176.1546730917255;
        Sat, 05 Jan 2019 15:28:37 -0800 (PST)
Received: from mail-lj1-f172.google.com (mail-lj1-f172.google.com. [209.85.208.172])
        by smtp.gmail.com with ESMTPSA id n8-v6sm14216334lji.90.2019.01.05.15.28.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 05 Jan 2019 15:28:36 -0800 (PST)
Received: by mail-lj1-f172.google.com with SMTP id n18-v6so35264490lji.7
        for <linux-mm@kvack.org>; Sat, 05 Jan 2019 15:28:35 -0800 (PST)
X-Received: by 2002:a2e:9983:: with SMTP id w3-v6mr15001293lji.133.1546730915544;
 Sat, 05 Jan 2019 15:28:35 -0800 (PST)
MIME-Version: 1.0
References: <nycvar.YFH.7.76.1901051817390.16954@cbobk.fhfr.pm>
 <CAG48ez2jAp9xkPXQmVXm0PqNrFGscg9BufQRem2UD8FGX-YzPw@mail.gmail.com>
 <CAHk-=whL4sZiM=JcdQAYQvHm7h7xEtVUh+gYGYhoSk4vi38tXg@mail.gmail.com> <CAHk-=wg5Kk+r36=jcGBaLUj+gjopjgiW5eyvkdMqvn0jFkD_iQ@mail.gmail.com>
In-Reply-To: <CAHk-=wg5Kk+r36=jcGBaLUj+gjopjgiW5eyvkdMqvn0jFkD_iQ@mail.gmail.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Sat, 5 Jan 2019 15:28:19 -0800
X-Gmail-Original-Message-ID: <CAHk-=wie+SA1WCQ5nTKgvWyBUdTGxHjAOaoms-=Xu7-wC4j=Ag@mail.gmail.com>
Message-ID:
 <CAHk-=wie+SA1WCQ5nTKgvWyBUdTGxHjAOaoms-=Xu7-wC4j=Ag@mail.gmail.com>
Subject: Re: [PATCH] mm/mincore: allow for making sys_mincore() privileged
To: Jann Horn <jannh@google.com>
Cc: Jiri Kosina <jikos@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, 
	Greg KH <gregkh@linuxfoundation.org>, Peter Zijlstra <peterz@infradead.org>, 
	Michal Hocko <mhocko@suse.com>, Linux-MM <linux-mm@kvack.org>, 
	kernel list <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190105232819.6OsdO__63Y7aCrngmR1KlOxwxH3DR0D1c-e_omgoK8o@z>

On Sat, Jan 5, 2019 at 3:16 PM Linus Torvalds
<torvalds@linux-foundation.org> wrote:
>
> It goes back to forever, it looks like. I can't find a reason.

Our man-pages talk abouit the "without doing IO" part. That may be the
result of our code, though, not the reason for it.

The BSD man-page has other flags, but doesn't describe what "in core"
really means:

     MINCORE_INCORE        Page is in core (resident).

     MINCORE_REFERENCED        Page has been referenced by us.

     MINCORE_MODIFIED        Page has been modified by us.

     MINCORE_REFERENCED_OTHER  Page has been referenced.

     MINCORE_MODIFIED_OTHER    Page has been modified.

     MINCORE_SUPER        Page is part of a large (``super'') page.

but the fact that it has MINCORE_MODIFIED_OTHER does obviously imply
that yes, historically it really did look up the pages elsewhere, not
just in the page tables.

Still, maybe we can get away with just making it be about our own page
tables. That would be lovely.

                 Linus

