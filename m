Return-Path: <SRS0=KVn2=RQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B1372C43381
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 06:42:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5FE5F2070D
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 06:42:38 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="EEFjcIr+"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5FE5F2070D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EF0468E0003; Wed, 13 Mar 2019 02:42:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E9F7D8E0002; Wed, 13 Mar 2019 02:42:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D681F8E0003; Wed, 13 Mar 2019 02:42:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f70.google.com (mail-yw1-f70.google.com [209.85.161.70])
	by kanga.kvack.org (Postfix) with ESMTP id AB4AA8E0002
	for <linux-mm@kvack.org>; Wed, 13 Mar 2019 02:42:37 -0400 (EDT)
Received: by mail-yw1-f70.google.com with SMTP id t9so1102553ywe.19
        for <linux-mm@kvack.org>; Tue, 12 Mar 2019 23:42:37 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=ebpiJgvlhqvcNtW6hg58h6gWxH/SKgRPsgHGklpT0Qg=;
        b=b6elUKHbUQHSUzoxI9aECQ+bWGxjGkzokyEpMHz4N0YLcLyNNtKyAfSwWldn7ZLcEJ
         P4c758Q8KVF3p4fqcL+bBFncU1H+jt6/0BEJQeGRFMvf5abKOTCf4FgDXT++fqL3kWRm
         mKfEP2dHnEm7JJRUBRs5DJEA0ECS833zN3gdK7dAI7VABT1FN3ZtRB7sew7IwhZcVGYX
         6SSmpXxNme6w1eQfts9iaWb3udpj07K+62xb40tGVk+XKkEnBhJxGtR4474WA+SBh8WK
         jvCpBjecWWX2xttQadZ5OTone1xJaBITkVS1jDhiKKrcxaRyHC2w0aO7x3I3Lj9Q/o7L
         8t7Q==
X-Gm-Message-State: APjAAAW0qFOOMK8jKOuDu49eZ1lpEkfqvVyLW/hMgYWvN27i3cRYa9HL
	1inTaffklpyBHgF1mAFnRYCdLBYYXmiokFpglWuESfgcEdicdWchudNE9LPYotuy/wjHBpsatcU
	NwZ+ENnNgygKaLu1ofnDztrrd+KEru8u7E2jc0d0OJvutj5G9o9iMRF8OxwKf8tKHcPOI7UOdJX
	KprXakbfcbD1484JHpaFfyl8R+BYKlzxxENQTOxz3zCAdpymQj/YmBhBLLmouSXMjhW5upcKb7Y
	Q45GYFg0G5tKydc6M7/hVuBYVeHjcLu3pTrqSi23lsj+yWCQVxNLLkKnGRAcSyg6b9uw/OJu+MX
	upbwp9jc1HxbWFksMxHm59G3Oj2vO3pF3J4G+PCmA0Jo4c9izHtMotESA4ZiRo1PGFxvZr4IJMW
	4
X-Received: by 2002:a81:24c9:: with SMTP id k192mr31969266ywk.19.1552459357386;
        Tue, 12 Mar 2019 23:42:37 -0700 (PDT)
X-Received: by 2002:a81:24c9:: with SMTP id k192mr31969241ywk.19.1552459356724;
        Tue, 12 Mar 2019 23:42:36 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552459356; cv=none;
        d=google.com; s=arc-20160816;
        b=HARJIB0OKXGvzOZx4wJmGPdGfxY2rNkyF3jrzMK2aSqTTb0azdcHQrbO8IyM70KNHD
         Z/5W/80kBM7VGluP4yhc7NhmLgVQmGOr7fVqKDzEjGxGxpkdlFyoMutZniCduQiJhXaS
         1Yv1MPTRCG1AE6uIf+mzcXF+slWFNDpAmFyCyvm8hGWMyjugIQp0Y3nmXU9iTwFuJgB5
         uW/Cilser1UuGdkDl3iPfbL3OsgiH0Ypex93u6A7Oo0rNY33cVwyhBWe3umwEZ7NERo9
         OaxRqrLuCL7tFoFRhtQ/GBjR+i8J5/+MfH8HxA/yktIL47WpuBMrbwLeFuBc9L5aSwih
         gj6Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=ebpiJgvlhqvcNtW6hg58h6gWxH/SKgRPsgHGklpT0Qg=;
        b=p7mFc5TcNJ7ZokQjMoSQXAoZd256oItMVr1tQakWfrFze8UW0LfXtXJn2ZeA36boCX
         wN2qEPRg7xz8B5JuuqbCqFdUTg5yPqUTJf6JPOJqxYN3rihC8zhjQSvCKBDS4Zp1JMK2
         Mw7ybpWGmlGf5Aj/r/uGJMP+lImNouwhi+JPTuxeauiMss38zsnE6K5bezUidboHEB8+
         XsH6ORQOzLbAtvnAMvefcnXpO4VqyX1JM+xHaAqfPPB3JliZwj7ulFvp5K/S5g0PyceJ
         urNf6iPMp/5zGzI2+MS50gdtyVL74pB+Rg0iKgsOEuxzn7L3PUTq4BEnTCvbL+GHWrdZ
         ue5A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=EEFjcIr+;
       spf=pass (google.com: domain of amir73il@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=amir73il@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i1sor5435214ybp.109.2019.03.12.23.42.36
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 12 Mar 2019 23:42:36 -0700 (PDT)
Received-SPF: pass (google.com: domain of amir73il@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=EEFjcIr+;
       spf=pass (google.com: domain of amir73il@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=amir73il@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=ebpiJgvlhqvcNtW6hg58h6gWxH/SKgRPsgHGklpT0Qg=;
        b=EEFjcIr+lwfd1Cx4pjnT1EtEi8PARJhMTqsIZKBxkN+m0X070i0faGadPIcZIKNafz
         PoE8PEYBMme5n9glPItiAHV0BiNjSxTEWHLJP1JjpgdVUgP0qfyKwDUF20wlwciGfJl1
         jPDtVtvEH7UIhx9gb3H3esJUXWOhu2X9vvW3ZIpKB1FGeJwHM5a5hM4vGSWxcwaWamjc
         ojokiqD3oHRtf+7r74rguxyJ3zqFByHYyURp/a4rc0QIfNZ/5BjgOEB+HtttfJUmOmm4
         /N4WF3xPNp7TsaoQyQEIfFFehqrjV8jcOzD7lmpc29N4vpjav6EZzJnSZm4z6ybd4dDF
         iDFw==
X-Google-Smtp-Source: APXvYqwQeGKKSYay1hQBMGZoL/nZ9eWqlMHPqwQLiC+Fn1ydNPDfN9i3J7vyKAUj2qiz70vUnuQGcP96J1k9gw+CS0k=
X-Received: by 2002:a25:4643:: with SMTP id t64mr36139215yba.462.1552459356096;
 Tue, 12 Mar 2019 23:42:36 -0700 (PDT)
MIME-Version: 1.0
References: <00000000000016f7d40583d79bd9@google.com> <CAGXu5jKjWwYk5N3mOH1A8fXX_0BT3r1At_3MzN9M+Ckg5irKXg@mail.gmail.com>
In-Reply-To: <CAGXu5jKjWwYk5N3mOH1A8fXX_0BT3r1At_3MzN9M+Ckg5irKXg@mail.gmail.com>
From: Amir Goldstein <amir73il@gmail.com>
Date: Wed, 13 Mar 2019 08:42:25 +0200
Message-ID: <CAOQ4uxgQf=-swzH_D6cXofXSwXdnpEUsYZ-5q2a_fOZZJy5oRQ@mail.gmail.com>
Subject: Re: WARNING: bad usercopy in fanotify_read
To: Kees Cook <keescook@chromium.org>
Cc: syzbot <syzbot+2c49971e251e36216d1f@syzkaller.appspotmail.com>, 
	Jan Kara <jack@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, cai@lca.pw, 
	Chris von Recklinghausen <crecklin@redhat.com>, LKML <linux-kernel@vger.kernel.org>, 
	Linux-MM <linux-mm@kvack.org>, syzkaller-bugs <syzkaller-bugs@googlegroups.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 13, 2019 at 8:26 AM Kees Cook <keescook@chromium.org> wrote:
>
> On Mon, Mar 11, 2019 at 1:42 PM syzbot
> <syzbot+2c49971e251e36216d1f@syzkaller.appspotmail.com> wrote:
> > C reproducer:   https://syzkaller.appspot.com/x/repro.c?x=17ee410b200000
> > [...]
> > ------------[ cut here ]------------
> > Bad or missing usercopy whitelist? Kernel memory exposure attempt detected
> > from SLAB object 'fanotify_event' (offset 40, size 8)!
> > [...]
> >   copy_to_user include/linux/uaccess.h:151 [inline]
> >   copy_fid_to_user fs/notify/fanotify/fanotify_user.c:236 [inline]
> >   copy_event_to_user fs/notify/fanotify/fanotify_user.c:294 [inline]
>
> Looks like this is the fh/ext_fh union in struct fanotify_fid, field
> "fid" in struct fanotify_event. Given that "fid" is itself in a union
> against a struct path, I think instead of a whitelist using
> KMEM_CACHE_USERCOPY(), this should just use a bounce buffer to avoid
> leaving a whitelist open for path or ext_fh exposure.
>
> Maybe something like this (untested):

I tested. Patch is fine by me with minor nit.
You may add:
Reviewed-by: Amir Goldstein <amir73il@gmail.com>


>
> diff --git a/fs/notify/fanotify/fanotify_user.c
> b/fs/notify/fanotify/fanotify_user.c
> index 56992b32c6bb..b87da9580b3c 100644
> --- a/fs/notify/fanotify/fanotify_user.c
> +++ b/fs/notify/fanotify/fanotify_user.c
> @@ -207,6 +207,7 @@ static int process_access_response(struct
> fsnotify_group *group,
>  static int copy_fid_to_user(struct fanotify_event *event, char __user *buf)
>  {
>         struct fanotify_event_info_fid info = { };
> +       unsigned char bounce[FANOTIFY_INLINE_FH_LEN], *fh;
>         struct file_handle handle = { };
>         size_t fh_len = event->fh_len;
>         size_t len = fanotify_event_info_len(event);
> @@ -233,7 +234,18 @@ static int copy_fid_to_user(struct fanotify_event
> *event, char __user *buf)
>
>         buf += sizeof(handle);
>         len -= sizeof(handle);
> -       if (copy_to_user(buf, fanotify_event_fh(event), fh_len))
> +
> +       /*
> +        * For an inline fh, copy through stack to exclude the copy from
> +        * usercopy hardening protections.
> +        */
> +       fh = fanotify_event_fh(event);
> +       if (fh_len <= sizeof(bounce)) {

Prefer <= FANOTIFY_INLINE_FH_LEN

> +               memcpy(bounce, fh, fh_len);
> +               fh = bounce;
> +       }
> +
> +       if (copy_to_user(buf, fh, fh_len))
>                 return -EFAULT;
>
>         /* Pad with 0's */
>
>
> --
> Kees Cook

