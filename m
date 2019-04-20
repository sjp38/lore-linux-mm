Return-Path: <SRS0=t1VS=SW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DC205C282DD
	for <linux-mm@archiver.kernel.org>; Sat, 20 Apr 2019 10:51:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7CBB72087F
	for <linux-mm@archiver.kernel.org>; Sat, 20 Apr 2019 10:51:14 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="EwO+gArl"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7CBB72087F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 151E86B0003; Sat, 20 Apr 2019 06:51:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 103316B0006; Sat, 20 Apr 2019 06:51:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F33D86B0007; Sat, 20 Apr 2019 06:51:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id D46416B0003
	for <linux-mm@kvack.org>; Sat, 20 Apr 2019 06:51:13 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id e13so3148441qkl.8
        for <linux-mm@kvack.org>; Sat, 20 Apr 2019 03:51:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=kaS+veCYE7ao8csQbi/ZAdwFn2xeuMRJDTxk7kh9MmQ=;
        b=WrCM6fldyej0r37wRWwIAgHo6lnHi68P65QDHgEb0aLdCRZ6QR/7VXpkGtMtoEpRfA
         qrRYrH3vYHOX7PbqsuDyYxKQkTKPRcfan2DFJXQLTzrImIzM3kwqhZTaBNZSEUbYv/3A
         afn7gbcfS6sg70apQZCO0Ot8KTqFEZIccdFLzw7Dsuq7rY76VBfYlHlObunmTvKDbBa5
         x8JJBMUiMU7hozrHj3GpAtBGp+FfiUF1xwmwKu2reC2A04DCrAofzcszF7nnIWAmKouv
         8AcQ7mjeDdHCG47BWy1K6G4tp0OrDu6zoIMl9qxTXzPNKGZ1TSQB55qTgS3TOTa3hBVW
         ePaw==
X-Gm-Message-State: APjAAAWhD9CT/bO8T8jaLvInmFmjHsVaCoSErd7vWZ73usGmxTYMnURK
	cQt8qhNmZcK2q90tyHNiUH7DuFyC4dlc7zH7imN4ma44gWQYcArFcAiwTE+eC/xFX3s1sX6xUhx
	YV0tryFve0Y8uS1byY7kDSmwV43li6GK9ukR8IanY8QT4WUuanuIHFCBJj+J1zqr99g==
X-Received: by 2002:aed:3e94:: with SMTP id n20mr7223474qtf.268.1555757473604;
        Sat, 20 Apr 2019 03:51:13 -0700 (PDT)
X-Received: by 2002:aed:3e94:: with SMTP id n20mr7223433qtf.268.1555757472629;
        Sat, 20 Apr 2019 03:51:12 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555757472; cv=none;
        d=google.com; s=arc-20160816;
        b=ZGszPvzMQjtXshoElafAKCzGNXeBs0ZXaL1rOzUfFeaHICfUCZmZ9jxObZDWJ51/VM
         XpIpBZldHszYUe/AhOgqOS5PjwKkG19qYmx9llBiLmGklGjMwDSVjms2Ncs7rfIZ7BEj
         BxVtwVUoOrVxGwg7zUTzjaVri9hDcWYjjipZ0frVm+ykcKSoDZIQfdg/DLrpd7MbjH31
         HishBFuffLzAztIC9MbGFhF7qjiOT/4oenP5dGnllk7Sx1KxHssS6EOg5XTPMJziWs/Z
         vu5qS17XduW79X3efTQjrCr60M6754ddyUSXoK62Dbv68gyY54mz5TgF5bhJFUPVL0Oo
         LMGQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=kaS+veCYE7ao8csQbi/ZAdwFn2xeuMRJDTxk7kh9MmQ=;
        b=lJJTDBCfdt9xuIM2oduOjroW3fnoUdmJ3Dqg+33zi9fdaYp5oLUfh6UUmFmInCzROU
         PTwrDErXVB6ukrRbQzBO5Pmv1PyXe47TXAoKyTOYrCbhnye193KACT1QG+8z46/F6J1f
         8S3UxUdyMUabVguT97towtSX7kTZVd23OOwwB7p4RBWCOgnMnIV2URiIRD1s5f+nYfBK
         ccHx/mh88cBfXDCHmt1GyFVq2FgIGcSFgvsMElP4hkXFiZGEuq6W+waiX+j7TRLDdmlm
         qiHaqV3w75hOBOH8pFXULg2mku74t80LoAmvAcpd/WThDhd7iWiRx4XJOQN3pVM8J+G8
         eFnA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=EwO+gArl;
       spf=pass (google.com: domain of mayhs11saini@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mayhs11saini@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g6sor4350171qkf.99.2019.04.20.03.51.12
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 20 Apr 2019 03:51:12 -0700 (PDT)
Received-SPF: pass (google.com: domain of mayhs11saini@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=EwO+gArl;
       spf=pass (google.com: domain of mayhs11saini@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mayhs11saini@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=kaS+veCYE7ao8csQbi/ZAdwFn2xeuMRJDTxk7kh9MmQ=;
        b=EwO+gArlEBVQK/nJT5vZKE02dfSFFoeHd/43vZOndrjFwkjrhjJgbW66CULGd/qp8M
         CAKK4/fa+yfKDft5ldNSlPt0B6rGPqndRHkFtb4MayLgZRwIeW+bjjxZxoS2RPm+NmrM
         5J8qu7sm0tvit9z1Ptm9VeGVZYEOilIUa4FqMFKftvJ8C1sr9isBTWCvBqkSLuRkQFnC
         /JfrzCUu4i4VMVxMXiNW5Pt1t1KcV3H7PonI7MF2Vn8rgAvwSZzAmsvqnBS5yxoNSCFk
         Cki0HCuHLWy/0V7zOngTErhlDLx+7wgLUrHt9aXGhXBRdZrcx1OCpXV7iZBdhZmXdUlW
         Hvng==
X-Google-Smtp-Source: APXvYqwATcAIlW4nr9QShhMxeCWgd4J//S9gB2/UnHehq87+pPLyQ1o9lMaZFrSTSc7CUnr7ubTUZZuLbaGHeINqWkU=
X-Received: by 2002:a37:6886:: with SMTP id d128mr907042qkc.158.1555757472269;
 Sat, 20 Apr 2019 03:51:12 -0700 (PDT)
MIME-Version: 1.0
References: <20190414091452.22275-1-shyam.saini@amarulasolutions.com> <C398B8C9-6A54-4590-AA88-58D514BAEB71@oracle.com>
In-Reply-To: <C398B8C9-6A54-4590-AA88-58D514BAEB71@oracle.com>
From: Shyam Saini <mayhs11saini@gmail.com>
Date: Sat, 20 Apr 2019 16:21:00 +0530
Message-ID: <CAOfkYf7vn7UnYzZDh9==agVu61sYyFWzvo6hQBt3KfaKrWC-6Q@mail.gmail.com>
Subject: Re: [PATCH 1/2] include: linux: Regularise the use of FIELD_SIZEOF macro
To: William Kucharski <william.kucharski@oracle.com>
Cc: Shyam Saini <shyam.saini@amarulasolutions.com>, 
	Kernel Hardening <kernel-hardening@lists.openwall.com>, LKML <linux-kernel@vger.kernel.org>, 
	Andrew Morton <akpm@linux-foundation.org>, Kees Cook <keescook@chromium.org>, 
	linux-arm-kernel@lists.infradead.org, linux-mips@vger.kernel.org, 
	intel-gvt-dev@lists.freedesktop.org, intel-gfx@lists.freedesktop.org, 
	dri-devel <dri-devel@lists.freedesktop.org>, 
	Network Development <netdev@vger.kernel.org>, linux-ext4@vger.kernel.org, 
	devel@lists.orangefs.org, linux-mm <linux-mm@kvack.org>, linux-sctp@vger.kernel.org, 
	bpf <bpf@vger.kernel.org>, kvm@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi William,

Sorry for the late reply.

> > Currently, there are 3 different macros, namely sizeof_field, SIZEOF_FIELD
> > and FIELD_SIZEOF which are used to calculate the size of a member of
> > structure, so to bring uniformity in entire kernel source tree lets use
> > FIELD_SIZEOF and replace all occurrences of other two macros with this.
> >
> > For this purpose, redefine FIELD_SIZEOF in include/linux/stddef.h and
> > tools/testing/selftests/bpf/bpf_util.h and remove its defination from
> > include/linux/kernel.h
>
>
> > --- a/include/linux/stddef.h
> > +++ b/include/linux/stddef.h
> > @@ -20,6 +20,15 @@ enum {
> > #endif
> >
> > /**
> > + * FIELD_SIZEOF - get the size of a struct's field
> > + * @t: the target struct
> > + * @f: the target struct's field
> > + * Return: the size of @f in the struct definition without having a
> > + * declared instance of @t.
> > + */
> > +#define FIELD_SIZEOF(t, f) (sizeof(((t *)0)->f))
> > +
> > +/**
> >  * sizeof_field(TYPE, MEMBER)
> >  *
> >  * @TYPE: The structure containing the field of interest
> > @@ -34,6 +43,6 @@ enum {
> >  * @MEMBER: The member within the structure to get the end offset of
> >  */
> > #define offsetofend(TYPE, MEMBER) \
> > -     (offsetof(TYPE, MEMBER) + sizeof_field(TYPE, MEMBER))
> > +     (offsetof(TYPE, MEMBER) + FIELD_SIZEOF(TYPE, MEMBER))
>
> If you're doing this, why are you leaving the definition of sizeof_field() in
> stddef.h untouched?

I have removed definition of sizeof_field in [1/2] patch.

> Given the way this has worked historically, if you are leaving it in place for
> source compatibility reasons, shouldn't it be redefined in terms of
> FIELD_SIZEOF(), e.g.:
>
> #define sizeof_field(TYPE, MEMBER) FIELD_SIZEOF(TYPE, MEMBER)

Actually, never thought this way. So,Thanks a lot for this valuable feedback.

I'll re-spin and post again.

