Return-Path: <SRS0=CIMh=QT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2863BC4151A
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 22:39:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D73F0222BB
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 22:39:17 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="fCfFjWCV"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D73F0222BB
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7927A8E0002; Tue, 12 Feb 2019 17:39:17 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 719FC8E0001; Tue, 12 Feb 2019 17:39:17 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5E2CE8E0002; Tue, 12 Feb 2019 17:39:17 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f199.google.com (mail-vk1-f199.google.com [209.85.221.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2C52A8E0001
	for <linux-mm@kvack.org>; Tue, 12 Feb 2019 17:39:17 -0500 (EST)
Received: by mail-vk1-f199.google.com with SMTP id e10so132097vke.20
        for <linux-mm@kvack.org>; Tue, 12 Feb 2019 14:39:17 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=YFMKNvnJ3kQYFBT3u+6m2xpocwP0rFyQ6m2jTIkI53g=;
        b=gucPh4Rlg9zRq7lNawuxHU+mYzLzG26sHCKCOONxXSfl6/rgPmICqgpmE1ybXJg4Yl
         Gch7K94fbi2kJMuNNfi049sjIZXqlrcs2eVkGY78hTmGt1J4PbE31DcznWL0vKjQ5K4v
         tyfQdzEjlLyPE+mKGlw229MsQkb40eORfskOpipKJu/Nligiy69qDHRG7IVVhyCnkoTq
         5hGYCSAkQmj2/bTkjwELJYs+G6g6Q3ui7KNSddg+ITllmZy+Gad+NO9tt28cddhXK3nv
         wxikjA4YBLtbXw++OUpflcgfCr+jo2SG7d/10BnCgQaA2KmLS9SkeRvRpk3Ix36TF044
         tmcg==
X-Gm-Message-State: AHQUAuYZ1nxfAsqLAqUAaqGPjKDZkpldqf+aeVmF9ui/Pz9o+1xK+RoS
	6K5rCTOdFGtZfoseMH725KzpX01VqSJuzcpLE8e62+zN1r/KplrypYOmEC7GxJJWZXKYelxiJUd
	9SYKJzErTOpn4BPr6/PUle9ZSURCL7ydIL/l87eJwhAK+j+kM42dhHhpLQ9KeOXekeYbt6b7Xud
	hDGg8I30LzQNqcv1p+JryoqxXxXjBs8dCJfY+bu1THbpX555fmnvVcbZizL7ShlkAzi8QOgdA91
	RJ+Cwbfw3RM9SQj+XFw4b5Y2w5SadU7gPdyqeBcExDCxNaITiqApDeHQ9o1kuRqWvMRSalOS5YS
	bGpDMZebMPSyjR6fPjs7q4uZcfn44woW2TpAaDVFn8J2raAUkorm3TgtqoNfncL0+/a9tZ3P5oe
	b
X-Received: by 2002:a1f:998d:: with SMTP id b135mr2728192vke.44.1550011156824;
        Tue, 12 Feb 2019 14:39:16 -0800 (PST)
X-Received: by 2002:a1f:998d:: with SMTP id b135mr2728171vke.44.1550011156215;
        Tue, 12 Feb 2019 14:39:16 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550011156; cv=none;
        d=google.com; s=arc-20160816;
        b=rjTA01biG/duf6Pp0SDA+ber3/V0Pii8+fW3AJwJ2vq17LuGsTr8pmf7a05AgKs3mk
         HuMN0xaignolXnh1+lezSvzTRxcQ5H0dvWdRlGr+KIiF8XTeaUww3K0rUuBYPIKgOX90
         nNEm7JEYrkGzUDqEb5h2xUxC/1pxmURU6WYck+0UQwtOIT3cDtsRExbY474Azd7hsT+x
         88xSYgIwaPB46FdA6nY772iiMrfk67kqd1KI0cMBah3BekoBmtLBg1Q+9kFPgNk8Lvy0
         H2uRi4yqfiWMOGiIDcAGf7I/ROCJfwCmGZ+IvyXuG90rJLTdR9b8ppI6EKZiT8Z3NRsQ
         72wQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=YFMKNvnJ3kQYFBT3u+6m2xpocwP0rFyQ6m2jTIkI53g=;
        b=vs1eWpRb1QFpidZQjVffbZsno2muXKBctcz6NuX9ttOYwyIhk0XFyZB8nxsqxccncX
         HfSy6ugjyFK0MstS1vawi/QNmBI2MOWVRjig7M4kNidjmCEGAJg/vzU37y1uRkvJfJcB
         Y9ItUPPzr3eMdJ+snpDNfznV+utQtnCO4Cade/TPNaI0z4+VLy3Kp2dp/W2WMrHkBBKA
         7UCGXiXAeF5BGTJtI0bUeVr2U3pFZwC/nFfmGzd2gvWH9tTz9colWzqpmthlBPhwMzEt
         cipsghjPL9ym/Vy5zkcGsX2uW1I1EEG0/dwBcVc/YTtNuVhsCMPdxe7jQcRsizjjSgM2
         +eQA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=fCfFjWCV;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v84sor9011759vsc.45.2019.02.12.14.39.16
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 12 Feb 2019 14:39:16 -0800 (PST)
Received-SPF: pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=fCfFjWCV;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chromium.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=YFMKNvnJ3kQYFBT3u+6m2xpocwP0rFyQ6m2jTIkI53g=;
        b=fCfFjWCVZvK//Azw02gHCq2Wf+TZyzQo67PjdK4cZacIFv71S2Z88FtQXX3fKTBpKP
         09egXjQE+WgB9m24FrKqUeXC9Wmv7R1TozcnA7aWOgsJazvsA8JJftiYgf64Zajp4I0D
         vPdV4Vxq+YQkzTFZITS1EP8feXnIFOX9/9N+s=
X-Google-Smtp-Source: AHgI3IaKbnhoedGyV6v5cXQqlN1U3LKxtJ5BTBplI/EiXaeBkXavBXEad6MEVtOvjZfA49i9xuLSbQ==
X-Received: by 2002:a67:ee43:: with SMTP id g3mr2631008vsp.192.1550011155439;
        Tue, 12 Feb 2019 14:39:15 -0800 (PST)
Received: from mail-vs1-f47.google.com (mail-vs1-f47.google.com. [209.85.217.47])
        by smtp.gmail.com with ESMTPSA id q193sm11875047vsd.0.2019.02.12.14.39.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Feb 2019 14:39:14 -0800 (PST)
Received: by mail-vs1-f47.google.com with SMTP id z18so221836vso.7
        for <linux-mm@kvack.org>; Tue, 12 Feb 2019 14:39:14 -0800 (PST)
X-Received: by 2002:a67:eb4a:: with SMTP id x10mr2523974vso.172.1550011153602;
 Tue, 12 Feb 2019 14:39:13 -0800 (PST)
MIME-Version: 1.0
References: <cover.1549927666.git.igor.stoppa@huawei.com> <CAGXu5j+n3ky2dOe4F+VyneQsM4VJbGPUw+DO55NkxxPhKzKHag@mail.gmail.com>
 <25bf3c63-c54c-f7ea-bec1-996a2c05d997@gmail.com> <CAGXu5jLqmYRUVLb7-jPsN4onO5UNH+D6qOF=9TOiVjJa-=DnZQ@mail.gmail.com>
 <CAH2bzCRZ5xYOT0R8piqZx4mSGj1_8fNG=Ce4UU8i6F7mYD9m9Q@mail.gmail.com>
 <CAGXu5jLRJZuWjnwEuK=7AMeCrj-eioVGksPL9dE9pbzHM=+Rmg@mail.gmail.com> <29cd9541-9af2-fc1c-c264-f4cb9c29349a@gmail.com>
In-Reply-To: <29cd9541-9af2-fc1c-c264-f4cb9c29349a@gmail.com>
From: Kees Cook <keescook@chromium.org>
Date: Tue, 12 Feb 2019 14:39:02 -0800
X-Gmail-Original-Message-ID: <CAGXu5jJyWb7aTJpDfBPD3GqMmNaJVT0pajdrPV93xnLoOa=0Vw@mail.gmail.com>
Message-ID: <CAGXu5jJyWb7aTJpDfBPD3GqMmNaJVT0pajdrPV93xnLoOa=0Vw@mail.gmail.com>
Subject: Re: [RFC PATCH v4 00/12] hardening: statically allocated protected memory
To: Igor Stoppa <igor.stoppa@gmail.com>
Cc: Igor Stoppa <igor.stoppa@huawei.com>, Ahmed Soliman <ahmedsoliman@mena.vt.edu>, 
	linux-integrity <linux-integrity@vger.kernel.org>, 
	Kernel Hardening <kernel-hardening@lists.openwall.com>, Linux-MM <linux-mm@kvack.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Feb 11, 2019 at 11:09 PM Igor Stoppa <igor.stoppa@gmail.com> wrote:
> wr_assign() does just that.
>
> However, reading again your previous mails, I realize that I might have
> misinterpreted what you were suggesting.
>
> If the advice is to have also a default memset_user() which relies on
> put_user(), but do not activate the feature by default for every
> architecture, I definitely agree that it would be good to have it.
> I just didn't think about it before.

Yeah, I just mean you could have an arch-agnostic memset_user() implementation.

> But I now realize that most likely you were just suggesting to have
> full, albeit inefficient default support and then let various archs
> review/enhance it. I can certainly do this.

Right.

> Regarding testing I have a question: how much can/should I lean on qemu?
> In most cases the MMU might not need to be fully emulated, so I wonder
> how well qemu-based testing can ensure that real life scenarios will work.

I think qemu lets you know if it works (kvm is using the real MMU),
and baremetal will give you more stable performance numbers.

-- 
Kees Cook

