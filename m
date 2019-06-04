Return-Path: <SRS0=7ZCb=UD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3CA14C282CE
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 16:42:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E7D2C23CE7
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 16:42:09 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="UwpWwJdg"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E7D2C23CE7
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7CB396B026E; Tue,  4 Jun 2019 12:42:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7BB056B0271; Tue,  4 Jun 2019 12:42:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 65BA06B0270; Tue,  4 Jun 2019 12:42:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f199.google.com (mail-it1-f199.google.com [209.85.166.199])
	by kanga.kvack.org (Postfix) with ESMTP id 474AB6B026E
	for <linux-mm@kvack.org>; Tue,  4 Jun 2019 12:42:09 -0400 (EDT)
Received: by mail-it1-f199.google.com with SMTP id u10so488136itb.5
        for <linux-mm@kvack.org>; Tue, 04 Jun 2019 09:42:09 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=3JDY6OHGY+NE0N4DeZuVbYe18iFYfWNpGGDsycjMC2g=;
        b=eBolizSLTkJqykIV8x1aCv2QZ6sviAp+eFKyYp/BLRAq5nXSuoaCGgvbLQjUwnefwG
         NB82NCxQCFeR1CaZY8sjr2/+t6oVf584vkQPrd+FWpyWpljRpXswjzKDNHp3pTKreXZB
         X/V0+YdqTEInCKYzCt4Z0A0FuqsScYTMPI7sXeWUKZ2JjJIITHb2pEUQdVX5TidIy1kD
         862BOj9vKOzrw/SSlztU0zWduNqK7/5tP1RmHM5FfwwY2E+EJT4uGhu5H8cntkUYjscW
         SxHpBp8IiAGY9bMYxSutnmUCIbUZ2Up/0jUDjDr2Bc/lAnzHkd9LGQLAQCUp1VoiNeIx
         uPrw==
X-Gm-Message-State: APjAAAVWDxMwzI4NOex3iBJQRRvfpoURoroIL14rtxNpJTrawE/3dez4
	shdCdo2FOgZDRuEaC9QCe/98yJ5sHpxmlGPREucIu42R/6956Le8xMMtMGV7UJHTO4eJS5+DQkk
	Zd6kkBth+XoxpCA/+fIJ7Ah6xDvRNBcIL06aHwaTFkd4nLVjs1ioxOQO0WE1rYQlKZA==
X-Received: by 2002:a5d:8702:: with SMTP id u2mr15943271iom.228.1559666529071;
        Tue, 04 Jun 2019 09:42:09 -0700 (PDT)
X-Received: by 2002:a5d:8702:: with SMTP id u2mr15943226iom.228.1559666528360;
        Tue, 04 Jun 2019 09:42:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559666528; cv=none;
        d=google.com; s=arc-20160816;
        b=ms45yXWaecZZs4rX6MrhJel4e4PLpGF/m/upYZa7Kpd1e3FT09496dgvwe9qpvQfSX
         FqaA6eDJZmMhdH5sAj5iIxd9JB5Mtuse9JrU4+31kqrZ8VUyxQOt0C9zhejydtvJWGzp
         SbpImmweuFRcO+eStMQOXcc37Me51zbYXc1m5JWEyzui6ShU9Q93jJmE6Qpxt8kt91qx
         mRXnvY85IvwSD4hEVMnwavY3E9pSlUO8oMDPd3VEDZAQAoovnQrsUsqvdvyYrwxQljwD
         njh039i87638hYNH9qWJznLsPIFHcPPpJXiSDhit5vhUL0iR2JWTzpvs/IAAkpRFW7eg
         63GA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=3JDY6OHGY+NE0N4DeZuVbYe18iFYfWNpGGDsycjMC2g=;
        b=lPzCJu9QlyJzi+RJcgFbWTqbB7EglHoj5775MtTeDAfmKBKHD+XTReJXq42IJEv6Kg
         vq7vXLa+FWbtpxXl4h5I+x+LY3fMSP8MjdAz5OT09boThRckAsB1eO8wEz5z054u4hUR
         B59s6P9/M1q3TSp1ild1qgaammBz8kRfyXPz3XE9T4c0DoSFFywrZ3ToqO4fgIjs98cv
         P7XpuNQ8zHS8cwUJ2s6giFxuVunbKSGoAAjAKaF4ONgjjG5LDs8oknD49VwpVIUn09yP
         N9/oID8Y/NkqvHB04q4vTWul+SfYACvfvAA9+lIOckEnUIDZWYkHRvhaHoaLThJIawfF
         /fIw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=UwpWwJdg;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j184sor2941480iof.140.2019.06.04.09.42.08
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 04 Jun 2019 09:42:08 -0700 (PDT)
Received-SPF: pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=UwpWwJdg;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=3JDY6OHGY+NE0N4DeZuVbYe18iFYfWNpGGDsycjMC2g=;
        b=UwpWwJdg390UZHtTns/rfTWthrTcGew4Fy9tGkbLx8KjLIFbnCG9jwC8uKqME2sGrF
         bxK/yRBAq3MGq7d1fhd/UrFby6JZmilGdyMximDEXCMVeehCUbNaUOm8LQT8kJu7s9jl
         1WBXFxHNJq+D35c04YNdcAxDDW5UA3m+yRtaJmCoJDarasrjCIw/srfNIg3AIrVVX2Q+
         jmxRZDxLSIQDXFYJQPRuRboIHhDGSkMXfmW6qRkdZuUFkpAhHgKYEsT5Gqa/rmEtt2/a
         Laf/J7G/1bnGOtKjkGb2owo6yrha7zJpq3OuHs7INOAiXZycoThXwcx5v4X1AIukhP+B
         z5Aw==
X-Google-Smtp-Source: APXvYqzcpmp0gznwMtOQmK24TPSREyjaVEIx3jTVWsSszTjRWj0MU/DJg3bP7iAb59r6WIoIIpPgJaT3Hvtj1qgxSog=
X-Received: by 2002:a5d:8f86:: with SMTP id l6mr16490098iol.97.1559666527982;
 Tue, 04 Jun 2019 09:42:07 -0700 (PDT)
MIME-Version: 1.0
References: <20190603170306.49099-1-nitesh@redhat.com> <20190603170432.1195-1-nitesh@redhat.com>
In-Reply-To: <20190603170432.1195-1-nitesh@redhat.com>
From: Alexander Duyck <alexander.duyck@gmail.com>
Date: Tue, 4 Jun 2019 09:41:56 -0700
Message-ID: <CAKgT0UeRzF24WeVkTN2WW41iKSUpXpZbpD55-g=MBHf814RV+A@mail.gmail.com>
Subject: Re: [QEMU PATCH] KVM: Support for page hinting
To: Nitesh Narayan Lal <nitesh@redhat.com>
Cc: kvm list <kvm@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, 
	linux-mm <linux-mm@kvack.org>, Paolo Bonzini <pbonzini@redhat.com>, lcapitulino@redhat.com, 
	pagupta@redhat.com, wei.w.wang@intel.com, 
	Yang Zhang <yang.zhang.wz@gmail.com>, Rik van Riel <riel@surriel.com>, 
	David Hildenbrand <david@redhat.com>, "Michael S. Tsirkin" <mst@redhat.com>, dodgen@google.com, 
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, dhildenb@redhat.com, 
	Andrea Arcangeli <aarcange@redhat.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 3, 2019 at 10:04 AM Nitesh Narayan Lal <nitesh@redhat.com> wrote:
>
> Enables QEMU to call madvise on the pages which are reported
> by the guest kernel.
>
> Signed-off-by: Nitesh Narayan Lal <nitesh@redhat.com>
> ---
>  hw/virtio/trace-events                        |  1 +
>  hw/virtio/virtio-balloon.c                    | 85 +++++++++++++++++++
>  include/hw/virtio/virtio-balloon.h            |  2 +-
>  include/qemu/osdep.h                          |  7 ++
>  .../standard-headers/linux/virtio_balloon.h   |  1 +
>  5 files changed, 95 insertions(+), 1 deletion(-)

<snip>

> diff --git a/include/qemu/osdep.h b/include/qemu/osdep.h
> index 840af09cb0..4d632933a9 100644
> --- a/include/qemu/osdep.h
> +++ b/include/qemu/osdep.h
> @@ -360,6 +360,11 @@ void qemu_anon_ram_free(void *ptr, size_t size);
>  #else
>  #define QEMU_MADV_REMOVE QEMU_MADV_INVALID
>  #endif
> +#ifdef MADV_FREE
> +#define QEMU_MADV_FREE MADV_FREE
> +#else
> +#define QEMU_MADV_FREE QEMU_MADV_INVALID
> +#endif

Is there a specific reason for making this default to INVALID instead
of just using DONTNEED? I ran into some issues as my host kernel
didn't have support for MADV_FREE in the exported kernel headers
apparently so I was getting no effect. It seems like it would be
better to fall back to doing DONTNEED instead of just disabling the
functionality all together.

>  #elif defined(CONFIG_POSIX_MADVISE)
>
> @@ -373,6 +378,7 @@ void qemu_anon_ram_free(void *ptr, size_t size);
>  #define QEMU_MADV_HUGEPAGE  QEMU_MADV_INVALID
>  #define QEMU_MADV_NOHUGEPAGE  QEMU_MADV_INVALID
>  #define QEMU_MADV_REMOVE QEMU_MADV_INVALID
> +#define QEMU_MADV_FREE QEMU_MADV_INVALID

Same here. If you already have MADV_DONTNEED you could just use that
instead of disabling the functionality.

>  #else /* no-op */
>
> @@ -386,6 +392,7 @@ void qemu_anon_ram_free(void *ptr, size_t size);
>  #define QEMU_MADV_HUGEPAGE  QEMU_MADV_INVALID
>  #define QEMU_MADV_NOHUGEPAGE  QEMU_MADV_INVALID
>  #define QEMU_MADV_REMOVE QEMU_MADV_INVALID
> +#define QEMU_MADV_FREE QEMU_MADV_INVALID
>
>  #endif
>

