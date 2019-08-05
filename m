Return-Path: <SRS0=3S0K=WB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1D91AC433FF
	for <linux-mm@archiver.kernel.org>; Mon,  5 Aug 2019 17:15:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B7A6920880
	for <linux-mm@archiver.kernel.org>; Mon,  5 Aug 2019 17:15:00 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="JjTRgPB+"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B7A6920880
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 552896B0005; Mon,  5 Aug 2019 13:15:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 503D26B0006; Mon,  5 Aug 2019 13:15:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3F2556B0007; Mon,  5 Aug 2019 13:15:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f71.google.com (mail-io1-f71.google.com [209.85.166.71])
	by kanga.kvack.org (Postfix) with ESMTP id 20A816B0005
	for <linux-mm@kvack.org>; Mon,  5 Aug 2019 13:15:00 -0400 (EDT)
Received: by mail-io1-f71.google.com with SMTP id f22so92927518ioh.22
        for <linux-mm@kvack.org>; Mon, 05 Aug 2019 10:15:00 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=BaGEBCCvHgLEeEM0jkTTKpXw1mRgMNiOlwrLO1Ss3pE=;
        b=Eb0OYGJRm1UENeQhxaSqpZ1c3ISuVuLwYX0yrPJ/VkZPxhSPrDC/LnLG0nHZfcnRh/
         i3SYI4lYVrMeNZEKa9rAOUxWTxGebssMhaEv5BH4MLQi4QFJZs+kIc3hGQMe7zDX9Gdw
         ug2Thzo47sKTnqq5ml2MvKmqH9tX0UAw8QvTdrMAVsrdI9D4gu5Brrvl22iw7jNkrROd
         EJU3xXVrFciFpB40w1WvWv/y0yzShH5KK46oIH0CxiP+lCBd6yd84jiD35zaUKu3e9lq
         PX0sAgG5mOZoqA4dA7xYokZBqE7FECikmXxIxIfJrVXXVSF5tmniAmDFYDBy1l+bJT97
         fzUQ==
X-Gm-Message-State: APjAAAUz4FrNikuQ7E8hxabvSCacgMP2upn5Ov9VOtEl+3tWBHZDUKtc
	Bxby3f+MSIoUjFiYZWX3uZMLIheIubThhSLC3td3l8M8LjrL2b7+WyQNqvcQvhMTjW0vjDnZnO+
	so/sl2etqupDeVxIkJwua7A3VLFL/v2awcix3xwiveftfXpJv45nsiKFtm4ZgBHeo2Q==
X-Received: by 2002:a6b:90c1:: with SMTP id s184mr13887976iod.244.1565025299839;
        Mon, 05 Aug 2019 10:14:59 -0700 (PDT)
X-Received: by 2002:a6b:90c1:: with SMTP id s184mr13887918iod.244.1565025299079;
        Mon, 05 Aug 2019 10:14:59 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565025299; cv=none;
        d=google.com; s=arc-20160816;
        b=FN2RYgFBEjv66RKdeGlNbJLIU7Nt71q/ps3x8KGgcMBprvwaqzwEzjqa05j4W+YhP2
         errxneBDb3ojeJ5q9xQgLv40L83OqP7H6F4DhBirL1SQYYNxLXrH9anW9tyXfRIv8DGL
         W6joHguf41m4AM/XtbY402/XxD/5eVMr/3B86/uCEPksefL9dK61aswz7r1A8eim06eh
         PCwf4b78kP9vAyjNDaKFdlZvxgcLcXlTCNTd9WvCu94ZyyRB2QygEBlVwZri9c3BwdYJ
         U5/kuElFKeRix3rxV1RSaNosI1wD4XhD2OXsbfAP/sS8UsLYCv1X0uaGEPrJTFKLsus6
         OeQA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=BaGEBCCvHgLEeEM0jkTTKpXw1mRgMNiOlwrLO1Ss3pE=;
        b=ZXOexGgCE9EqF5HzP/fMXHdW3p1wGPT/3lf3fGg5q7D4uYnpa8x4TYw12TcfV1k/xG
         d/DCEp+qXzQcsiGeRhqzkbA5Gk/p7ALzqlIrWDoNCDzJ+2w3Ot7JVwxQ/ntveYxRCeLt
         b90eb6YSYH6bMTUj69MNU7S6WyKGRkLFgcx4xMw+BDpTPMbW+7yaWjkWWFfNaSibBsHF
         oMPizWB2JFexRRs8nOL8owIdww50+XD7jRS8upWT8NMXhz295AVRWD4Fnlv8mnwuhmrc
         5jklk6AHzDkU43w7x2fXwJlxzZDpM+Z6jXNQ5eEQljxhwU4V6jUuSJ002ifHsw1nbBPu
         MDOQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=JjTRgPB+;
       spf=pass (google.com: domain of mikhail.v.gavrilov@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mikhail.v.gavrilov@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r3sor46976174jai.10.2019.08.05.10.14.59
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 05 Aug 2019 10:14:59 -0700 (PDT)
Received-SPF: pass (google.com: domain of mikhail.v.gavrilov@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=JjTRgPB+;
       spf=pass (google.com: domain of mikhail.v.gavrilov@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mikhail.v.gavrilov@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=BaGEBCCvHgLEeEM0jkTTKpXw1mRgMNiOlwrLO1Ss3pE=;
        b=JjTRgPB+SGUpcW+V3EtO6gL93HfTBnpBBM2vny9l8TcyUi5UkRHiDr4pq4BfGTxDm9
         6qlTZ0bf4iNdZYF/tA9gMQDaHOKsCk0kkQ7sG+UIrccFLU970xNtlgGQHFVJcps/j+6g
         pqTNufrlLPZqx2gH19poXxTiOgxkMlpjPxz6BtEWFFxrBwuZh6iaB1o3V6sVX56+ylGU
         2pszfJRnRuLfd3ez1yKDNCqpKFzfIMt7ScpsAppPN5dSa1UtA4JwMl67ZKOiCjpjyKH8
         E+W9yaFIGavidj9gdLW170u1mu/Nq9jerve9QF+3GHtgQvR1fhS0D2sNraatYXX5C9Xm
         FQIA==
X-Google-Smtp-Source: APXvYqyYq8Rtn/DMdIS94LKA7/HHkb6Gd4UKz+pVmoP+PdIkZvkKoQxrBDinOQiL8GBtZH952dHVKUmsuGzP5lURYG4=
X-Received: by 2002:a02:1607:: with SMTP id a7mr623447jaa.123.1565025298399;
 Mon, 05 Aug 2019 10:14:58 -0700 (PDT)
MIME-Version: 1.0
References: <20190805032114.8740-1-hdanton@sina.com>
In-Reply-To: <20190805032114.8740-1-hdanton@sina.com>
From: Mikhail Gavrilov <mikhail.v.gavrilov@gmail.com>
Date: Mon, 5 Aug 2019 22:14:47 +0500
Message-ID: <CABXGCsM3-Ax0jsLS=QCM6m331onGXLEcfmmc_kLdqgOLzMSj9Q@mail.gmail.com>
Subject: Re: The issue with page allocation 5.3 rc1-rc2 (seems drm culprit here)
To: Hillf Danton <hdanton@sina.com>
Cc: Dave Airlie <airlied@gmail.com>, "Deucher, Alexander" <Alexander.Deucher@amd.com>, 
	"Koenig, Christian" <Christian.Koenig@amd.com>, Harry Wentland <harry.wentland@amd.com>, 
	amd-gfx list <amd-gfx@lists.freedesktop.org>, 
	Linux Memory Management List <linux-mm@kvack.org>, 
	Linux List Kernel Mailing <linux-kernel@vger.kernel.org>, dri-devel <dri-devel@lists.freedesktop.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 5 Aug 2019 at 08:21, Hillf Danton <hdanton@sina.com> wrote:
>
>
>
> Try to fix the failure above using vmalloc + kmalloc.
>
> --- a/drivers/gpu/drm/amd/display/dc/core/dc.c
> +++ b/drivers/gpu/drm/amd/display/dc/core/dc.c
> @@ -1174,8 +1174,12 @@ struct dc_state *dc_create_state(struct
>         struct dc_state *context = kzalloc(sizeof(struct dc_state),
>                                            GFP_KERNEL);
>
> -       if (!context)
> -               return NULL;
> +       if (!context) {
> +               context = kvzalloc(sizeof(struct dc_state),
> +                                          GFP_KERNEL);
> +               if (!context)
> +                       return NULL;
> +       }
>         /* Each context must have their own instance of VBA and in order to
>          * initialize and obtain IP and SOC the base DML instance from DC is
>          * initially copied into every context
> @@ -1195,8 +1199,13 @@ struct dc_state *dc_copy_state(struct dc
>         struct dc_state *new_ctx = kmemdup(src_ctx,
>                         sizeof(struct dc_state), GFP_KERNEL);
>
> -       if (!new_ctx)
> -               return NULL;
> +       if (!new_ctx) {
> +               new_ctx = kvmalloc(sizeof(*new_ctx), GFP_KERNEL);
> +               if (new_ctx)
> +                       *new_ctx = *src_ctx;
> +               else
> +                       return NULL;
> +       }
>
>         for (i = 0; i < MAX_PIPES; i++) {
>                         struct pipe_ctx *cur_pipe = &new_ctx->res_ctx.pipe_ctx[i];
> @@ -1230,7 +1239,7 @@ static void dc_state_free(struct kref *k
>  {
>         struct dc_state *context = container_of(kref, struct dc_state, refcount);
>         dc_resource_state_destruct(context);
> -       kfree(context);
> +       kvfree(context);
>  }
>
>  void dc_release_state(struct dc_state *context)
> --

Unfortunately couldn't check this patch because, with the patch, the
kernel did not compile.
Here is compile error messages:

drivers/gpu/drm/amd/amdgpu/../display/dc/core/dc.c: In function
'dc_create_state':
drivers/gpu/drm/amd/amdgpu/../display/dc/core/dc.c:1178:13: error:
implicit declaration of function 'kvzalloc'; did you mean 'kzalloc'?
[-Werror=implicit-function-declaration]
 1178 |   context = kvzalloc(sizeof(struct dc_state),
      |             ^~~~~~~~
      |             kzalloc
drivers/gpu/drm/amd/amdgpu/../display/dc/core/dc.c:1178:11: warning:
assignment to 'struct dc_state *' from 'int' makes pointer from
integer without a cast [-Wint-conversion]
 1178 |   context = kvzalloc(sizeof(struct dc_state),
      |           ^
drivers/gpu/drm/amd/amdgpu/../display/dc/core/dc.c: In function 'dc_copy_state':
drivers/gpu/drm/amd/amdgpu/../display/dc/core/dc.c:1203:13: error:
implicit declaration of function 'kvmalloc'; did you mean 'kmalloc'?
[-Werror=implicit-function-declaration]
 1203 |   new_ctx = kvmalloc(sizeof(*new_ctx), GFP_KERNEL);
      |             ^~~~~~~~
      |             kmalloc
drivers/gpu/drm/amd/amdgpu/../display/dc/core/dc.c:1203:11: warning:
assignment to 'struct dc_state *' from 'int' makes pointer from
integer without a cast [-Wint-conversion]
 1203 |   new_ctx = kvmalloc(sizeof(*new_ctx), GFP_KERNEL);
      |           ^
drivers/gpu/drm/amd/amdgpu/../display/dc/core/dc.c: In function 'dc_state_free':
drivers/gpu/drm/amd/amdgpu/../display/dc/core/dc.c:1242:2: error:
implicit declaration of function 'kvfree'; did you mean 'kzfree'?
[-Werror=implicit-function-declaration]
 1242 |  kvfree(context);
      |  ^~~~~~
      |  kzfree
cc1: some warnings being treated as errors
make[4]: *** [scripts/Makefile.build:274:
drivers/gpu/drm/amd/amdgpu/../display/dc/core/dc.o] Error 1
make[4]: *** Waiting for unfinished jobs....
make[3]: *** [scripts/Makefile.build:490: drivers/gpu/drm/amd/amdgpu] Error 2
make[3]: *** Waiting for unfinished jobs....
make: *** [Makefile:1084: drivers] Error 2


--
Best Regards,
Mike Gavrilov.

