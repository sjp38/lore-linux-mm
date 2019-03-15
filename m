Return-Path: <SRS0=L2Uh=RS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CD286C43381
	for <linux-mm@archiver.kernel.org>; Fri, 15 Mar 2019 18:13:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7326D218AC
	for <linux-mm@archiver.kernel.org>; Fri, 15 Mar 2019 18:13:29 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=joelfernandes.org header.i=@joelfernandes.org header.b="pTRZUOR9"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7326D218AC
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=joelfernandes.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 08A9C6B029C; Fri, 15 Mar 2019 14:13:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 037D16B029E; Fri, 15 Mar 2019 14:13:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E414C6B029F; Fri, 15 Mar 2019 14:13:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id B89496B029C
	for <linux-mm@kvack.org>; Fri, 15 Mar 2019 14:13:28 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id c25so9482381qtj.13
        for <linux-mm@kvack.org>; Fri, 15 Mar 2019 11:13:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=q6eG5wgnw+unORojL17W/6kSteRzx3rHaBc67euHz48=;
        b=N2OGejc5Y0fdl9WpVFZs3I0BKljYDopeoqrmOJU7n04DYuPo7laEij5B8emxp6bkAZ
         4pyRnRsuHxHTRKIMDQGnUmLg02zbSr19Wg9WxSCs0O05jXQVevgPOwrkEUOn7+bcExVb
         Z+wIghWK8/hlJivFZdAna0wHnE9N8oqnCwz1Z7+rUhtayEJE5hdoalSSqQTqJ16peaqG
         WtnXbEwRpQPUrTN+tNRI6PatHKIEb00ml816w9N06nv4J+4SwZi/NDgY0nnQnWXlazOa
         j3Q2Rx67NQ2w4uy7fq095mSXmuuTq0pYAmjIUlCl1iTKy9p2ZqbmK4FXM3vz5yyj7F2j
         N5gg==
X-Gm-Message-State: APjAAAU9YEgXNThPSu2R7IQluHGcv3FWn+sqsr23H355ZIn9TTqNUYBE
	RQMleuVfCI4a6pobFKCi9ZeFkB/RP5/hj62237A5EI22+BDfDgYpbADqzS3747H0FxyqZv1hPJX
	EmJMK7b9GcClrjuWdIyxWx4GqfY+Mt8unVTP+319qyf6yWXn0dXL3PZB5rlbb5wuR2A==
X-Received: by 2002:a37:c20c:: with SMTP id i12mr3822914qkm.94.1552673608425;
        Fri, 15 Mar 2019 11:13:28 -0700 (PDT)
X-Received: by 2002:a37:c20c:: with SMTP id i12mr3822841qkm.94.1552673607104;
        Fri, 15 Mar 2019 11:13:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552673607; cv=none;
        d=google.com; s=arc-20160816;
        b=lv0RjeyFrvRp8FNVpssT/hqUCMO9kE48mVITQTZaoH158Lf+910jYCsiKwOoEu8sQ8
         dkHxEELaYQA6nTROtohiR9pa+untb1IY8kr4Yq3NkoUuDHWVu+9QI8+KHWZjZ+f5RI5r
         CvCNkHSO87AnPtXz+05WOHRWamkBmwLWU77L3eFD/eWs6WFaBFPjw9gQLnJ6C3XA85Xq
         P8Sj8qQfUbxP87z8wt3cmRDv2sN2r0Rg+c8JZNIZm7sUNBHmldZlYdL4FUiyHh9R6oSu
         DcjSu98nAHvPFuNIY5JNlUzhzvAxc3eXoiS9ncCXMMlIGJ+2XV1T2aQk3IkUZ4D1cn7Y
         qH7g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=q6eG5wgnw+unORojL17W/6kSteRzx3rHaBc67euHz48=;
        b=lt4tHMVyukZ+tbzCbEE/fBo1wARart0wYI3/lOXIkdDPE0KyVf/9erR2HXMP3yrZ+f
         4fnmc/gzHRBIIsjaYnsA4itAJqycZOzpF/43PPvyv6WMVqyT0dNZISvXS/ifh0AW2wqQ
         GrMki1llnp9YEKrwyqdAPPmdMZrWmkckiHzwobsejLzbczOcZNFFOglFczxtNXIkNNr7
         VH6lvR7KBRgDwEaFHA2OLXSCjJcPcqNVwQ2I+AHjIaL1UtfRfx1GXTkdoI0Hc+6xnqT4
         hApWdFUGsCV2IxGCNcjHmCwJ7t6ghrXDkYp+rd//E7P7l9yuTpWwTHsDHQAxl19fBqKL
         lmvA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@joelfernandes.org header.s=google header.b=pTRZUOR9;
       spf=pass (google.com: domain of joel@joelfernandes.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=joel@joelfernandes.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w14sor2950762qvi.17.2019.03.15.11.13.26
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 15 Mar 2019 11:13:27 -0700 (PDT)
Received-SPF: pass (google.com: domain of joel@joelfernandes.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@joelfernandes.org header.s=google header.b=pTRZUOR9;
       spf=pass (google.com: domain of joel@joelfernandes.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=joel@joelfernandes.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=joelfernandes.org; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=q6eG5wgnw+unORojL17W/6kSteRzx3rHaBc67euHz48=;
        b=pTRZUOR9tD01/yvyyitOYmlPRduSzM+RUbsLOCQUvtErFaPRT4aUBZXVpiTUmR+iaH
         qNHgc9BLYVYNZ86O/4fCGpLNQ6ysglYO1DQvE9espFgJXYrSpudfPqx5W+dXZQbOX9d5
         XsE4ke3/70ppALljmAuWoLCyr3GWB/cxgr16w=
X-Google-Smtp-Source: APXvYqyapHPhx1//x+Hc5HFAb2MjY04hpS7fCSjEDnWc8My3aeCiXQ6xAQfZ4yPmvPPGGZthqLWbog==
X-Received: by 2002:a0c:bc01:: with SMTP id j1mr3708437qvg.24.1552673606570;
        Fri, 15 Mar 2019 11:13:26 -0700 (PDT)
Received: from localhost ([2620:0:1004:1100:cca9:fccc:8667:9bdc])
        by smtp.gmail.com with ESMTPSA id v12sm1990632qth.12.2019.03.15.11.13.24
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 15 Mar 2019 11:13:24 -0700 (PDT)
Date: Fri, 15 Mar 2019 14:13:24 -0400
From: Joel Fernandes <joel@joelfernandes.org>
To: Christian Brauner <christian@brauner.io>
Cc: Daniel Colascione <dancol@google.com>,
	Steven Rostedt <rostedt@goodmis.org>,
	Sultan Alsawaf <sultan@kerneltoast.com>,
	Tim Murray <timmurray@google.com>, Michal Hocko <mhocko@kernel.org>,
	Suren Baghdasaryan <surenb@google.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Arve =?iso-8859-1?B?SGr4bm5lduVn?= <arve@android.com>,
	Todd Kjos <tkjos@android.com>, Martijn Coenen <maco@android.com>,
	Ingo Molnar <mingo@redhat.com>,
	Peter Zijlstra <peterz@infradead.org>,
	LKML <linux-kernel@vger.kernel.org>,
	"open list:ANDROID DRIVERS" <devel@driverdev.osuosl.org>,
	linux-mm <linux-mm@kvack.org>,
	kernel-team <kernel-team@android.com>
Subject: Re: [RFC] simple_lmk: Introduce Simple Low Memory Killer for Android
Message-ID: <20190315181324.GA248160@google.com>
References: <20190311204626.GA3119@sultan-box.localdomain>
 <CAJuCfpGpBxofTT-ANEEY+dFCSdwkQswox3s8Uk9Eq0BnK9i0iA@mail.gmail.com>
 <20190312080532.GE5721@dhcp22.suse.cz>
 <20190312163741.GA2762@sultan-box.localdomain>
 <CAEe=Sxn_uayj48wo7oqf8mNZ7QAGJUQVmkPcHcuEGjA_Z8ELeQ@mail.gmail.com>
 <CAEXW_YQMnbN+e-janGbZc5MH6MwdUdXNfonpLUu5O2nsSkJyeg@mail.gmail.com>
 <20190314204911.GA875@sultan-box.localdomain>
 <20190314231641.5a37932b@oasis.local.home>
 <CAKOZuetZHJzmQy3n001x4+rmWoWHEgUv2Zvow9W5+xvukxp1JQ@mail.gmail.com>
 <20190315180306.sq3z645p3hygrmt2@brauner.io>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190315180306.sq3z645p3hygrmt2@brauner.io>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Mar 15, 2019 at 07:03:07PM +0100, Christian Brauner wrote:
> On Thu, Mar 14, 2019 at 09:36:43PM -0700, Daniel Colascione wrote:
> > On Thu, Mar 14, 2019 at 8:16 PM Steven Rostedt <rostedt@goodmis.org> wrote:
> > >
> > > On Thu, 14 Mar 2019 13:49:11 -0700
> > > Sultan Alsawaf <sultan@kerneltoast.com> wrote:
> > >
> > > > Perhaps I'm missing something, but if you want to know when a process has died
> > > > after sending a SIGKILL to it, then why not just make the SIGKILL optionally
> > > > block until the process has died completely? It'd be rather trivial to just
> > > > store a pointer to an onstack completion inside the victim process' task_struct,
> > > > and then complete it in free_task().
> > >
> > > How would you implement such a method in userspace? kill() doesn't take
> > > any parameters but the pid of the process you want to send a signal to,
> > > and the signal to send. This would require a new system call, and be
> > > quite a bit of work.
> > 
> > That's what the pidfd work is for. Please read the original threads
> > about the motivation and design of that facility.
> > 
> > > If you can solve this with an ebpf program, I
> > > strongly suggest you do that instead.
> > 
> > Regarding process death notification: I will absolutely not support
> > putting aBPF and perf trace events on the critical path of core system
> > memory management functionality. Tracing and monitoring facilities are
> > great for learning about the system, but they were never intended to
> > be load-bearing. The proposed eBPF process-monitoring approach is just
> > a variant of the netlink proposal we discussed previously on the pidfd
> > threads; it has all of its drawbacks. We really need a core system
> > call  --- really, we've needed robust process management since the
> > creation of unix --- and I'm glad that we're finally getting it.
> > Adding new system calls is not expensive; going to great lengths to
> > avoid adding one is like calling a helicopter to avoid crossing the
> > street. I don't think we should present an abuse of the debugging and
> > performance monitoring infrastructure as an alternative to a robust
> > and desperately-needed bit of core functionality that's neither hard
> > to add nor complex to implement nor expensive to use.
> > 
> > Regarding the proposal for a new kernel-side lmkd: when possible, the
> > kernel should provide mechanism, not policy. Putting the low memory
> > killer back into the kernel after we've spent significant effort
> > making it possible for userspace to do that job. Compared to kernel
> > code, more easily understood, more easily debuggable, more easily
> > updated, and much safer. If we *can* move something out of the kernel,
> > we should. This patch moves us in exactly the wrong direction. Yes, we
> > need *something* that sits synchronously astride the page allocation
> > path and does *something* to stop a busy beaver allocator that eats
> > all the available memory before lmkd, even mlocked and realtime, can
> > respond. The OOM killer is adequate for this very rare case.
> > 
> > With respect to kill timing: Tim is right about the need for two
> > levels of policy: first, a high-level process prioritization and
> > memory-demand balancing scheme (which is what OOM score adjustment
> > code in ActivityManager amounts to); and second, a low-level
> > process-killing methodology that maximizes sustainable memory reclaim
> > and minimizes unwanted side effects while killing those processes that
> > should be dead. Both of these policies belong in userspace --- because
> > they *can* be in userspace --- and userspace needs only a few tools,
> > most of which already exist, to do a perfectly adequate job.
> > 
> > We do want killed processes to die promptly. That's why I support
> > boosting a process's priority somehow when lmkd is about to kill it.
> > The precise way in which we do that --- involving not only actual
> > priority, but scheduler knobs, cgroup assignment, core affinity, and
> > so on --- is a complex topic best left to userspace. lmkd already has
> > all the knobs it needs to implement whatever priority boosting policy
> > it wants.
> > 
> > Hell, once we add a pidfd_wait --- which I plan to work on, assuming
> > nobody beats me to it, after pidfd_send_signal lands --- you can
> 
> Daniel,
> 
> I've just been talking to Joel.
> I actually "expected" you to work pidfd_wait() after prior
> conversations we had on the pidfd_send_signal() patchsets. :) That's why
> I got a separate git tree on kernel.org since I expect a lot more work
> to come. I hope that Linus still decides to pull pidfd_send_signal()
> before Sunday (For the ones who have missed the link in a prior response
> of mine:
> https://lkml.org/lkml/2019/3/12/439
> 
> This is the first merge window I sent this PR.
> 
> The pidfd tree has a branch for-next that is already tracked by Stephen
> in linux-next since the 5.0 merge window. The patches for
> pidfd_send_signal() sit in the pidfd branch.
> I'd be happy to share the tree with you and Joel (We can rename it if
> you prefer I don't care).
> I would really like to centralize this work so that we sort of have a
> "united front" and end up with a coherent api and can send PRs from a
> centralized place:
> https://git.kernel.org/pub/scm/linux/kernel/git/brauner/linux.git/

I am totally onboard with working together / reviewing this work with you all
on a common tree somewhere (Christian's pidfd tree is fine). I was curious,
why do we want to add a new syscall (pidfd_wait) though? Why not just use
standard poll/epoll interface on the proc fd like Daniel was suggesting.
AFAIK, once the proc file is opened, the struct pid is essentially pinned
even though the proc number may be reused. Then the caller can just poll.
We can add a waitqueue to struct pid, and wake up any waiters on process
death (A quick look shows task_struct can be mapped to its struct pid) and
also possibly optimize it using Steve's TIF flag idea. No new syscall is
needed then, let me know if I missed something?

thanks,

 - Joel

