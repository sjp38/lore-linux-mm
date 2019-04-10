Return-Path: <SRS0=DRoR=SM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BA13BC10F11
	for <linux-mm@archiver.kernel.org>; Wed, 10 Apr 2019 11:31:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7162E2083E
	for <linux-mm@archiver.kernel.org>; Wed, 10 Apr 2019 11:31:55 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="sl2qd3Jf"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7162E2083E
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E658E6B028D; Wed, 10 Apr 2019 07:31:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E14986B028E; Wed, 10 Apr 2019 07:31:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D2AF96B028F; Wed, 10 Apr 2019 07:31:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f71.google.com (mail-io1-f71.google.com [209.85.166.71])
	by kanga.kvack.org (Postfix) with ESMTP id B39B76B028D
	for <linux-mm@kvack.org>; Wed, 10 Apr 2019 07:31:54 -0400 (EDT)
Received: by mail-io1-f71.google.com with SMTP id b199so1467803iof.14
        for <linux-mm@kvack.org>; Wed, 10 Apr 2019 04:31:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=fvn/7zFnF3HAnTBufLjHdB464PsWTUouxpzbMSb1H2g=;
        b=aXNBAxxFzamiS3A2LIjgRp2ZJIfjqHu6ooq9XvG4YdB9jdW+BJdn/o9pfXvLO4CubV
         iNxtp2ZeNzWaSlC4ktAMKqncTt7lTZeuRdsfNo4voukbU5TXxktDS2/K/RA2v1ouiS7R
         z33Vf+Zsk22b1J0P4x4SPkDPDw3hw6nTjYSVRCHO2ox99wl51EKYF9C2OQunQQlHRthX
         BOVWimknjVmntHfLdS8NzUJYCy+LaWQpuygTc8e+CqCCVNszNwR5SuViwgDaRhqGdPhk
         /bIKJDv82ecmQoM6PDqiz4PRmJZYWDmWfa+UV+zZciRpRs0Ysv52WrKrFQg/+4mBviIK
         6d+g==
X-Gm-Message-State: APjAAAXgECS5tVbv1qxOjydyVkfZ6YG53+ZNJnk04xXX+stLOghFQKhg
	n3oEXC/APZLC+s0v0Ant+bf9CTm0eNwvvxxLlkvCoKttA4etWdBkC9HiUzLeQF+0Jj9x5XC34Ja
	Yh+zjXUA8uR2foKMbPjtzztADzkrwMxrnHNx/kiowoBk0ZM+EuLMJCY3wnUDiUF9j5g==
X-Received: by 2002:a05:660c:14e:: with SMTP id r14mr2689128itk.95.1554895914489;
        Wed, 10 Apr 2019 04:31:54 -0700 (PDT)
X-Received: by 2002:a05:660c:14e:: with SMTP id r14mr2689080itk.95.1554895913706;
        Wed, 10 Apr 2019 04:31:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554895913; cv=none;
        d=google.com; s=arc-20160816;
        b=U+NXnw4zzBalwEgwfObaxR5QewP5Qm+TFV67l3LxuL/PIRWwt16n9fLSlqqcqdMI0C
         pexAQ3rQ6zCcTToRbmDkTw7UDxQmg0O9XUNzYuFLIxut4BX6P8zvG+XDA9U6/0jwm77b
         PIyM3cWHELaYUKB7W2O1NhNpWxy8txyDyua0JCzlLBZNSGGon06AcUlZu28rso1varTs
         2kKc5+i37coYM7YjBEI9WCzpAG2GrA0BpVeNEJIBnvqUy/gT48tdl9/oaQ/O46MWPOYl
         T/3tIn4rA2fpRkblAcBCTJ55bDWoci2XuaNFzhUoZdy/RrIjhp8VyaJ6My7dJaaTyavV
         lQvw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=fvn/7zFnF3HAnTBufLjHdB464PsWTUouxpzbMSb1H2g=;
        b=eIHgq9DmlwKLHf5ED9LObI9ofevpMC3bDEUU1EQIM/ARZ6faSy+Ef6bVrn1/7i3CSy
         iWg8bMyQBZMoGDoaEEX+Lawc0l04mELpyjb3SYhTmONgvAuGoLqUmEpQtM4ICGx+W+FB
         bXH2vruTQl8bH3MY0V+C0J9kViBVMx6fImt8iZqlvgzXWAsWCg1umwOEVI6IBzpXBNGy
         h2yTBzjDIZp5BgPaLndCVUlawB+nzV7LsQR2smkLwXFV8HFAi/bfLNVTcAYaKmFPkYRv
         76h/bnWikZnFjDX11cSL7RzDwEJZ7zaKavxruWc1UdCw8ZQ0JxD9i8iUjnxaHdnY3HDp
         k2ew==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=sl2qd3Jf;
       spf=pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dvyukov@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s135sor2963181itb.9.2019.04.10.04.31.53
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 10 Apr 2019 04:31:53 -0700 (PDT)
Received-SPF: pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=sl2qd3Jf;
       spf=pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dvyukov@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=fvn/7zFnF3HAnTBufLjHdB464PsWTUouxpzbMSb1H2g=;
        b=sl2qd3Jf3qmCvfIH/SLL8F3Jdiy1HR05kNdYcy8+mkI+eYuoGCyBXZ8jKlU2/ZvX3v
         j5BPcckdL8liLVmp0hb/d0qL/hnSN6a6y+emyi8hPCvPKkHhKBRTvguhIRJl7ukEj/TD
         AfIcEewOPg9RWGcp4deatK1YePDRlkk/ZrBo1QfsYvxHp3K1LvJps037mMeV6TFfYgDk
         7l+xa/X4JrKtOPDWSlTmFVfynoyr96WEJi+70PYVdKLUvQi9/vrXKCLZ+kJzm1IJOhVa
         a73mdwUY31qMvU1zriLqta/Q+Nb8TmzUDN6AL2UrUwnlmd4O99l17yGfkUnUcH4VBuZR
         Ufgw==
X-Google-Smtp-Source: APXvYqx+/T8WY03v9xLmT+TvaJRfgwlIvB0PUC6j88bxk0iWtwftMluJ5tPLM6WK/fA+GPicKD1rsJwSBv8R4E8L55w=
X-Received: by 2002:a24:3d8f:: with SMTP id n137mr2634250itn.96.1554895912971;
 Wed, 10 Apr 2019 04:31:52 -0700 (PDT)
MIME-Version: 1.0
References: <20190410102754.387743324@linutronix.de> <20190410103644.750219625@linutronix.de>
In-Reply-To: <20190410103644.750219625@linutronix.de>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Wed, 10 Apr 2019 13:31:41 +0200
Message-ID: <CACT4Y+YO45bfyCaeaLP-xAVDOjSE8xnbXpv-Dz7t3W7C5jPd6Q@mail.gmail.com>
Subject: Re: [RFC patch 13/41] mm/kasan: Remove the ULONG_MAX stack trace hackery
To: Thomas Gleixner <tglx@linutronix.de>
Cc: LKML <linux-kernel@vger.kernel.org>, Josh Poimboeuf <jpoimboe@redhat.com>, 
	"the arch/x86 maintainers" <x86@kernel.org>, Andy Lutomirski <luto@kernel.org>, Steven Rostedt <rostedt@goodmis.org>, 
	Alexander Potapenko <glider@google.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, 
	kasan-dev <kasan-dev@googlegroups.com>, Linux-MM <linux-mm@kvack.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 10, 2019 at 1:05 PM Thomas Gleixner <tglx@linutronix.de> wrote:
>
> No architecture terminates the stack trace with ULONG_MAX anymore. Remove
> the cruft.
>
> Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
> Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>
> Cc: Alexander Potapenko <glider@google.com>
> Cc: kasan-dev@googlegroups.com
> Cc: Dmitry Vyukov <dvyukov@google.com>
> Cc: linux-mm@kvack.org
> ---
>  mm/kasan/common.c |    3 ---
>  1 file changed, 3 deletions(-)
>
> --- a/mm/kasan/common.c
> +++ b/mm/kasan/common.c
> @@ -74,9 +74,6 @@ static inline depot_stack_handle_t save_
>
>         save_stack_trace(&trace);
>         filter_irq_stacks(&trace);
> -       if (trace.nr_entries != 0 &&
> -           trace.entries[trace.nr_entries-1] == ULONG_MAX)
> -               trace.nr_entries--;
>
>         return depot_save_stack(&trace, flags);
>  }


Acked-by: Dmitry Vyukov <dvyukov@google.com>

