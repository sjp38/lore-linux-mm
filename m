Return-Path: <SRS0=jH+M=QO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ACDB6C169C4
	for <linux-mm@archiver.kernel.org>; Thu,  7 Feb 2019 00:27:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 59AD92084D
	for <linux-mm@archiver.kernel.org>; Thu,  7 Feb 2019 00:27:51 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="qcVNBNfz"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 59AD92084D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B5AF98E000A; Wed,  6 Feb 2019 19:27:50 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B0A988E0002; Wed,  6 Feb 2019 19:27:50 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9FABA8E000A; Wed,  6 Feb 2019 19:27:50 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f200.google.com (mail-it1-f200.google.com [209.85.166.200])
	by kanga.kvack.org (Postfix) with ESMTP id 764018E0002
	for <linux-mm@kvack.org>; Wed,  6 Feb 2019 19:27:50 -0500 (EST)
Received: by mail-it1-f200.google.com with SMTP id 135so7858021itb.6
        for <linux-mm@kvack.org>; Wed, 06 Feb 2019 16:27:50 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=QjmxfddQuTfnUk2Jf9d94uGA03f2Ji4tV+lPx6DhrcU=;
        b=D+zbp+oPO1tuzJwL4Qp4cka9KWYUfgVaHy/MwZ6g3ouLvyDuCCqX5pDtIYhQ8e6M8M
         r/a2E1ylxo+C6uUIgX+BHFGWiRvIPTM0yMRSZfdTqvTLkBgFddNs5DxgGXMnGqaMsOCT
         kg9NajpRVDTsE6u958e0+9zt6fvSkIR/LvC2CRXiYrPt8ZBEjYddKxTvqz1x7c4cRCD7
         +Zb16j3oMypJHwMnz1Dni8TDQJgJvFzGqF8UgOYRy5QDP8kvX4wQ36DoQLwSnI36Rn8s
         7GHWyedtjD4UQ7Mb7w+ThHwFE6m8X4Xqp7JOGQLDGf/Og8MO4BETEsrwWW1A0Rjo2j/O
         k7iQ==
X-Gm-Message-State: AHQUAuaiZuv5idHiEef5zTnSdOBzlCnJeytTw1staLZl3PZzEiM3xgXr
	xyuqrpDQBUq75ijg6Smtwpu58XHwg8sW3fsfR8tDRixDrWMo57OTEqst75T6TswW3ma0tOMmrPx
	lXOBZ9fl+gN7LcAbQH5cfvJe2/rGKnNTF/i6YTURKv95RC5yhj7Th6Z7BsUrKBMVxFqbX4guNSp
	eVFgsc9yB9wIRQF9LluyrwnwmWpNtFDPuHvVAwDWAnDOfrQ9Pw1XezCI7caeOJBp1qQAdpzhs6P
	sLtBhVe+bc49/Kb+NcGMDouM/MidwLRskIKEEgaQFL++fBVathKiOUawM1yPDYr6h2DW2CvWVCq
	hrALjW2ZGfewvhTACj7qANvD49mhXsvnPpb1/JS7JhjNEPDn3lYTwSsSqQd8ZLTu7B9pbytGQKc
	P
X-Received: by 2002:a24:10cc:: with SMTP id 195mr3461218ity.178.1549499270224;
        Wed, 06 Feb 2019 16:27:50 -0800 (PST)
X-Received: by 2002:a24:10cc:: with SMTP id 195mr3461201ity.178.1549499269399;
        Wed, 06 Feb 2019 16:27:49 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549499269; cv=none;
        d=google.com; s=arc-20160816;
        b=pQSOwBUEjoDBubXcwpRuPJ4YGP8X9pjUwWa+jX8cOz8nqGsuhRsNW2+iptXhTcoI44
         VkGNZ83WV6O6FA7z+vD0EJwh3kYkbuDY1cBEjLZsH6/KfWeReWSx7ktYjZpTmKEZSBhf
         jg1hxFhJztpAgUnj6O4uX6CVCj2pK0IyC8s02g3nR1WmbOrME1VE13pImYvYLw5wCbya
         zh4KTWu7szyC6Y/b5rq3jPxBZ2Aqc7si+KjyCSxXQ+jodY2+SvLQ3SDP2M4Fd6pNITSx
         CIzIE66NQPr/rE2Le8UOhEpcEkE56201SjAww//Q7iaC++mj9f328uNUUGnn5hx+BAOW
         9nEw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=QjmxfddQuTfnUk2Jf9d94uGA03f2Ji4tV+lPx6DhrcU=;
        b=tK3yApWcG4v5LFKP5OSW8e2Yz0t5c6smoH8Pau5SYHYWc04B3xywvLxB121ZbaT7ul
         Vu3GIiDWdYT80u6PI11+D8ZVbQLYNp9AH/6IIz4VGTvO/zvvt4tVF6HDRZIwPG0dQP2B
         exV9mKLoOHSko+y0sPSCNMgIKtfJTIS6HHso8Xp52WPPAS0N30S3ohImjwNNUo2Xe+GL
         ih8/2Z5raDTmv6zHZAEX5mmrhszyO7SK4ozdYEd+vReXrtpyqn6pKZ+EFBx6B+OdGPe3
         VTGjipkMs1Lz99JWfff2KXmhph4gzptxpTAw+3ZAO6xoK3/WQ8QOoPzHO2tyH1Bf8D1T
         TVRw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=qcVNBNfz;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n11sor3866907ioc.126.2019.02.06.16.27.49
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 06 Feb 2019 16:27:49 -0800 (PST)
Received-SPF: pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=qcVNBNfz;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=QjmxfddQuTfnUk2Jf9d94uGA03f2Ji4tV+lPx6DhrcU=;
        b=qcVNBNfzzoJH0+ab83ciTUxscvQptzm2bXho4/JSv+R7y4fY0GS7aOhx1OzaBRgXRz
         OTSgH6jquOw3sXi7lnso4XQOXACb7ifqnPcI9cz6+41PQyBRIVWLp9uSl2uVWn8mjf6E
         lhCQMe2Xe6LubrCv79nWnF6OiyL2wHi1ZeRSPkTDfbLXOXzdTvFXxFLODOmwXMMzDZIl
         uqyW/c0jUVR2Mtfme1RPUbm+aX+fz65Yx40t4MEj/eZq+p+M/ZqKYclAy9wNYzz+C0iV
         NeQhXfhog91yOksshxUK8ux53laiMA+U0+4x9C2PNqKskoFYeWI1XPcExREmyrVgoMVQ
         rsMA==
X-Google-Smtp-Source: AHgI3IaeNTEkecukVcsQkUXZ1P+6ZkWqh2UWOKyZYicc+FHZha7sf+tg8hCR2dnCfM3UZu3Mibirrday1lovm+NSCww=
X-Received: by 2002:a5e:8f0b:: with SMTP id c11mr1058613iok.116.1549499268955;
 Wed, 06 Feb 2019 16:27:48 -0800 (PST)
MIME-Version: 1.0
References: <631c44cc-df2d-40d4-a537-d24864df0679@nvidia.com>
In-Reply-To: <631c44cc-df2d-40d4-a537-d24864df0679@nvidia.com>
From: Alexander Duyck <alexander.duyck@gmail.com>
Date: Wed, 6 Feb 2019 16:27:37 -0800
Message-ID: <CAKgT0UewZP7AE8o__+6TYeKxERBdbnLP9DSzRApZQjzj9Jpeww@mail.gmail.com>
Subject: Re: No system call to determine MAX_NUMNODES?
To: Ralph Campbell <rcampbell@nvidia.com>
Cc: Linux MM <linux-mm@kvack.org>, longman@redhat.com
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Feb 6, 2019 at 3:13 PM Ralph Campbell <rcampbell@nvidia.com> wrote:
>
> I was using the latest git://git.cmpxchg.org/linux-mmotm.git and noticed
> a new issue compared to 5.0.0-rc5.
>
> It looks like there is no convenient way to query the kernel's value for
> MAX_NUMNODES yet this is used in kernel_get_mempolicy() to validate the
> 'maxnode' parameter to the GET_MEMPOLICY(2) system call.
> Otherwise, EINVAL is returned.
>
> Searching the internet for get_mempolicy yields some references that
> recommend reading /proc/<pid>/status and parsing the line "Mems_allowed:".
>
> Running "cat /proc/self/status | grep Mems_allowed:" I get:
> With 5.0.0-rc5:
> Mems_allowed:   00000000,00000001
> With 5.0.0-rc5-mm1:
> Mems_allowed:   1
> (both kernels were config'ed with CONFIG_NODES_SHIFT=6)
>
> Clearly, there should be a better way to query MAX_NUMNODES like
> sysconf(), sysctl(), or libnuma.

Really we shouldn't need to know that. That just tells us about how
the kernel was built, it doesn't really provide any information about
the layout of the system.

> I searched for the patch that changed /proc/self/status but didn't find it.

The patch you are looking for is located at:
http://lkml.kernel.org/r/1545405631-6808-1-git-send-email-longman@redhat.com

I wonder if we shouldn't look at modifying kernel_get_mempolicy and
the compat call to test for nr_node_ids instead of MAX_NUMNODES since
the rest of the data would be useless anyway.

