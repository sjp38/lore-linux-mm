Return-Path: <SRS0=h9qD=RX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-13.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A15F5C43381
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 19:41:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5995021873
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 19:41:00 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="OA+7LFBa"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5995021873
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C544C6B0003; Wed, 20 Mar 2019 15:40:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C05166B0006; Wed, 20 Mar 2019 15:40:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AF4476B0007; Wed, 20 Mar 2019 15:40:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ua1-f72.google.com (mail-ua1-f72.google.com [209.85.222.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8C6316B0003
	for <linux-mm@kvack.org>; Wed, 20 Mar 2019 15:40:59 -0400 (EDT)
Received: by mail-ua1-f72.google.com with SMTP id m3so303728uao.22
        for <linux-mm@kvack.org>; Wed, 20 Mar 2019 12:40:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=SvArG4neodJjg81/l1ml2GxK3X5tveRM+mJKV/2MOkc=;
        b=Z5DU2hpDtJGKbosHuID2nZCAsqFEywO381lyjN18+e2469a6asrvZ2K6Ct5hiA9grO
         cfUMvyroZL+O+KlCkKp5xea3PxzCfHGSi+P3aqkB7jw1jzWiew7RgJ2n89+4ZJOs+MLd
         yDH1k3NS+SBZxw0tbEl7Fp8Y1qjBRj1pS90QaeL9xUcikoeoaXsdVCCLnUyrVINVq37I
         TkP/5d5MqRW7l7/Jutj2uz+4ZH7ZYNmNFVv1TebFqpmclevebqgKahU2cxQkqw2G7jOt
         b1TaDtFqULJjefZsof+FFcqkTGa5tUber0BQ1wG5QWzP6VIKtECZLQsHQdKrv/kZiWt0
         OG+w==
X-Gm-Message-State: APjAAAV4R+kYW5lJjDJRP2WD6F8/gxAxahaKFZ93DfBrgsSX5QsOimvg
	q5jDm2ZkPBeCvH9LghgXlfzHVclSvYTytBCmFR8Fh/DGXS22ziljlvZ0EOESkBMzlFjFaZBPXLz
	p/QJWshLLoadsBmIDUBedb5NW6y+7ldfZw1aEV5mZFM770RRpuTc8qmeuKJtUalGFog==
X-Received: by 2002:ab0:2b16:: with SMTP id e22mr5299762uar.113.1553110859213;
        Wed, 20 Mar 2019 12:40:59 -0700 (PDT)
X-Received: by 2002:ab0:2b16:: with SMTP id e22mr5299725uar.113.1553110858436;
        Wed, 20 Mar 2019 12:40:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553110858; cv=none;
        d=google.com; s=arc-20160816;
        b=LbQmmI5QZsI/coBj4zDi+cZvU8xZA/K1wpaGj4evMTrR65eA068OqWLlsgYUZF+rOg
         Y22ByxqCXFjFRhF6Sf+a+TftHCn0FHLPau+7RQa4C2e8f/22IJH8UsK7OaHw/cohcQPT
         CHCFOb5VTMfremUzOzuj3fr3yDq5zDTTk7awFPV8kKtihhD+sW8gvN15rjvgRqZjyooT
         Y4Nd53uWUSHXVzS6AVPPy0ZSNOWQ6RbkUYa3dcNOVAY9Snd7OaXUyIMmjLq5YmtQBuYT
         pjQdDZSzpgxefADnBUHIRsGZ+l3nA/HgonMvQCIXKLVtTQIQftRiegUrJxuVes5jk2DF
         1x4Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=SvArG4neodJjg81/l1ml2GxK3X5tveRM+mJKV/2MOkc=;
        b=EWVm68XwklqX0epoknEV/o7tOURr+vRglI2juQGG6rBE9+r9xODYFYFpklpxjbTPao
         y+rpuRqncFqsGd28i1vUUAzF2XuazMUpsCB9I+wkYvypA06AqTcx25pK9NuvWJD0oVwY
         Mph8u9QFVPWOt29OQkoI0u78AKJNmNRBzBWs+STJnk2TB3R4n58pdfvdru7EZ0TaVAnO
         zzbsUKCF6sYVPKstuCPY3batWk6dkzU+vVMnw3YXxdg584VClhiVgFHA3JR3cg1ZiqVF
         OvrCDwrQ9Lpd/tMS2ZQVtRxGZrw6yIJFMkpOvoGag+o9fnOC8Q9NRja58eJzgAug68ns
         sBWA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=OA+7LFBa;
       spf=pass (google.com: domain of dancol@google.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=dancol@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id v72sor1655816vkv.54.2019.03.20.12.40.58
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 20 Mar 2019 12:40:58 -0700 (PDT)
Received-SPF: pass (google.com: domain of dancol@google.com designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=OA+7LFBa;
       spf=pass (google.com: domain of dancol@google.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=dancol@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=SvArG4neodJjg81/l1ml2GxK3X5tveRM+mJKV/2MOkc=;
        b=OA+7LFBabangtz/p7+isIh2AehX9or2nW+UiM+LmdDlGICer9Hr1pT/Zb2fX8f3yMo
         Quw+a/ByrKDYjBc3YXralGnDlUQtfNB3wN7yg6F3ic3z6H3YGtA7R8K0chdALunMX9Qe
         UIJDpnYnbayASP16vApGjx5myPEIQ4is88+Xz/plHQ+eHIEbSsl/KbFDuL4WSq9RpzFy
         FF/8m0BmrpWsKv062B1wnLIgrP5QZZhOWK+wFYM9lQJTSIAMfHm7aLSdNtyQT7mo9hXW
         G3qrzq2ZPU6pWNiZ7h/DXjc/toE6jVACJlnlKa8+x+85gT7CQIHeOQTzbMX/isOSzhla
         KkCw==
X-Google-Smtp-Source: APXvYqwQ/dXvHEzlTvHvnz0gIwhtnnrUl00BFG1RsZB1vcXIy6qMCGsim0ImV8HN8YylcuX03YXGxlwWccPGAKlG94o=
X-Received: by 2002:a1f:82ce:: with SMTP id e197mr5989535vkd.89.1553110857728;
 Wed, 20 Mar 2019 12:40:57 -0700 (PDT)
MIME-Version: 1.0
References: <20190319231020.tdcttojlbmx57gke@brauner.io> <20190320015249.GC129907@google.com>
 <CAKOZuetJzg_EiyuK7Pa13X3LKuBbreg7zJ5g4uQv_uV4wpmZjg@mail.gmail.com>
 <20190320035953.mnhax3vd47ya4zzm@brauner.io> <CAKOZuet3-VhmC3oHtEbPPvdiar_k_QXTf0TkgmH9LiwmW-_oNA@mail.gmail.com>
 <4A06C5BB-9171-4E70-BE31-9574B4083A9F@joelfernandes.org> <20190320182649.spryp5uaeiaxijum@brauner.io>
 <CAKOZuevHbQtrq+Nb-jw1L7O72BmAzcXmbUnfnseeXZjX4PE4tg@mail.gmail.com>
 <20190320185156.7bq775vvtsxqlzfn@brauner.io> <CALCETrXO=V=+qEdLDVPf8eCgLZiB9bOTrUfe0V-U-tUZoeoRDA@mail.gmail.com>
 <20190320191412.5ykyast3rgotz3nu@brauner.io>
In-Reply-To: <20190320191412.5ykyast3rgotz3nu@brauner.io>
From: Daniel Colascione <dancol@google.com>
Date: Wed, 20 Mar 2019 12:40:46 -0700
Message-ID: <CAKOZuesRwQ4=Svu1KgHWY=HZSS8mF8uFmuzuVOSH0QpJoy7a5w@mail.gmail.com>
Subject: Re: pidfd design
To: Christian Brauner <christian@brauner.io>
Cc: Andy Lutomirski <luto@kernel.org>, Joel Fernandes <joel@joelfernandes.org>, 
	Suren Baghdasaryan <surenb@google.com>, Steven Rostedt <rostedt@goodmis.org>, 
	Sultan Alsawaf <sultan@kerneltoast.com>, Tim Murray <timmurray@google.com>, 
	Michal Hocko <mhocko@kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, 
	=?UTF-8?B?QXJ2ZSBIasO4bm5ldsOlZw==?= <arve@android.com>, 
	Todd Kjos <tkjos@android.com>, Martijn Coenen <maco@android.com>, Ingo Molnar <mingo@redhat.com>, 
	Peter Zijlstra <peterz@infradead.org>, LKML <linux-kernel@vger.kernel.org>, 
	"open list:ANDROID DRIVERS" <devel@driverdev.osuosl.org>, linux-mm <linux-mm@kvack.org>, 
	kernel-team <kernel-team@android.com>, Oleg Nesterov <oleg@redhat.com>, 
	"Serge E. Hallyn" <serge@hallyn.com>, Kees Cook <keescook@chromium.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 20, 2019 at 12:14 PM Christian Brauner <christian@brauner.io> wrote:
>
> On Wed, Mar 20, 2019 at 11:58:57AM -0700, Andy Lutomirski wrote:
> > On Wed, Mar 20, 2019 at 11:52 AM Christian Brauner <christian@brauner.io> wrote:
> > >
> > > You're misunderstanding. Again, I said in my previous mails it should
> > > accept pidfds optionally as arguments, yes. But I don't want it to
> > > return the status fds that you previously wanted pidfd_wait() to return.
> > > I really want to see Joel's pidfd_wait() patchset and have more people
> > > review the actual code.
> >
> > Just to make sure that no one is forgetting a material security consideration:
>
> Andy, thanks for commenting!
>
> >
> > $ ls /proc/self
> > attr             exe        mountinfo      projid_map    status
> > autogroup        fd         mounts         root          syscall
> > auxv             fdinfo     mountstats     sched         task
> > cgroup           gid_map    net            schedstat     timers
> > clear_refs       io         ns             sessionid     timerslack_ns
> > cmdline          latency    numa_maps      setgroups     uid_map
> > comm             limits     oom_adj        smaps         wchan
> > coredump_filter  loginuid   oom_score      smaps_rollup
> > cpuset           map_files  oom_score_adj  stack
> > cwd              maps       pagemap        stat
> > environ          mem        personality    statm
> >
> > A bunch of this stuff makes sense to make accessible through a syscall
> > interface that we expect to be used even in sandboxes.  But a bunch of
> > it does not.  For example, *_map, mounts, mountstats, and net are all
> > namespace-wide things that certain policies expect to be unavailable.
> > stack, for example, is a potential attack surface.  Etc.

If you can access these files sources via open(2) on /proc/<pid>, you
should be able to access them via a pidfd. If you can't, you
shouldn't. Which /proc? The one you'd get by mounting procfs. I don't
see how pidfd makes any material changes to anyone's security. As far
as I'm concerned, if a sandbox can't mount /proc at all, it's just a
broken and unsupported configuration.

An actual threat model and real thought paid to access capabilities
would help. Almost everything around the interaction of Linux kernel
namespaces and security feels like a jumble of ad-hoc patches added as
afterthoughts in response to random objections.

>> All these new APIs either need to
> > return something more restrictive than a proc dirfd or they need to
> > follow the same rules.

What's wrong with the latter?

> > And I'm afraid that the latter may be a
> > nonstarter if you expect these APIs to be used in libraries.

What's special about libraries? How is a library any worse-off using
openat(2) on a pidfd than it would be just opening the file called
"/proc/$apid"?

> > Yes, this is unfortunate, but it is indeed the current situation.  I
> > suppose that we could return magic restricted dirfds, or we could
> > return things that aren't dirfds and all and have some API that gives
> > you the dirfd associated with a procfd but only if you can see
> > /proc/PID.
>
> What would be your opinion to having a
> /proc/<pid>/handle
> file instead of having a dirfd. Essentially, what I initially proposed
> at LPC. The change on what we currently have in master would be:
> https://gist.github.com/brauner/59eec91550c5624c9999eaebd95a70df

And how do you propose, given one of these handle objects, getting a
process's current priority, or its current oom score, or its list of
memory maps? As I mentioned in my original email, and which nobody has
addressed, if you don't use a dirfd as your process handle or you
don't provide an easy way to get one of these proc directory FDs, you
need to duplicate a lot of metadata access interfaces.

