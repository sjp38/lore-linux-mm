Return-Path: <SRS0=HgWV=RT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,URIBL_BLOCKED,USER_IN_DEF_DKIM_WL autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6BA4EC10F03
	for <linux-mm@archiver.kernel.org>; Sat, 16 Mar 2019 17:32:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id ECCC2218FC
	for <linux-mm@archiver.kernel.org>; Sat, 16 Mar 2019 17:31:59 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="KO4HUFda"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org ECCC2218FC
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5C5826B02D7; Sat, 16 Mar 2019 13:31:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 574026B02D8; Sat, 16 Mar 2019 13:31:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 463656B02D9; Sat, 16 Mar 2019 13:31:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f69.google.com (mail-io1-f69.google.com [209.85.166.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1D1876B02D7
	for <linux-mm@kvack.org>; Sat, 16 Mar 2019 13:31:59 -0400 (EDT)
Received: by mail-io1-f69.google.com with SMTP id w19so9771019ioa.15
        for <linux-mm@kvack.org>; Sat, 16 Mar 2019 10:31:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=KYThlM/qCXw00qK9OcGbl490CqSKkPBQ60AjUWblE34=;
        b=TLHhNoGXOe4FmqRxHsG9IAR6gD2HyZwMpTE/yZpRK07o2ghkSMXG1JS7sgP8G9kCjp
         tBIR7S95tPeHe0VGBa7NwPmRUcOoki7VB9jXmtAvzUeaOIXmWt9bz/LaozblQOjsDFLa
         3Awt0P9yrgo8bSABS7suGkgUmumm0apu9bj4zQXhHahotIoSFNCi/XqOkKvxfWx1V6o2
         rxOOUPw2zwRFQPi1h7n0rljpWAwksF7CEAF2azLPJifwYse23Y1oSf6yfjWgxcsUkF4h
         U1j3FKQEaDZKqomBgORGzUTPwl90suuSVW8nuH3hhmSmQPvd9TfV9GjKzqcK5DGvcex4
         W4wg==
X-Gm-Message-State: APjAAAWy44V0FJ2n5K7K25KRNUju6hOL1q9xBXWLrBxAg7Q4Y6E02y+l
	laQH7AlAUo0MaB8I2tP5jPO5XdHK/3dMZd1zlagFaQsgJ1XeBhtkUdvv24Q/CzGZDYM3uMkx2HM
	8xyjGd5HguhQ7alilNEKofMG6g578x9wCYtFxSuf+KEJdwIBwHcM1TloYjURItz/dHA==
X-Received: by 2002:a5d:9252:: with SMTP id e18mr3753894iol.97.1552757518864;
        Sat, 16 Mar 2019 10:31:58 -0700 (PDT)
X-Received: by 2002:a5d:9252:: with SMTP id e18mr3753858iol.97.1552757517710;
        Sat, 16 Mar 2019 10:31:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552757517; cv=none;
        d=google.com; s=arc-20160816;
        b=CRawJoDI9HytWz033bglNl0oCKKhzKwXRPWOpBFZwzQGeAMR3AvjRawvsxcXVKRnF8
         LeGim4Me+5KogBsuOUMCFzCN33uwPxHN36GIjHEwbtZbJl772hov4UuSXjOAFLa3dG9G
         BEPQYoWUsOMVtI/B7re8tKwlg6rmklSRUXMTvPkCVWUm1mQvoIC0ndsOZj/TpRiJXPMu
         GgiN1G2GY1faw9ogJZ5z+IyMJlrDWcSG0eHvjmn+CalDGpzk2hhPVBnO94wI2sGJp5zH
         fkbThiOmcLShLQlvbd0H0fORPVKEKIvGx2VCYqa1l6JOtEmK9VTWAceJADt+90y2tEnf
         vLcA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=KYThlM/qCXw00qK9OcGbl490CqSKkPBQ60AjUWblE34=;
        b=fduVNYMSdbpT6dtHRJC03FBxzKOEoSpUkkM33O1EgimORyz8r0FAHmYZGTC5Ykp3Rc
         T01LyvF5jBzdpMsV1/+xnNM/ooSHi22PVfB5PDwliB1JBClZselX8YOtP6J9P9eeFki+
         J3IPs3c9nyu4MDcj4672MaYv1PBjaLLQ6kS57ZjTGLM4E1/jP7MHbH6zsBWyBAADYKdG
         qBKS5b59wEWRoeNycly7jS+kiR2ROuptSrFrmrdcAKn2Uvvl5wI8l06ZOLme7xGD5cCu
         0VLzYw0ZxsjsNelEPnCpISiLXtdMyYf65Q2kqMGXY2ux4EpC/kCdu4avKcq7R2d745Bd
         jxAA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=KO4HUFda;
       spf=pass (google.com: domain of surenb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=surenb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l199sor9605606itb.13.2019.03.16.10.31.57
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 16 Mar 2019 10:31:57 -0700 (PDT)
Received-SPF: pass (google.com: domain of surenb@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=KO4HUFda;
       spf=pass (google.com: domain of surenb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=surenb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=KYThlM/qCXw00qK9OcGbl490CqSKkPBQ60AjUWblE34=;
        b=KO4HUFdasxYjpZit8xzAdrzX3PBnIR59Q8mfN2yqzNNLtwCv/B5sGYk0aGAR40yauC
         o5DLvJL3OhvMW0yc6b1wcUs/qLwDFmNo8ROLYmtVRe4PDzCHn99q1IIUJTXtMBq39Y3K
         tGIu8ho1JVwOxhj1encTIOw6Uwoxtvw4q+fmnyPQQwdr5rxKsdiYP/8EQZ6cRn3ULUhU
         9FhpDsMPK2zlUeYao+qRvuPaXk0Y+ZUREdrvseBmAW6esd7lObxe9Uh5PkY4enhNE1R5
         1phbsPrW1YxF0wRNt7YgFU8HwgakmxfGxyCGxWs+zsl32RLVeJUV4EBQ8//+H3CiF9vR
         JkkQ==
X-Google-Smtp-Source: APXvYqwt3/NtY1q8kvFlPOBO8aAygdzNFbwruR4bWzyFB6EZq2v0Sr+JUDk4Sb3kyGisVrDfsJmtDtwpE8MdHJCY52o=
X-Received: by 2002:a24:3c53:: with SMTP id m80mr1087932ita.102.1552757516935;
 Sat, 16 Mar 2019 10:31:56 -0700 (PDT)
MIME-Version: 1.0
References: <20190312080532.GE5721@dhcp22.suse.cz> <20190312163741.GA2762@sultan-box.localdomain>
 <CAEe=Sxn_uayj48wo7oqf8mNZ7QAGJUQVmkPcHcuEGjA_Z8ELeQ@mail.gmail.com>
 <CAEXW_YQMnbN+e-janGbZc5MH6MwdUdXNfonpLUu5O2nsSkJyeg@mail.gmail.com>
 <20190314204911.GA875@sultan-box.localdomain> <20190314231641.5a37932b@oasis.local.home>
 <CAKOZuetZHJzmQy3n001x4+rmWoWHEgUv2Zvow9W5+xvukxp1JQ@mail.gmail.com>
 <20190315180306.sq3z645p3hygrmt2@brauner.io> <20190315181324.GA248160@google.com>
 <20190315182426.sujcqbzhzw4llmsa@brauner.io> <20190315184903.GB248160@google.com>
In-Reply-To: <20190315184903.GB248160@google.com>
From: Suren Baghdasaryan <surenb@google.com>
Date: Sat, 16 Mar 2019 10:31:45 -0700
Message-ID: <CAJuCfpGp_9fE9MPGVCWjnTaeBE0K_Q22LS1pBqhp7zW2M=dbGw@mail.gmail.com>
Subject: Re: [RFC] simple_lmk: Introduce Simple Low Memory Killer for Android
To: Joel Fernandes <joel@joelfernandes.org>
Cc: Christian Brauner <christian@brauner.io>, Daniel Colascione <dancol@google.com>, 
	Steven Rostedt <rostedt@goodmis.org>, Sultan Alsawaf <sultan@kerneltoast.com>, 
	Tim Murray <timmurray@google.com>, Michal Hocko <mhocko@kernel.org>, 
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>, =?UTF-8?B?QXJ2ZSBIasO4bm5ldsOlZw==?= <arve@android.com>, 
	Todd Kjos <tkjos@android.com>, Martijn Coenen <maco@android.com>, Ingo Molnar <mingo@redhat.com>, 
	Peter Zijlstra <peterz@infradead.org>, LKML <linux-kernel@vger.kernel.org>, 
	"open list:ANDROID DRIVERS" <devel@driverdev.osuosl.org>, linux-mm <linux-mm@kvack.org>, 
	kernel-team <kernel-team@android.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Mar 15, 2019 at 11:49 AM Joel Fernandes <joel@joelfernandes.org> wrote:
>
> On Fri, Mar 15, 2019 at 07:24:28PM +0100, Christian Brauner wrote:
> [..]
> > > why do we want to add a new syscall (pidfd_wait) though? Why not just use
> > > standard poll/epoll interface on the proc fd like Daniel was suggesting.
> > > AFAIK, once the proc file is opened, the struct pid is essentially pinned
> > > even though the proc number may be reused. Then the caller can just poll.
> > > We can add a waitqueue to struct pid, and wake up any waiters on process
> > > death (A quick look shows task_struct can be mapped to its struct pid) and
> > > also possibly optimize it using Steve's TIF flag idea. No new syscall is
> > > needed then, let me know if I missed something?
> >
> > Huh, I thought that Daniel was against the poll/epoll solution?
>
> Hmm, going through earlier threads, I believe so now. Here was Daniel's
> reasoning about avoiding a notification about process death through proc
> directory fd: http://lkml.iu.edu/hypermail/linux/kernel/1811.0/00232.html
>
> May be a dedicated syscall for this would be cleaner after all.

Ah, I wish I've seen that discussion before...
syscall makes sense and it can be non-blocking and we can use
select/poll/epoll if we use eventfd. I would strongly advocate for
non-blocking version or at least to have a non-blocking option.
Something like this:

evfd = eventfd(0, EFD_NONBLOCK | EFD_CLOEXEC);
// register eventfd to receive death notification
pidfd_wait(pid_to_kill, evfd);
// kill the process
pidfd_send_signal(pid_to_kill, ...)
// tend to other things
...
// wait for the process to die
poll_wait(evfd, ...);

This simplifies userspace, allows it to wait for multiple events using
epoll and I think kernel implementation will be also quite simple
because it already implements eventfd_signal() that takes care of
waitqueue handling.

If pidfd_send_signal could be extended to have an optional eventfd
parameter then we would not even have to add a new syscall.

> > I have no clear opinion on what is better at the moment since I have
> > been mostly concerned with getting pidfd_send_signal() into shape and
> > was reluctant to put more ideas/work into this if it gets shutdown.
> > Once we have pidfd_send_signal() the wait discussion makes sense.
>
> Ok. It looks like that is almost in though (fingers crossed :)).
>
> thanks,
>
>  - Joel
>

