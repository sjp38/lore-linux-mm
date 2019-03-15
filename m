Return-Path: <SRS0=L2Uh=RS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,URIBL_BLOCKED,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 799CCC43381
	for <linux-mm@archiver.kernel.org>; Fri, 15 Mar 2019 16:12:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1A2C321871
	for <linux-mm@archiver.kernel.org>; Fri, 15 Mar 2019 16:12:41 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="da9yz2JE"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1A2C321871
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9BEFC6B028E; Fri, 15 Mar 2019 12:12:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 96E746B0290; Fri, 15 Mar 2019 12:12:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 85E5B6B0291; Fri, 15 Mar 2019 12:12:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f197.google.com (mail-vk1-f197.google.com [209.85.221.197])
	by kanga.kvack.org (Postfix) with ESMTP id 510ED6B028E
	for <linux-mm@kvack.org>; Fri, 15 Mar 2019 12:12:41 -0400 (EDT)
Received: by mail-vk1-f197.google.com with SMTP id 5so3581030vkg.20
        for <linux-mm@kvack.org>; Fri, 15 Mar 2019 09:12:41 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=G98PYh2DSRIXfDiz2B8YEDtdGPjk4D3XkkejmaTBmq4=;
        b=c/2z6G9QqhNbYGGKeA7/rAMElF8iCPJXpB4Bv8NAY+atxAdAUulD4oaQggyGthebht
         q2c0y2Wmqm3f69qOoRIZOmkBHqhaJG4vCFeMqWwctHattyBi+GuJDXVinyt6Mf89WBiJ
         Tuyru2tkH2rPTLOuosdsbFWn3zw4vDY8DDcK3CPgYN2qdgEgdHGwLHZviV1G6boE0foI
         rGy5Yx53cNLie+TworjbP2TpXp4JlLeA8Syxk8BRDlKAZ9MGOUpxJ5JiNNL7Tc40eLHT
         Fj7wFXO4nbV4LUSRuXnQ4LJeYav5TyJ8TJ4yxZBhtzW+6jp1gSimQCb+1xjXtxJT7orM
         3fTw==
X-Gm-Message-State: APjAAAX5Uf+yMqQ4Ixe8gZ1AQDCA7xFoi/eN7B/SjvNfWMK1XpdUZkD6
	hQHJz8lkjU+xiEBozW0y+cINlnuLoSBEk+WN6nJicD89sPvLgfc2vfrZLVTH9Bsc5TUYftEJTgm
	yt1Ey15ZD1SgoeCwEcm4j8n1TMtdbl9yyU5+p7R7+RXCKcoNBMtcY8L3p0gaPIOMotQ==
X-Received: by 2002:a67:fe45:: with SMTP id m5mr2388765vsr.229.1552666360993;
        Fri, 15 Mar 2019 09:12:40 -0700 (PDT)
X-Received: by 2002:a67:fe45:: with SMTP id m5mr2388710vsr.229.1552666359882;
        Fri, 15 Mar 2019 09:12:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552666359; cv=none;
        d=google.com; s=arc-20160816;
        b=D3HDi/lF6ooeC8RTDR7tflsxwvoqWMCDfR+iNX+8a2BCgL59LfJsyGtHZtG/t42i8B
         PtAyjxXk9JPaO8QGVLGfalAhBuELI1mSSZBme4OlSqXz6d8GNkIj0HMDSSKziv1Thb9P
         AocjEsS7IswVApiih2RJ8BJUT6klm4L+bUEVkBFy9oB5yvIPM82c59ee+fshWTm5apit
         gjoE2nXhVY/atTfj4DeNWfcwpLyPMIljQNJ77+WJht4cHx+vAdnXsCJNgHRUk0WhmwNO
         JPIG0fwhKJf4tGaxvJkpz/UJQZMY4zwvUvJcDlZplpaqiL06mG5KFjcpuVs3mTgx+sHA
         7NaA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=G98PYh2DSRIXfDiz2B8YEDtdGPjk4D3XkkejmaTBmq4=;
        b=kmxQZac/FyQFSL2fjcsKFwJL8KEDkC+KnJ4cUA3n1JYhJXTe8v5X1pQwiQWDZvhjHX
         1pRLOPkbdfj6T2JxSFU8d392yZHdl8087LwFu/bFzZk7LhQtW6xszAVI+/sY31P/E5iX
         rvAn60jkwgmobLcC6ob7j+B2JDkap6FyF4PGYLZ4jeFK9OTXyFWUc0hZ/48NE14/FynO
         NjIwW3rprKZAj6UjxcTpCLoc+OgFtv/qVU1FZfxNihq7//2QhI70r8vkFAGVBkupfP6k
         uSS2IjUeez+2MNgdWaFyGXfMwob9KBqF9jgXj2piMqXpPwSh1Ng3Wij6I4FjrHgn8dzN
         /dCw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=da9yz2JE;
       spf=pass (google.com: domain of dancol@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dancol@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y14sor1541885vsn.13.2019.03.15.09.12.39
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 15 Mar 2019 09:12:39 -0700 (PDT)
Received-SPF: pass (google.com: domain of dancol@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=da9yz2JE;
       spf=pass (google.com: domain of dancol@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dancol@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=G98PYh2DSRIXfDiz2B8YEDtdGPjk4D3XkkejmaTBmq4=;
        b=da9yz2JEOWD047fJ5Bb9+unPczli1634zxjR75AhtA2Icpb35PChSfAhhzBVlXjHBi
         Rh3swkylF2TNU4Yjyh8tSNdvg7FmgAW5/2bRGtusGjpHevseK5PeSLEDGYye5BIzBP8e
         9DJaZXd995bBDxtwYgpVsPZzrDJcpAM4oTlfW0sArSRJOCBAmZMO48UEsYmMJWH0c79V
         FccNiVvhSVFk3jp3SHfT/PWSR53fOuOsEnS+YhVolkeR6vFIQpal6I/rswGyWtms4yfx
         nkJfnP35q/5LyU9iIkvw59O69LQdNYJbW4lWp00xBBe4B+Uxjby+E0RrTs/sDK8jorIQ
         0cnQ==
X-Google-Smtp-Source: APXvYqy7Q6EypbCUqsdi37CmUirfHoauKh+3HjiwM47K3gidDG9pLQ6/1v354cQuGsiIVCmiwIi3hA1+K93DKW4+R0k=
X-Received: by 2002:a67:fa8c:: with SMTP id f12mr1600062vsq.171.1552666358905;
 Fri, 15 Mar 2019 09:12:38 -0700 (PDT)
MIME-Version: 1.0
References: <20190310203403.27915-1-sultan@kerneltoast.com>
 <20190311174320.GC5721@dhcp22.suse.cz> <20190311175800.GA5522@sultan-box.localdomain>
 <CAJuCfpHTjXejo+u--3MLZZj7kWQVbptyya4yp1GLE3hB=BBX7w@mail.gmail.com>
 <20190311204626.GA3119@sultan-box.localdomain> <CAJuCfpGpBxofTT-ANEEY+dFCSdwkQswox3s8Uk9Eq0BnK9i0iA@mail.gmail.com>
 <20190312080532.GE5721@dhcp22.suse.cz> <20190312163741.GA2762@sultan-box.localdomain>
 <CAEe=Sxn_uayj48wo7oqf8mNZ7QAGJUQVmkPcHcuEGjA_Z8ELeQ@mail.gmail.com>
 <CAEXW_YQMnbN+e-janGbZc5MH6MwdUdXNfonpLUu5O2nsSkJyeg@mail.gmail.com>
 <20190314204911.GA875@sultan-box.localdomain> <20190314231641.5a37932b@oasis.local.home>
 <CAKOZuetZHJzmQy3n001x4+rmWoWHEgUv2Zvow9W5+xvukxp1JQ@mail.gmail.com> <CAJuCfpFXhE0LwLf-KEuN8W5zqHh_nLzgv7DGjrePiSr6xkvSKA@mail.gmail.com>
In-Reply-To: <CAJuCfpFXhE0LwLf-KEuN8W5zqHh_nLzgv7DGjrePiSr6xkvSKA@mail.gmail.com>
From: Daniel Colascione <dancol@google.com>
Date: Fri, 15 Mar 2019 09:12:27 -0700
Message-ID: <CAKOZueunOjQ_=8K5KHb-wr_9BAXmZo1=0nESKrBikEY0Cjx=yQ@mail.gmail.com>
Subject: Re: [RFC] simple_lmk: Introduce Simple Low Memory Killer for Android
To: Suren Baghdasaryan <surenb@google.com>
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

On Fri, Mar 15, 2019 at 8:56 AM Suren Baghdasaryan <surenb@google.com> wrote:
>
> On Thu, Mar 14, 2019 at 9:37 PM Daniel Colascione <dancol@google.com> wrote:
> >
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
> > imagine a general-purpose priority inheritance mechanism expediting
> > process death when a high-priority process waits on a pidfd_wait
> > handle for a condemned process. You know you're on the right track
> > design-wise when you start seeing this kind of elegant constructive
> > interference between seemingly-unrelated features. What we don't need
> > is some kind of blocking SIGKILL alternative or backdoor event
> > delivery system.
>
> When talking about pidfd_wait functionality do you mean something like
> this: https://lore.kernel.org/patchwork/patch/345098/ ? I missed the
> discussion about it, could you please point me to it?

That directory-polling approach came up in the discussion. It's a bad
idea, mostly for API reasons. I'm talking about something more like
https://lore.kernel.org/lkml/20181029175322.189042-1-dancol@google.com/,
albeit in system call form instead of in the form of a new per-task
proc file.

