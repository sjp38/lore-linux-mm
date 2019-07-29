Return-Path: <SRS0=FoEm=V2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_IN_DEF_DKIM_WL
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 439E3C76186
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 20:11:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0765620644
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 20:11:24 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="ESrg15vv"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0765620644
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7C9CB8E0003; Mon, 29 Jul 2019 16:11:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 779FE8E0002; Mon, 29 Jul 2019 16:11:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 690608E0003; Mon, 29 Jul 2019 16:11:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id 204A08E0002
	for <linux-mm@kvack.org>; Mon, 29 Jul 2019 16:11:24 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id b6so30616844wrp.21
        for <linux-mm@kvack.org>; Mon, 29 Jul 2019 13:11:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=lBs2XH1stLT9RSq/8zHtTMENwlKXXKYro8AoKfkCRxU=;
        b=JMqE3fkFIMpRRzZzVCMTMd9og+61tnIFrjDIOyMI/d+T8Wg6l9nJZ+NCyLWnCgPONi
         J5uETrcKKrs2J3roemrPlYL9rpAxyOKcNuN9ReHLTySOzRuPxOECE2X8cizlpNU0nNwB
         Zl36vWNCxEshRr6blraXDj9BJ5woLJOmES3mOOS0THMGREYTe/nRmdrTvmS5li1AneWs
         S0wCGd5s1DBy+S61aJnBnMdwvovDPiLRU0+KlJih+uU04jGutBlBYlR7+JxZXedO2t3a
         ktlDVtkNYoQFCspnP7zv0j3BDUFiCnwmSVq+7vNFR4EufbKu2hy0I6chD1m7ChKYzcP4
         nbbw==
X-Gm-Message-State: APjAAAUaMGLfdMJgNGDRMyU8QpUfPnT/rDCIEehW+nlNYnOFkViffMhp
	DE365sjW1bTOlsIOnPBPMQMYMM523T8T6hI93EQWC1gckhNkHUQp2PdMLS1BljAaUXRHzwTWh5C
	9zbY7G4AZoSv+b906JF5L05Bi61pOw4iOhFLPBb8LvzfIPjHQVGpUIBpNVEb89gc7cg==
X-Received: by 2002:adf:f281:: with SMTP id k1mr34606460wro.154.1564431083706;
        Mon, 29 Jul 2019 13:11:23 -0700 (PDT)
X-Received: by 2002:adf:f281:: with SMTP id k1mr34606431wro.154.1564431082997;
        Mon, 29 Jul 2019 13:11:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564431082; cv=none;
        d=google.com; s=arc-20160816;
        b=r7z/B4EPj+iSAI3ppv0NaoRflwaaDtb7AKLejQthm3rR30U61Tg+5hkvnqUA8RxD5c
         OIKjg963s71q57R6wyt8RPdsITVulYZNVOXwayEOQ4WSoMmc9m/aQRvUwbkYY+RewiOS
         x/47FXrQMLWuA/ajoKtiwc+jG7yB6r5KwdLF/4aIvo1UDkSbkkaoVK+otvk6nR3lAuJj
         RwsyReXcVQ0lV2vLPpQa+04QDlb6WRWFapM6VS9shgDdUkcaYex+1kb7w60xG0AXJ74Z
         v2jGevrDW7tEv26EFTtbOfu5IjvRwGenj8DpepI7vL3GJW1qFfkFSoXDd+6+8mLWjR39
         jKNA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=lBs2XH1stLT9RSq/8zHtTMENwlKXXKYro8AoKfkCRxU=;
        b=GyjuVtYXR50EoGk1o1HVVNC1lOaqrWIBqE/JFUgXxpjvBDTD/ekHojINVMuydognZO
         Hu0acUWPiS5pgiVfe7MUsRyz9UkQ+/LkMiOQgpZH52FGd1f9pOL6KUOzta1a0i64b7oF
         Fyhx5zooBIUTyiA96VaygLXaAE8l5xbLv7+WZqrdYWIA6MNgnA6fanNdLJSSohObLMJ4
         4iuLKcsYC9O9MfcERYFjz+G3TQwUkouUtyyAKo0U4XT+7zgXU03X3qxP28Qu1OWy2jrL
         YUFrJwilXMDGvm4PynbNnYWqZ3x5YP1j34oSEJCcP/7TeubfMgF63nON0m9OYkQ0Mxbt
         FKgA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=ESrg15vv;
       spf=pass (google.com: domain of surenb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=surenb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g8sor49961589wrp.5.2019.07.29.13.11.22
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 29 Jul 2019 13:11:22 -0700 (PDT)
Received-SPF: pass (google.com: domain of surenb@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=ESrg15vv;
       spf=pass (google.com: domain of surenb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=surenb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=lBs2XH1stLT9RSq/8zHtTMENwlKXXKYro8AoKfkCRxU=;
        b=ESrg15vvIX2QliCdNOmD818metRcak3U4lgoyUOfJF5b5qpQcOFHk0C5rbPIKNw1qq
         1/YcdaNMcX/6zvstceGw4yvHU1Rf/KH+kAvcYEprQkif0v58fm2J4T4LKWE+ujWj8ACl
         /6Cn7fMp0R/3d3Q5rNzDwfnJ6yr6pFBaNu9F2uUh7KXxX0hA0Of4ytteaddwvPWjr2ai
         IHueRhtmbIcmgRtC4iBgos3HVH7sOSkTIh66bPU+d5V7kcxvFHzIMKQYVyEDKop8Cbvo
         mqpZn0O4GvhScLBcknDAPX3u/sNr6wdE8yeeZnp6BC2CP44/ofXvyC6F0UELTqafJhKM
         SJ2g==
X-Google-Smtp-Source: APXvYqxFKlb66t4oKcBaMb48wYrx+/EeOSc5Ncb8ZjsZuiaefe638OkpcAYIjYItOQWGw5Iw4GJc21WafT9t8sruOeQ=
X-Received: by 2002:a5d:46cf:: with SMTP id g15mr126611598wrs.93.1564431082241;
 Mon, 29 Jul 2019 13:11:22 -0700 (PDT)
MIME-Version: 1.0
References: <20190729194205.212846-1-surenb@google.com> <20190729195614.GA31529@kroah.com>
In-Reply-To: <20190729195614.GA31529@kroah.com>
From: Suren Baghdasaryan <surenb@google.com>
Date: Mon, 29 Jul 2019 13:11:11 -0700
Message-ID: <CAJuCfpFRsmN0gim_4fXNouzOxZWSJO6xkpLzoGvbBUE8tMOECA@mail.gmail.com>
Subject: Re: [PATCH 1/1] psi: do not require setsched permission from the
 trigger creator
To: Greg KH <gregkh@linuxfoundation.org>
Cc: lizefan@huawei.com, Johannes Weiner <hannes@cmpxchg.org>, axboe@kernel.dk, 
	Dennis Zhou <dennis@kernel.org>, Dennis Zhou <dennisszhou@gmail.com>, 
	Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, 
	Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, 
	linux-doc@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, 
	kernel-team <kernel-team@android.com>, Nick Kralevich <nnk@google.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jul 29, 2019 at 12:57 PM Greg KH <gregkh@linuxfoundation.org> wrote:
>
> On Mon, Jul 29, 2019 at 12:42:05PM -0700, Suren Baghdasaryan wrote:
> > When a process creates a new trigger by writing into /proc/pressure/*
> > files, permissions to write such a file should be used to determine whether
> > the process is allowed to do so or not. Current implementation would also
> > require such a process to have setsched capability. Setting of psi trigger
> > thread's scheduling policy is an implementation detail and should not be
> > exposed to the user level. Remove the permission check by using _nocheck
> > version of the function.
> >
> > Suggested-by: Nick Kralevich <nnk@google.com>
> > Signed-off-by: Suren Baghdasaryan <surenb@google.com>
> > ---
> >  kernel/sched/psi.c | 2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
>
> $ ./scripts/get_maintainer.pl --file kernel/sched/psi.c
> Ingo Molnar <mingo@redhat.com> (maintainer:SCHEDULER)
> Peter Zijlstra <peterz@infradead.org> (maintainer:SCHEDULER)
> linux-kernel@vger.kernel.org (open list:SCHEDULER)
>
>
> No where am I listed there, so why did you send this "To:" me?
>

Oh, sorry about that. Both Ingo and Peter are CC'ed directly. Should I
still resend?

> please fix up and resend.
>
> greg k-h

