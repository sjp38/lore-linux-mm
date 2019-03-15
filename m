Return-Path: <SRS0=L2Uh=RS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,URIBL_BLOCKED,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C8A16C43381
	for <linux-mm@archiver.kernel.org>; Fri, 15 Mar 2019 04:37:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6CB3D21871
	for <linux-mm@archiver.kernel.org>; Fri, 15 Mar 2019 04:37:03 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="gcS2AtPY"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6CB3D21871
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E3C046B026F; Fri, 15 Mar 2019 00:37:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DEBD06B0270; Fri, 15 Mar 2019 00:37:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D00506B0271; Fri, 15 Mar 2019 00:37:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f198.google.com (mail-vk1-f198.google.com [209.85.221.198])
	by kanga.kvack.org (Postfix) with ESMTP id A25276B026F
	for <linux-mm@kvack.org>; Fri, 15 Mar 2019 00:37:02 -0400 (EDT)
Received: by mail-vk1-f198.google.com with SMTP id q135so2961910vke.9
        for <linux-mm@kvack.org>; Thu, 14 Mar 2019 21:37:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=qRJfx8d8wwSbLNVreftx8lfkpWiLNOWZSCO4KdGkoZE=;
        b=oioFQQp3UdNEFi2QFuDGMf2p3FkG6wmwJPXQ/ewzv+ncFNGJ/b1JA4Vfz0fGFvXUaj
         cfhXdo3L2kJ9JXcfr3mkDmN3lhx8SSWAS2503jOceC8DjTpiSoZHDWxuGPHRN2f5mpkl
         Xat3hEcbfAw9cmkg/YDT5ecPom884fr84Pk5HD5NLicp9/yKAmngK4+mUqAMtcZWKkB8
         YFGtq9HRGpv8CVWK5Cqt1CdOTVpu5V8daJ1MYg1GL7X9ESeMPyIBFBWlrbeqEvkDMdqZ
         uyROuAjm0ABqPYVFdARS+hM4ScQd7hVZoDrtPBenxwOg18AxxKaLD6Js4nmdUxDOpxCx
         lqvA==
X-Gm-Message-State: APjAAAXl9O09qhbhZvM99z0mhlJVjNGk5thJ1Si33WmVu0HB+Rpt8VyU
	SIXVOqCzvEoT815syWzmnr66NExfquVuZsAXP5+dZ+wCcxfReQDBv4e62N0DDlytCSTbUC/Pyeu
	00Oi2TwxyJJ+84UYtTMUltComA9cps0Bw7XOnhdoT9M1iS68rCXvpSk1egAdIxPQq7w==
X-Received: by 2002:a67:fac8:: with SMTP id g8mr979480vsq.216.1552624622244;
        Thu, 14 Mar 2019 21:37:02 -0700 (PDT)
X-Received: by 2002:a67:fac8:: with SMTP id g8mr979449vsq.216.1552624621110;
        Thu, 14 Mar 2019 21:37:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552624621; cv=none;
        d=google.com; s=arc-20160816;
        b=QVH+PftCC5Se3GeKkAPTQEwSlL+GYEb1baMQPINvCw/cNy99hXAPkNrONhqEx7jRJc
         niN7t3lOVeUpE/CoCWy+xfSbeOcohnbkPILxizlAruZbdewyQlm+qZY1+YwQhg9RkV8x
         rHYtVzP5fAOLWcHrv3SRBkRu6lrzAUNXF2HaU0DNF8tLBRi+VWPBxQKwRaiWhMwYpV/n
         bj0bRYqS51wazxhvOzWxoOlbLJpdzM22GKKvNOWDWCOpr85dUSX4NkwIxsppzf80zKgU
         PrlX2yRJu3ZyoktnEHdl/qdKl0jN+NQtBWPEjVV/0nXnMc1uXq2vG1QRcxy4wl/0yLSC
         e2uQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=qRJfx8d8wwSbLNVreftx8lfkpWiLNOWZSCO4KdGkoZE=;
        b=JuCiz5g6ayq04r38WEhJwo6VxiLPlTrsHsJIJDDLFxQ210B/xwGfc3ap3Ps/er1KxP
         zHNKtJu6AlKvEekFKWcLsjgaUa0Y4NqjwRuYmV9th3NPvudWs6U1smG+9plnI8yc2ZWg
         o0tYZY/Dr+w/o6SNbBQ68Xlhy+ODxJM7eZzu0APGGTBiKw27UndW89CkP9vJhOousZp6
         rnvYDqSZ2+S7rZOi0gylMHY9PkQkCD5qy3B0xjb2+OH/hfKE9GkUFlMLNxt2H4wauhzp
         ag2ygvDLBA+YXy7IF0/PykuybAAq9y0er8S4KL+OXj7gk8+bs8FedcE7u8U3gtXGpVtg
         BZpw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=gcS2AtPY;
       spf=pass (google.com: domain of dancol@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dancol@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m12sor537714vsr.74.2019.03.14.21.37.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 14 Mar 2019 21:37:01 -0700 (PDT)
Received-SPF: pass (google.com: domain of dancol@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=gcS2AtPY;
       spf=pass (google.com: domain of dancol@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dancol@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=qRJfx8d8wwSbLNVreftx8lfkpWiLNOWZSCO4KdGkoZE=;
        b=gcS2AtPYq9RcGfmdl9URgJvn4S1LnS4pd+KjMfsIG02p0PTciI1jbnjznNyD342MKu
         Bb22f7bpaAj62IhP0hSzIIQ8mIbYH3AfJz8GuZuNSWGyXllw49oRw7RcvwRJDxFtLfeX
         +NU1mhuAS/qPETrQNp0JSPUi5JoAUs6KBbAZ7aIUJ8YMAh8db76GvDekyLm6PWmURUqX
         AwKdC64OaKaZF3+wH+A+C7vZyqFEwbEV43onVopzP6/mZ3vSYIAHWdT1aIoe/B0FhoxK
         snkADwze4Sg0ek94ffY2aaBcorIHC7Egu+yMl91pEV2AaOMQjAJyIjIPz9pZqzA1YOdt
         9eJA==
X-Google-Smtp-Source: APXvYqyWkGqSaByD/VxAQsjOu0bmQBl9Vw+BiynR72qdp/w6atgkoiyBLI5D0jemnFeKsQOs+MH3gIJJI4iG91r/lDQ=
X-Received: by 2002:a67:f611:: with SMTP id k17mr968084vso.149.1552624620216;
 Thu, 14 Mar 2019 21:37:00 -0700 (PDT)
MIME-Version: 1.0
References: <20190310203403.27915-1-sultan@kerneltoast.com>
 <20190311174320.GC5721@dhcp22.suse.cz> <20190311175800.GA5522@sultan-box.localdomain>
 <CAJuCfpHTjXejo+u--3MLZZj7kWQVbptyya4yp1GLE3hB=BBX7w@mail.gmail.com>
 <20190311204626.GA3119@sultan-box.localdomain> <CAJuCfpGpBxofTT-ANEEY+dFCSdwkQswox3s8Uk9Eq0BnK9i0iA@mail.gmail.com>
 <20190312080532.GE5721@dhcp22.suse.cz> <20190312163741.GA2762@sultan-box.localdomain>
 <CAEe=Sxn_uayj48wo7oqf8mNZ7QAGJUQVmkPcHcuEGjA_Z8ELeQ@mail.gmail.com>
 <CAEXW_YQMnbN+e-janGbZc5MH6MwdUdXNfonpLUu5O2nsSkJyeg@mail.gmail.com>
 <20190314204911.GA875@sultan-box.localdomain> <20190314231641.5a37932b@oasis.local.home>
In-Reply-To: <20190314231641.5a37932b@oasis.local.home>
From: Daniel Colascione <dancol@google.com>
Date: Thu, 14 Mar 2019 21:36:43 -0700
Message-ID: <CAKOZuetZHJzmQy3n001x4+rmWoWHEgUv2Zvow9W5+xvukxp1JQ@mail.gmail.com>
Subject: Re: [RFC] simple_lmk: Introduce Simple Low Memory Killer for Android
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Sultan Alsawaf <sultan@kerneltoast.com>, Joel Fernandes <joel@joelfernandes.org>, 
	Tim Murray <timmurray@google.com>, Michal Hocko <mhocko@kernel.org>, 
	Suren Baghdasaryan <surenb@google.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, 
	=?UTF-8?B?QXJ2ZSBIasO4bm5ldsOlZw==?= <arve@android.com>, 
	Todd Kjos <tkjos@android.com>, Martijn Coenen <maco@android.com>, 
	Christian Brauner <christian@brauner.io>, Ingo Molnar <mingo@redhat.com>, 
	Peter Zijlstra <peterz@infradead.org>, LKML <linux-kernel@vger.kernel.org>, 
	"open list:ANDROID DRIVERS" <devel@driverdev.osuosl.org>, linux-mm <linux-mm@kvack.org>, 
	kernel-team <kernel-team@android.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Mar 14, 2019 at 8:16 PM Steven Rostedt <rostedt@goodmis.org> wrote:
>
> On Thu, 14 Mar 2019 13:49:11 -0700
> Sultan Alsawaf <sultan@kerneltoast.com> wrote:
>
> > Perhaps I'm missing something, but if you want to know when a process has died
> > after sending a SIGKILL to it, then why not just make the SIGKILL optionally
> > block until the process has died completely? It'd be rather trivial to just
> > store a pointer to an onstack completion inside the victim process' task_struct,
> > and then complete it in free_task().
>
> How would you implement such a method in userspace? kill() doesn't take
> any parameters but the pid of the process you want to send a signal to,
> and the signal to send. This would require a new system call, and be
> quite a bit of work.

That's what the pidfd work is for. Please read the original threads
about the motivation and design of that facility.

> If you can solve this with an ebpf program, I
> strongly suggest you do that instead.

Regarding process death notification: I will absolutely not support
putting aBPF and perf trace events on the critical path of core system
memory management functionality. Tracing and monitoring facilities are
great for learning about the system, but they were never intended to
be load-bearing. The proposed eBPF process-monitoring approach is just
a variant of the netlink proposal we discussed previously on the pidfd
threads; it has all of its drawbacks. We really need a core system
call  --- really, we've needed robust process management since the
creation of unix --- and I'm glad that we're finally getting it.
Adding new system calls is not expensive; going to great lengths to
avoid adding one is like calling a helicopter to avoid crossing the
street. I don't think we should present an abuse of the debugging and
performance monitoring infrastructure as an alternative to a robust
and desperately-needed bit of core functionality that's neither hard
to add nor complex to implement nor expensive to use.

Regarding the proposal for a new kernel-side lmkd: when possible, the
kernel should provide mechanism, not policy. Putting the low memory
killer back into the kernel after we've spent significant effort
making it possible for userspace to do that job. Compared to kernel
code, more easily understood, more easily debuggable, more easily
updated, and much safer. If we *can* move something out of the kernel,
we should. This patch moves us in exactly the wrong direction. Yes, we
need *something* that sits synchronously astride the page allocation
path and does *something* to stop a busy beaver allocator that eats
all the available memory before lmkd, even mlocked and realtime, can
respond. The OOM killer is adequate for this very rare case.

With respect to kill timing: Tim is right about the need for two
levels of policy: first, a high-level process prioritization and
memory-demand balancing scheme (which is what OOM score adjustment
code in ActivityManager amounts to); and second, a low-level
process-killing methodology that maximizes sustainable memory reclaim
and minimizes unwanted side effects while killing those processes that
should be dead. Both of these policies belong in userspace --- because
they *can* be in userspace --- and userspace needs only a few tools,
most of which already exist, to do a perfectly adequate job.

We do want killed processes to die promptly. That's why I support
boosting a process's priority somehow when lmkd is about to kill it.
The precise way in which we do that --- involving not only actual
priority, but scheduler knobs, cgroup assignment, core affinity, and
so on --- is a complex topic best left to userspace. lmkd already has
all the knobs it needs to implement whatever priority boosting policy
it wants.

Hell, once we add a pidfd_wait --- which I plan to work on, assuming
nobody beats me to it, after pidfd_send_signal lands --- you can
imagine a general-purpose priority inheritance mechanism expediting
process death when a high-priority process waits on a pidfd_wait
handle for a condemned process. You know you're on the right track
design-wise when you start seeing this kind of elegant constructive
interference between seemingly-unrelated features. What we don't need
is some kind of blocking SIGKILL alternative or backdoor event
delivery system.

We definitely don't want to have to wait for a process's parent to
reap it. Instead, we want to wait for it to become a zombie. That's
why I designed my original exithand patch to fire death notification
upon transition to the zombie state, not upon process table removal,
and I expect pidfd_wait (or whatever we call it) to act the same way.

In any case, there's a clear path forward here --- general-purpose,
cheap, and elegant --- and we should just focus on doing that instead
of more complex proposals with few advantages.

