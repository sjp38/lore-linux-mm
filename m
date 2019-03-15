Return-Path: <SRS0=L2Uh=RS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_PASS,USER_AGENT_NEOMUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EFB62C43381
	for <linux-mm@archiver.kernel.org>; Fri, 15 Mar 2019 18:03:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 993B42186A
	for <linux-mm@archiver.kernel.org>; Fri, 15 Mar 2019 18:03:13 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=brauner.io header.i=@brauner.io header.b="LeCRrCsu"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 993B42186A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=brauner.io
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1CBA26B029B; Fri, 15 Mar 2019 14:03:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 152026B029C; Fri, 15 Mar 2019 14:03:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F35636B029D; Fri, 15 Mar 2019 14:03:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 98CB76B029B
	for <linux-mm@kvack.org>; Fri, 15 Mar 2019 14:03:12 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id o12so3619300edv.21
        for <linux-mm@kvack.org>; Fri, 15 Mar 2019 11:03:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=DLrG7C2HgPVhdjQ05Nw+pYKzUhstGE6Y6qauRU146Cs=;
        b=lKiGPl+kKuEIOpntWvH3yjG8EUfCT1ZU/GMzFWP1LW2tekHxT6JIc/8IE4NUlrMM7L
         5o9uJYg1cYWY0cchDZIqtBjSiVdUq3XuhGmmlZgat77lnlMgro6cyddqqPSqFClSzApf
         AEymaD7xaqHU8tJqbVt9Tdo/KVsJdA89OMJNHLSB8xdEFVor5TAhyAphQgzc/Bl1LZji
         YUwvGpBQMJ0VCRktKrTz+Bj1dl3M6Bn7N6NhbP2BKDanPflCk7fpZ/liKvYnmfgKWHNt
         ISzEimFz/DaJiTIQyYRFi41Z9UGoBLfEDf47PaGz6nIUFc+OL1qgt+hE30ajDsH/bbR2
         97kg==
X-Gm-Message-State: APjAAAWmaQWocanLnez2aHc03doOoUQctEQ2cpsupRKrdgsU9Ls1ZaPj
	yOQM6jsB9mXWn/iwr7WYFwNSTgGk1gDDXNLCAM8Im09dNGHCmJdmNPabfbu58DB7mThsscgUaGB
	Y9rve7A8B9Nu8JAACFb145iySZTaHw1LBdn9ggjMZ0ChhB4a3sUBgx2DMrMvKv1nvhw==
X-Received: by 2002:aa7:d909:: with SMTP id a9mr3653837edr.95.1552672992045;
        Fri, 15 Mar 2019 11:03:12 -0700 (PDT)
X-Received: by 2002:aa7:d909:: with SMTP id a9mr3653765edr.95.1552672990574;
        Fri, 15 Mar 2019 11:03:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552672990; cv=none;
        d=google.com; s=arc-20160816;
        b=fCsM+9PRMm+H/RlN00acW+hkOjedVcgflZ32HyMDyCT5yMmWT96kJhgiUU8UstkfaN
         TOYoCE4vSjkS9OtNQK5P6l7kjZBdBuZaVT6U8dIpuJeRIB8wb0Ilv444oFfa1Wtm7nyW
         NOLJibxZZehTG6IIM/1eS29q17TNe5NupSlnJ5ZqyNAx4EC/qlc1txPJXQpijF55o9ce
         wg81gCj/lVPQedDgD0zj93RzpPMWmLpCw/pH0wO8OzwhonLnCAqDDZS/u9sWDOTsti+8
         DI9VrILBT2Z1CyoZ2Ap5pCYeUYTZTiv+iiL0/1qjSK+BAMoCOShLfQ8qoUK98BV884bj
         UTbw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=DLrG7C2HgPVhdjQ05Nw+pYKzUhstGE6Y6qauRU146Cs=;
        b=GSp87AI8v1f1/Fu4xXcnaHrNRTxePSkFbpv0TApmtO+MYm9O6dKiVb30FSyf2J8H/B
         nsTKRiNjwrE7cxZMUOPNMvkqPIT4KmMusR0A38I9CqzY82irja7eS0DdEy1TUaWrFVGK
         MhcDhFbWcMUy8QHvwraE3KpoIiXNMrRb6i7CT3nCI9/GCZ6NnD79flXlWkkaoiz6mPRq
         7tJnPJYHnJ9HgNK/nS0qEeSnrGufT0sJUpPXTEhccj+eGYsmVxaFRa6zrfMH6SJQo0ie
         9ASQakGqpvSnGbZUsWTaqrU7ElbD66UHxmDR27Onvt2gbalQSWrFS4rK1gkyz/hgWEJX
         lkbw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@brauner.io header.s=google header.b=LeCRrCsu;
       spf=pass (google.com: domain of christian@brauner.io designates 209.85.220.65 as permitted sender) smtp.mailfrom=christian@brauner.io
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c50sor1747602eda.27.2019.03.15.11.03.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 15 Mar 2019 11:03:10 -0700 (PDT)
Received-SPF: pass (google.com: domain of christian@brauner.io designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@brauner.io header.s=google header.b=LeCRrCsu;
       spf=pass (google.com: domain of christian@brauner.io designates 209.85.220.65 as permitted sender) smtp.mailfrom=christian@brauner.io
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=brauner.io; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=DLrG7C2HgPVhdjQ05Nw+pYKzUhstGE6Y6qauRU146Cs=;
        b=LeCRrCsuWUax2GnMHCyUkm7AKx9GdoM7m8QE9QSSWXj88BIMKJMNS2i5rac7HWoKh7
         cva0i75CE1uuwWvQMdq3ZakOWWv718Es4yNU/k4tS8i73vCVf5NVQ2akO6gUScpLv/jX
         T0oAWnk2qQ5gw/Cs9S0J3ut7uUJx9OQ8//jXVFraWJXPs2TgAa1YzYqf7QPbt6OY3waI
         Kso7VKQAXoNnuaAzekQLC0xLRj1Pa79N/wilpedKf50gmrMYkbHQsVKKvTCjAuJ6Mu8G
         wlApWgZSmx0UpSjvYlqOP4UOVXnA2NEe1BleanzWjQZuWNn7ogSS3gr2cWReT34dqwH3
         QS7g==
X-Google-Smtp-Source: APXvYqzAi+6+LWdaGff9CwBmx3wYwQ10pT8T92ZtjsHtcC07gqsQz3ESBNjuhUGiol1OcSZ4lA0NlA==
X-Received: by 2002:a50:c9c9:: with SMTP id c9mr3731045edi.96.1552672990025;
        Fri, 15 Mar 2019 11:03:10 -0700 (PDT)
Received: from brauner.io ([2a02:8109:b6c0:76e:dd26:cbb7:1dbc:50af])
        by smtp.gmail.com with ESMTPSA id r3sm561481ejb.55.2019.03.15.11.03.08
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Fri, 15 Mar 2019 11:03:09 -0700 (PDT)
Date: Fri, 15 Mar 2019 19:03:07 +0100
From: Christian Brauner <christian@brauner.io>
To: Daniel Colascione <dancol@google.com>
Cc: Steven Rostedt <rostedt@goodmis.org>,
	Sultan Alsawaf <sultan@kerneltoast.com>,
	Joel Fernandes <joel@joelfernandes.org>,
	Tim Murray <timmurray@google.com>, Michal Hocko <mhocko@kernel.org>,
	Suren Baghdasaryan <surenb@google.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Arve =?utf-8?B?SGrDuG5uZXbDpWc=?= <arve@android.com>,
	Todd Kjos <tkjos@android.com>, Martijn Coenen <maco@android.com>,
	Ingo Molnar <mingo@redhat.com>,
	Peter Zijlstra <peterz@infradead.org>,
	LKML <linux-kernel@vger.kernel.org>,
	"open list:ANDROID DRIVERS" <devel@driverdev.osuosl.org>,
	linux-mm <linux-mm@kvack.org>,
	kernel-team <kernel-team@android.com>
Subject: Re: [RFC] simple_lmk: Introduce Simple Low Memory Killer for Android
Message-ID: <20190315180306.sq3z645p3hygrmt2@brauner.io>
References: <CAJuCfpHTjXejo+u--3MLZZj7kWQVbptyya4yp1GLE3hB=BBX7w@mail.gmail.com>
 <20190311204626.GA3119@sultan-box.localdomain>
 <CAJuCfpGpBxofTT-ANEEY+dFCSdwkQswox3s8Uk9Eq0BnK9i0iA@mail.gmail.com>
 <20190312080532.GE5721@dhcp22.suse.cz>
 <20190312163741.GA2762@sultan-box.localdomain>
 <CAEe=Sxn_uayj48wo7oqf8mNZ7QAGJUQVmkPcHcuEGjA_Z8ELeQ@mail.gmail.com>
 <CAEXW_YQMnbN+e-janGbZc5MH6MwdUdXNfonpLUu5O2nsSkJyeg@mail.gmail.com>
 <20190314204911.GA875@sultan-box.localdomain>
 <20190314231641.5a37932b@oasis.local.home>
 <CAKOZuetZHJzmQy3n001x4+rmWoWHEgUv2Zvow9W5+xvukxp1JQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <CAKOZuetZHJzmQy3n001x4+rmWoWHEgUv2Zvow9W5+xvukxp1JQ@mail.gmail.com>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Mar 14, 2019 at 09:36:43PM -0700, Daniel Colascione wrote:
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

Daniel,

I've just been talking to Joel.
I actually "expected" you to work pidfd_wait() after prior
conversations we had on the pidfd_send_signal() patchsets. :) That's why
I got a separate git tree on kernel.org since I expect a lot more work
to come. I hope that Linus still decides to pull pidfd_send_signal()
before Sunday (For the ones who have missed the link in a prior response
of mine:
https://lkml.org/lkml/2019/3/12/439

This is the first merge window I sent this PR.

The pidfd tree has a branch for-next that is already tracked by Stephen
in linux-next since the 5.0 merge window. The patches for
pidfd_send_signal() sit in the pidfd branch.
I'd be happy to share the tree with you and Joel (We can rename it if
you prefer I don't care).
I would really like to centralize this work so that we sort of have a
"united front" and end up with a coherent api and can send PRs from a
centralized place:
https://git.kernel.org/pub/scm/linux/kernel/git/brauner/linux.git/

Christian

> imagine a general-purpose priority inheritance mechanism expediting
> process death when a high-priority process waits on a pidfd_wait
> handle for a condemned process. You know you're on the right track
> design-wise when you start seeing this kind of elegant constructive
> interference between seemingly-unrelated features. What we don't need
> is some kind of blocking SIGKILL alternative or backdoor event
> delivery system.
> 
> We definitely don't want to have to wait for a process's parent to
> reap it. Instead, we want to wait for it to become a zombie. That's
> why I designed my original exithand patch to fire death notification
> upon transition to the zombie state, not upon process table removal,
> and I expect pidfd_wait (or whatever we call it) to act the same way.
> 
> In any case, there's a clear path forward here --- general-purpose,
> cheap, and elegant --- and we should just focus on doing that instead
> of more complex proposals with few advantages.

