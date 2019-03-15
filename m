Return-Path: <SRS0=L2Uh=RS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,URIBL_BLOCKED,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BF831C43381
	for <linux-mm@archiver.kernel.org>; Fri, 15 Mar 2019 15:56:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4CF5B21872
	for <linux-mm@archiver.kernel.org>; Fri, 15 Mar 2019 15:56:55 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="sQKSe3w+"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4CF5B21872
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AB6366B0289; Fri, 15 Mar 2019 11:56:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A63346B028A; Fri, 15 Mar 2019 11:56:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 92C5C6B028B; Fri, 15 Mar 2019 11:56:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id 66B3C6B0289
	for <linux-mm@kvack.org>; Fri, 15 Mar 2019 11:56:54 -0400 (EDT)
Received: by mail-io1-f70.google.com with SMTP id i24so7306033iol.21
        for <linux-mm@kvack.org>; Fri, 15 Mar 2019 08:56:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=H4rtgT9B6M1B9LQmL3+oXFzPJ5+Ql+wZXXQfq4r7qxM=;
        b=gt4agNX6vrm5jdCTRvVF+WaW3i+pAKr4g2P76BNQgjSlqAqXqVnBm7uDIg9xmvWqG2
         UbcnCbd6295/d97ND3Nci5C0VynTqIaE8ePs4biwRktAftv3YC8bw0JKLwHIvpLgYzck
         AHcTMqEHwp/ppxcP1sEnnlSkccrMjFy7AsPSZIRoiu2yXjTgPL8BhqhrtJGn6KY/lJSU
         ztwmL8Lsvq11EX5+hKRwglJ7SCrXSFFOSu7pT7m0Bk/1xA1Yyf3ZyABT5AH/lNAJgkGG
         pIsnIKdxrTkBcy7/6nUfYfQjWb6Xf/BA4PEcvmyRGkHGK9JLe9K6EfezKL1YlV1g+gEF
         zl8Q==
X-Gm-Message-State: APjAAAW3vE3ZBaUo/+g/fx0VE3wWPfR7a7fjDtiXT1bJaDsJuQVkr45P
	ur5JXr3ahwbKsrPD1p+Osnt2BmyntXxWfrVkokKjxmkkYcLQiokXbLYoJYuJ0dNicieh39FCOoT
	LI4yKd5I3tM/xzdW+/CArIiTKtT8tN1NcXIgLwgbPOQFLHL65C/k9Sxt2qy0VmrIHAw==
X-Received: by 2002:a5e:dc0a:: with SMTP id b10mr2970878iok.34.1552665414090;
        Fri, 15 Mar 2019 08:56:54 -0700 (PDT)
X-Received: by 2002:a5e:dc0a:: with SMTP id b10mr2970808iok.34.1552665412805;
        Fri, 15 Mar 2019 08:56:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552665412; cv=none;
        d=google.com; s=arc-20160816;
        b=Ei7CnqdhKAdwfQtZVIZV+Y1JNeQcPNgIGepssijVusappgl+oqjxBuh8yY8P7Jye0n
         IdLr3TZz/W68BKNcuCBGXoLjcr0StGMuX12yyOulR+gkPN8SytpNERbcqD0VRMF4CsqA
         DtusC6Xs+iNfNxEE74sDctck/fOJnrD9UA8eN0raibYH9+yHrlOicD4pfR51s9kcE4nA
         ljBU05EF/bDW/sLjSIo8x+7f0lCRmR5x4bfdZqwmvoezqDPFFBP2W7jo70esESQl3VkY
         mhrLG+/7qV59LtZ0V7hoFqVvf6eqaSyJf11DbjvdRrHbKdWyckAJtGRumqFMwxxBGlYY
         piZg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=H4rtgT9B6M1B9LQmL3+oXFzPJ5+Ql+wZXXQfq4r7qxM=;
        b=CoH79QRUydZv17Qg4Qx6+11EUTFCABGrebUCvsBP6xcvEO1XOnIbTr4/G0hV89SVDm
         xdzryPokxvqA0kjvYk+KhFquAZzxssxSJo/ZZsVqi7A3Ukza/EoRJ+mFmVRjSHLth7Ku
         3jdwpow+xTvhkWXxZYo1ce/w/3Mg0F87TiqzRQvenoZE5PAimvSri1ZLchju/3pd+zfl
         Fwqmva/dNf7S7ZMgbVIHTfBUw5RNd4nmmClGwL0B30Uf/Jw8m5TjZsbG5FXohKDi4Iuo
         5I7fD0CLSx5uqDi68OG+CCmvd1aSN7SzU2qxyoIB7ncxq+Qqoe6fN5jhAVC7IiFQkzRh
         xZSg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=sQKSe3w+;
       spf=pass (google.com: domain of surenb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=surenb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u194sor3758937itb.26.2019.03.15.08.56.52
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 15 Mar 2019 08:56:52 -0700 (PDT)
Received-SPF: pass (google.com: domain of surenb@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=sQKSe3w+;
       spf=pass (google.com: domain of surenb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=surenb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=H4rtgT9B6M1B9LQmL3+oXFzPJ5+Ql+wZXXQfq4r7qxM=;
        b=sQKSe3w+XoNEOHxv44wL0wTqwONaxtUvQC34Q2Nez1GqGkGvEXukH/JAod5bOJXGHm
         OKGDpaVbIA/dn/74y/fofwr/x6nLERCAStBftMQvXXcbmjhz98E7nUE+wwdzHn3khfx+
         9FC1ns2uL6HfNp+q032A5iCx39NEwhkRkYXDmt5pB6fDuk8LyAj1frF2LnOOv6lj8lgD
         592ejppi3Gh6xhesU26P0CiVMsDdMDAR076ZgzCHEKe4oXwnXT7UB2gksgsfbwbQpcPB
         An5ekgh1mI2jscsUv9feC58UwwOfUQdGBYKOUdtUjOyki0GE6ap6da45meACeTZmwcCV
         sPRg==
X-Google-Smtp-Source: APXvYqyqcIlbt1RfAFrK2X9pXdPK7c9C3TBI78IspfigtRt/4QFN//wL64B3tnVby9qAAl/BFark1nkjyptSDxFdTH8=
X-Received: by 2002:a24:a81:: with SMTP id 123mr2553188itw.43.1552665412172;
 Fri, 15 Mar 2019 08:56:52 -0700 (PDT)
MIME-Version: 1.0
References: <20190310203403.27915-1-sultan@kerneltoast.com>
 <20190311174320.GC5721@dhcp22.suse.cz> <20190311175800.GA5522@sultan-box.localdomain>
 <CAJuCfpHTjXejo+u--3MLZZj7kWQVbptyya4yp1GLE3hB=BBX7w@mail.gmail.com>
 <20190311204626.GA3119@sultan-box.localdomain> <CAJuCfpGpBxofTT-ANEEY+dFCSdwkQswox3s8Uk9Eq0BnK9i0iA@mail.gmail.com>
 <20190312080532.GE5721@dhcp22.suse.cz> <20190312163741.GA2762@sultan-box.localdomain>
 <CAEe=Sxn_uayj48wo7oqf8mNZ7QAGJUQVmkPcHcuEGjA_Z8ELeQ@mail.gmail.com>
 <CAEXW_YQMnbN+e-janGbZc5MH6MwdUdXNfonpLUu5O2nsSkJyeg@mail.gmail.com>
 <20190314204911.GA875@sultan-box.localdomain> <20190314231641.5a37932b@oasis.local.home>
 <CAKOZuetZHJzmQy3n001x4+rmWoWHEgUv2Zvow9W5+xvukxp1JQ@mail.gmail.com>
In-Reply-To: <CAKOZuetZHJzmQy3n001x4+rmWoWHEgUv2Zvow9W5+xvukxp1JQ@mail.gmail.com>
From: Suren Baghdasaryan <surenb@google.com>
Date: Fri, 15 Mar 2019 08:56:40 -0700
Message-ID: <CAJuCfpFXhE0LwLf-KEuN8W5zqHh_nLzgv7DGjrePiSr6xkvSKA@mail.gmail.com>
Subject: Re: [RFC] simple_lmk: Introduce Simple Low Memory Killer for Android
To: Daniel Colascione <dancol@google.com>
Cc: Steven Rostedt <rostedt@goodmis.org>, Sultan Alsawaf <sultan@kerneltoast.com>, 
	Joel Fernandes <joel@joelfernandes.org>, Tim Murray <timmurray@google.com>, 
	Michal Hocko <mhocko@kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, 
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

On Thu, Mar 14, 2019 at 9:37 PM Daniel Colascione <dancol@google.com> wrote:
>
> On Thu, Mar 14, 2019 at 8:16 PM Steven Rostedt <rostedt@goodmis.org> wrote:
> >
> > On Thu, 14 Mar 2019 13:49:11 -0700
> > Sultan Alsawaf <sultan@kerneltoast.com> wrote:
> >
> > > Perhaps I'm missing something, but if you want to know when a process has died
> > > after sending a SIGKILL to it, then why not just make the SIGKILL optionally
> > > block until the process has died completely? It'd be rather trivial to just
> > > store a pointer to an onstack completion inside the victim process' task_struct,
> > > and then complete it in free_task().
> >
> > How would you implement such a method in userspace? kill() doesn't take
> > any parameters but the pid of the process you want to send a signal to,
> > and the signal to send. This would require a new system call, and be
> > quite a bit of work.
>
> That's what the pidfd work is for. Please read the original threads
> about the motivation and design of that facility.
>
> > If you can solve this with an ebpf program, I
> > strongly suggest you do that instead.
>
> Regarding process death notification: I will absolutely not support
> putting aBPF and perf trace events on the critical path of core system
> memory management functionality. Tracing and monitoring facilities are
> great for learning about the system, but they were never intended to
> be load-bearing. The proposed eBPF process-monitoring approach is just
> a variant of the netlink proposal we discussed previously on the pidfd
> threads; it has all of its drawbacks. We really need a core system
> call  --- really, we've needed robust process management since the
> creation of unix --- and I'm glad that we're finally getting it.
> Adding new system calls is not expensive; going to great lengths to
> avoid adding one is like calling a helicopter to avoid crossing the
> street. I don't think we should present an abuse of the debugging and
> performance monitoring infrastructure as an alternative to a robust
> and desperately-needed bit of core functionality that's neither hard
> to add nor complex to implement nor expensive to use.
>
> Regarding the proposal for a new kernel-side lmkd: when possible, the
> kernel should provide mechanism, not policy. Putting the low memory
> killer back into the kernel after we've spent significant effort
> making it possible for userspace to do that job. Compared to kernel
> code, more easily understood, more easily debuggable, more easily
> updated, and much safer. If we *can* move something out of the kernel,
> we should. This patch moves us in exactly the wrong direction. Yes, we
> need *something* that sits synchronously astride the page allocation
> path and does *something* to stop a busy beaver allocator that eats
> all the available memory before lmkd, even mlocked and realtime, can
> respond. The OOM killer is adequate for this very rare case.
>
> With respect to kill timing: Tim is right about the need for two
> levels of policy: first, a high-level process prioritization and
> memory-demand balancing scheme (which is what OOM score adjustment
> code in ActivityManager amounts to); and second, a low-level
> process-killing methodology that maximizes sustainable memory reclaim
> and minimizes unwanted side effects while killing those processes that
> should be dead. Both of these policies belong in userspace --- because
> they *can* be in userspace --- and userspace needs only a few tools,
> most of which already exist, to do a perfectly adequate job.
>
> We do want killed processes to die promptly. That's why I support
> boosting a process's priority somehow when lmkd is about to kill it.
> The precise way in which we do that --- involving not only actual
> priority, but scheduler knobs, cgroup assignment, core affinity, and
> so on --- is a complex topic best left to userspace. lmkd already has
> all the knobs it needs to implement whatever priority boosting policy
> it wants.
>
> Hell, once we add a pidfd_wait --- which I plan to work on, assuming
> nobody beats me to it, after pidfd_send_signal lands --- you can
> imagine a general-purpose priority inheritance mechanism expediting
> process death when a high-priority process waits on a pidfd_wait
> handle for a condemned process. You know you're on the right track
> design-wise when you start seeing this kind of elegant constructive
> interference between seemingly-unrelated features. What we don't need
> is some kind of blocking SIGKILL alternative or backdoor event
> delivery system.

When talking about pidfd_wait functionality do you mean something like
this: https://lore.kernel.org/patchwork/patch/345098/ ? I missed the
discussion about it, could you please point me to it?

> We definitely don't want to have to wait for a process's parent to
> reap it. Instead, we want to wait for it to become a zombie. That's
> why I designed my original exithand patch to fire death notification
> upon transition to the zombie state, not upon process table removal,
> and I expect pidfd_wait (or whatever we call it) to act the same way.
>
> In any case, there's a clear path forward here --- general-purpose,
> cheap, and elegant --- and we should just focus on doing that instead
> of more complex proposals with few advantages.

