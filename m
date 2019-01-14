Return-Path: <SRS0=uJng=PW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 714C3C43387
	for <linux-mm@archiver.kernel.org>; Mon, 14 Jan 2019 14:03:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 36E8C20657
	for <linux-mm@archiver.kernel.org>; Mon, 14 Jan 2019 14:03:05 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 36E8C20657
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-m68k.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CB2D18E0003; Mon, 14 Jan 2019 09:03:04 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C62828E0002; Mon, 14 Jan 2019 09:03:04 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B50C18E0003; Mon, 14 Jan 2019 09:03:04 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ua1-f71.google.com (mail-ua1-f71.google.com [209.85.222.71])
	by kanga.kvack.org (Postfix) with ESMTP id 85E378E0002
	for <linux-mm@kvack.org>; Mon, 14 Jan 2019 09:03:04 -0500 (EST)
Received: by mail-ua1-f71.google.com with SMTP id c26so1522501uap.13
        for <linux-mm@kvack.org>; Mon, 14 Jan 2019 06:03:04 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:mime-version
         :references:in-reply-to:from:date:message-id:subject:to:cc;
        bh=EPXQ005dpgnhxanjjmigJASoqbeog16GFnmkdoG8qpw=;
        b=K7JApS+u3vnIr0g8RApEys7ghBqxQKbwXda97yRVR7+chmfSyETtGFdEEaXHzvRodR
         DH/Ye37F91/5OQsm0j8qgeQqLsV8Qwu/wNm7vbk0B9poHAIAekNHCvF2Q6TY0hb1NHeq
         ebb7GEbce1tIqzqC/Z+jGp9ggHC9YFjFUhWsKoAfJKz9yUWSdFvIT/47OrRVlhthnz2n
         8IdGJVopME0Ue3s+ZO7nQpsigO3xK+m24nTdWlDl+KDbTKD2onS22IFh+kfv9nWsrvjk
         AcQulSqRh6bM+4KCfnYEpZNVfhtpFcgpVK6NFk6w1yYKdRqViPZmChdbfpswfqrNcZTf
         mldw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of geert.uytterhoeven@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=geert.uytterhoeven@gmail.com
X-Gm-Message-State: AJcUukezf9ycGAWw0nnlLUTkS1YuikRQjI46buj2J6KzMW1V7wNZMhRx
	f3LkmE/CQoJVXo8nL90z6nchcaq0uXlXIVaKKxwOlyOsmifSSfstlDVunEeBCTOU4COQHd34eik
	nRME7UVVVN3lrJg9d0Z9XrwL5koDerkKtaje2HRuIeK3DxfzSbJjKnUdgG6ppV7eqGfLD9JteP6
	jgqCg8lGgYT6ej9pZO1eTPsZ9Yz45327NCNBwtjCbszTPI1bWZgU/mFHERBvLG46dVWu/opEEug
	Puc1TmGiEqnzmQYrH23cwlNrHKdLFq8ShTVX4zzCIxq9MP6yHfE0+kHXHhnPhn40RHn3Fo6HkRE
	GuDzQvzz62tBcL+uszZFZaYKNFiulWqcevt9TH0F/IoLgzDqjU5466zpIOJ/Vc3xwW4wmpYIEg=
	=
X-Received: by 2002:ab0:8d9:: with SMTP id o25mr9554226uaf.127.1547474584160;
        Mon, 14 Jan 2019 06:03:04 -0800 (PST)
X-Received: by 2002:ab0:8d9:: with SMTP id o25mr9554206uaf.127.1547474583359;
        Mon, 14 Jan 2019 06:03:03 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1547474583; cv=none;
        d=google.com; s=arc-20160816;
        b=QsR0uN2O/L4XsRvfeRuw8QFRXAYCLMvG4ktzto8HbQ3GQdRgaMmRVRejP8eESjZPwg
         bW6pRhvG9ChdAZLtim+ofeyJt9su8fTh3BiJPJoIxtb67iNQn2IHMcsLmt3RF7dwCIMy
         LSnzEtuERci/emWXiLEtsdcBVxW4G84OmRcbSbHK+Ix6PeMzm0PzZVk0O2JLHkoxZAWi
         CAmrMjSWrbdl7pyfcJ6LH/QcY8MqGhL4gnFdCeE0Mu/vPwPEfEJJHrv+FB9C87mnwhfe
         Dk/vEpVgG75u+Ez2OwjXtSMDrwpf9v58sxW8Z59AUEd9ySE5/lX8Xm2n63eusqBi44a0
         25Tg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version;
        bh=EPXQ005dpgnhxanjjmigJASoqbeog16GFnmkdoG8qpw=;
        b=QtR/4uavM/gb5y1m0Stu5Mpk83r3yhKUMww4LLciMwxNT8CDTS8OIvC92Jp9wm3sm5
         nMyVUyqRShN+PA6wKGyN3MTBdqHJ2rGzc0H6tDa2cCy0RCUxm3oSFZYCeJhdrlzNyuOA
         i+lr48mSZ0t/y70t62yBDmn3JrHWfWIuFvjE+/4v/IsLkVflo+MmFgfWmBKHQwhmffTi
         R4V+HQOx0+vcZwYxvDc9nwhvqK6CoXg3X1e/44GbmT9eZb2Ccc1WfWmDkmzrEPPld3zf
         OP2SswylDUXbs4cdCYoXtX+6On9jEJ4YlZif7vtwvZVC8IsT+5kG9lXe9JmwY5+/TKps
         uXBg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of geert.uytterhoeven@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=geert.uytterhoeven@gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e15sor322585vsa.13.2019.01.14.06.03.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 14 Jan 2019 06:03:03 -0800 (PST)
Received-SPF: pass (google.com: domain of geert.uytterhoeven@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of geert.uytterhoeven@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=geert.uytterhoeven@gmail.com
X-Google-Smtp-Source: ALg8bN5wYMxOtX3lY+uzxTqd21QEfqP1458GnLRYAHGRLaMnhFDHkh8ZI6dVlRF3u0c0V7r+jYFPOiKxVX+duKm+d8A=
X-Received: by 2002:a67:f43:: with SMTP id 64mr10255483vsp.166.1547474582599;
 Mon, 14 Jan 2019 06:03:02 -0800 (PST)
MIME-Version: 1.0
References: <20190114125903.24845-1-david@redhat.com> <20190114125903.24845-6-david@redhat.com>
In-Reply-To: <20190114125903.24845-6-david@redhat.com>
From: Geert Uytterhoeven <geert@linux-m68k.org>
Date: Mon, 14 Jan 2019 15:02:50 +0100
Message-ID:
 <CAMuHMdWEChb4+tf0m_qN9Mc6Am5T0rZLqAn6QsQ8NdMOCRPySQ@mail.gmail.com>
Subject: Re: [PATCH v2 5/9] m68k/mm: use __ClearPageReserved()
To: David Hildenbrand <david@redhat.com>
Cc: Linux MM <linux-mm@kvack.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, 
	Linux ARM <linux-arm-kernel@lists.infradead.org>, 
	linux-m68k <linux-m68k@lists.linux-m68k.org>, 
	linuxppc-dev <linuxppc-dev@lists.ozlabs.org>, linux-riscv@lists.infradead.org, 
	linux-s390 <linux-s390@vger.kernel.org>, linux-mediatek@lists.infradead.org, 
	Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, 
	Matthew Wilcox <willy@infradead.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190114140250.PoZ84e97C6SHV47d03P_Uw35_P5qfhMdvikvX43n4MA@z>

On Mon, Jan 14, 2019 at 1:59 PM David Hildenbrand <david@redhat.com> wrote:
> The PG_reserved flag is cleared from memory that is part of the kernel
> image (and therefore marked as PG_reserved). Avoid using PG_reserved
> directly.
>
> Cc: Geert Uytterhoeven <geert@linux-m68k.org>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Michal Hocko <mhocko@kernel.org>
> Cc: Matthew Wilcox <willy@infradead.org>
> Signed-off-by: David Hildenbrand <david@redhat.com>

Acked-by: Geert Uytterhoeven <geert@linux-m68k.org>

BTW, it's a pity ctags doesn't know where __ClearPageReserved()
is defined.

Gr{oetje,eeting}s,

                        Geert


--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds

