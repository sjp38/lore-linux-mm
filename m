Return-Path: <SRS0=4n/l=R3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,URIBL_BLOCKED,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 60D3EC43381
	for <linux-mm@archiver.kernel.org>; Sun, 24 Mar 2019 18:49:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 030D22147C
	for <linux-mm@archiver.kernel.org>; Sun, 24 Mar 2019 18:49:05 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="Kpr2Pj89"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 030D22147C
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 66F7B6B0003; Sun, 24 Mar 2019 14:49:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 61E0F6B0005; Sun, 24 Mar 2019 14:49:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 534B36B0007; Sun, 24 Mar 2019 14:49:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 304A36B0003
	for <linux-mm@kvack.org>; Sun, 24 Mar 2019 14:49:05 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id m8so6851716qka.10
        for <linux-mm@kvack.org>; Sun, 24 Mar 2019 11:49:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=3E5PbD/R8KE0AK8IEXA0HiRaTNZrWClh6JLvVEMcjJA=;
        b=NiY5fHCpRqgWz6ICmJ8mlA0yuF0MGD6xjxKd4aqdCB/SM0ApVfZYik/mGttcGN4ymF
         BXNv/F5QInJs9hVDEhk2n83Ku0qVXMj7hjNBHQe5IIJ7wz5SZguKYQTKX6Amru+ekZ2D
         5xDP5X7Pz+yMtQnNCe1E+2qJjYkbgCpFGtI6O0Unmm4m/Ejh6i6y/fhw787QtfHCtS88
         9f+zH2bRg0DoRXQ14+y+npPxvIbwRizShEVk6Tk+9W46TpMF2YE9/enrkVkxvVsC1UDB
         7yur/ftPwqBuM4sDVadjYJyVErJ2suu5DthtuljPegpNbZ/iQ3PgUMqMJj4veVS3zZsn
         mWPg==
X-Gm-Message-State: APjAAAVVdJJRnTEXHVehgGf2S/BABO1IsPYolEmYgSvjd/5YIbd3LDqv
	TUy2GpgNCQqNsoxwtjX7ThpUtWPhtWac03xvuOdnNwfJpYBd6ZMLL2Dc3Vpgf34bPr9T4dNwtlP
	mxk2mvhMQMQTSIou3/aGFD7oRS2exNBWDOhVv9hO+UfP/IDbUslcNp8Y6c9TmEYS9rQ==
X-Received: by 2002:a05:620a:1372:: with SMTP id d18mr15276932qkl.310.1553453344792;
        Sun, 24 Mar 2019 11:49:04 -0700 (PDT)
X-Received: by 2002:a05:620a:1372:: with SMTP id d18mr15276908qkl.310.1553453344045;
        Sun, 24 Mar 2019 11:49:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553453344; cv=none;
        d=google.com; s=arc-20160816;
        b=Kmiph53DfR//JRSk7Gt9C2JeSLdALyOHba/sGsaH64EdjQrX0FZuY6s0Kuc8prx3Ej
         rZCRxL1TCMLbm/mB3iU8/1TQYn4WKUNL3w010k5wyp2VhrTR9o1QPgCP0zkNcDSW9xKn
         p+JKS4s6YeYsFS0mQBIoqEU6+GiVFFgxTB9yRYhYLjyUVy8OSOUIFuI2QBXV/ofq7GMU
         iKYmzKUviSz/tqHNIJ9HeSCQGgsYt2Fi59reApVH4i9QW/lUQZijLjeR1w50Nz3y2rKM
         upQzkJBtXoMDIE4jaQjC/JI+i4A6sjCODtmmNkX4PSbdOdLJJn3ZrtSWdGu0ltV8rZvx
         1zGg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=3E5PbD/R8KE0AK8IEXA0HiRaTNZrWClh6JLvVEMcjJA=;
        b=PDAvwbAaCdkm0AkvC2BYB4z9P6QhFyIH4KKW3H50S7JWpkf1aLrSi+FA4Nt6H/yCJ1
         RoeNeOHha3w4O+NQ+yMMfXXF0+0Nnz8Qdhn7zLtr5tGad8DwTglg16I6DepSRtXdOZ7K
         FOwhstzVHPWc3RJu//8gVJ6blqU5RVFPHcC6h9pAHCkkqsm1ZVg6BurDjYvihUuxPu7E
         cZCOkhS8ax8xP+gT1myX6iJXGAmE6II5I5MXIQH10QP5u2WpsRitcv60YLjq6LEupb32
         YR/P6u85HbnvJDe23SSP0OE6Gld8sslDT6TQX1N90L2pDetIN2lBTk5reO5vCpgbg8wZ
         SZ+g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=Kpr2Pj89;
       spf=pass (google.com: domain of joelaf@google.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=joelaf@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id f54sor14624960qvf.35.2019.03.24.11.49.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 24 Mar 2019 11:49:04 -0700 (PDT)
Received-SPF: pass (google.com: domain of joelaf@google.com designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=Kpr2Pj89;
       spf=pass (google.com: domain of joelaf@google.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=joelaf@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=3E5PbD/R8KE0AK8IEXA0HiRaTNZrWClh6JLvVEMcjJA=;
        b=Kpr2Pj89AACdsy9YXGxjPNM2856WloQP5gTnJGcMPHcDulRXB24JL1Q+55SZ8atsZ5
         pTu+lL+XbvMqTKShWIDc2U1PeoFD/B0fTrhrmRmWHQL39Y2XUuH3WcWHArJ1fChakr8M
         +EQugGx8TeJA6+qHQWTme3C9lUj/6RhHLE8pKqo9CAO9rB/MTEFgfWe9ZuB4k7PmnI/k
         7aJ3xsiegOQE/AqwkFIiHUTDJZZPTG8tjvyTShIZRB/ft+NCDYcNMITqGZilJqRKZHGJ
         kx++06XqoMPr0nh41EIxB69l6ghrb5N80kv2wK9f8K2619cn8tz2Rpgp8rzE15hkiie1
         mkSg==
X-Google-Smtp-Source: APXvYqwCwbatcl/nUNjqKbqJbunhhvR2uPQnvJ0q0OU9X7yHkG1uyIFEAYpQ+V9uE6Rkswj54NQTVvUhOderhX900JE=
X-Received: by 2002:a0c:d2fa:: with SMTP id x55mr17704481qvh.161.1553453343410;
 Sun, 24 Mar 2019 11:49:03 -0700 (PDT)
MIME-Version: 1.0
References: <20190319231020.tdcttojlbmx57gke@brauner.io> <20190320015249.GC129907@google.com>
 <CAKOZuetJzg_EiyuK7Pa13X3LKuBbreg7zJ5g4uQv_uV4wpmZjg@mail.gmail.com>
 <20190320035953.mnhax3vd47ya4zzm@brauner.io> <CAKOZuet3-VhmC3oHtEbPPvdiar_k_QXTf0TkgmH9LiwmW-_oNA@mail.gmail.com>
 <4A06C5BB-9171-4E70-BE31-9574B4083A9F@joelfernandes.org> <20190320182649.spryp5uaeiaxijum@brauner.io>
 <CAKOZuevHbQtrq+Nb-jw1L7O72BmAzcXmbUnfnseeXZjX4PE4tg@mail.gmail.com>
 <20190320185156.7bq775vvtsxqlzfn@brauner.io> <CAKOZuetKkPaAZvRZyG3V6RMAgOJx08dH4K4ABqLnAf53WRUHTg@mail.gmail.com>
 <20190324144404.GA32603@mail.hallyn.com>
In-Reply-To: <20190324144404.GA32603@mail.hallyn.com>
From: Joel Fernandes <joelaf@google.com>
Date: Sun, 24 Mar 2019 14:48:51 -0400
Message-ID: <CAJWu+op62YzbpKmgMMXROt-qaAVfx++XsYQCcK6MHu1qBfd=fg@mail.gmail.com>
Subject: Re: pidfd design
To: "Serge E. Hallyn" <serge@hallyn.com>
Cc: Daniel Colascione <dancol@google.com>, Christian Brauner <christian@brauner.io>, 
	Joel Fernandes <joel@joelfernandes.org>, Suren Baghdasaryan <surenb@google.com>, 
	Steven Rostedt <rostedt@goodmis.org>, Sultan Alsawaf <sultan@kerneltoast.com>, 
	Tim Murray <timmurray@google.com>, Michal Hocko <mhocko@kernel.org>, 
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>, =?UTF-8?B?QXJ2ZSBIasO4bm5ldsOlZw==?= <arve@android.com>, 
	Todd Kjos <tkjos@android.com>, Martijn Coenen <maco@android.com>, Ingo Molnar <mingo@redhat.com>, 
	Peter Zijlstra <peterz@infradead.org>, LKML <linux-kernel@vger.kernel.org>, 
	"open list:ANDROID DRIVERS" <devel@driverdev.osuosl.org>, linux-mm <linux-mm@kvack.org>, 
	kernel-team <kernel-team@android.com>, Oleg Nesterov <oleg@redhat.com>, 
	Andy Lutomirski <luto@amacapital.net>, Kees Cook <keescook@chromium.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Mar 24, 2019 at 10:44 AM Serge E. Hallyn <serge@hallyn.com> wrote:
>
> On Wed, Mar 20, 2019 at 12:29:31PM -0700, Daniel Colascione wrote:
> > On Wed, Mar 20, 2019 at 11:52 AM Christian Brauner <christian@brauner.io> wrote:
> > > I really want to see Joel's pidfd_wait() patchset and have more people
> > > review the actual code.
> >
> > Sure. But it's also unpleasant to have people write code and then have
> > to throw it away due to guessing incorrectly about unclear
> > requirements.
>
> No, it is not.  It is not unpleasant.  And it is useful.  It is the best way to
> identify and resolve those incorrect guesses and unclear requirements.

No problem, a bit of discussion helped set the direction. Personally
it did help clarify lot of things for me.  We are hard at work with
come up with an implementation and are looking at posting something
soon. I agree that the best is to discuss on actual code where
possible.

