Return-Path: <SRS0=L2Uh=RS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 49DFDC4360F
	for <linux-mm@archiver.kernel.org>; Fri, 15 Mar 2019 13:36:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CA1FB21019
	for <linux-mm@archiver.kernel.org>; Fri, 15 Mar 2019 13:36:15 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=joelfernandes.org header.i=@joelfernandes.org header.b="DypriJsH"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CA1FB21019
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=joelfernandes.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2BC676B0281; Fri, 15 Mar 2019 09:36:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 269F46B0282; Fri, 15 Mar 2019 09:36:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 134926B0283; Fri, 15 Mar 2019 09:36:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id DCC266B0281
	for <linux-mm@kvack.org>; Fri, 15 Mar 2019 09:36:14 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id 43so8593599qtz.8
        for <linux-mm@kvack.org>; Fri, 15 Mar 2019 06:36:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=VKfVpaxZoxyBURh7QyO3ZULqx69a8OaThEQCt8FoTew=;
        b=rAC98oITMZeOxf7pAl+RFS8XOiZTUaJjjmoB/kQYGrP9kfqnKWPHWObd83eLqFzrxB
         r5JAXIx5XbRrxKf7/JlLAsAQPJZ8lNeCmSEBTb/3K5CZcAKQm+Thk9lVixEPiJ6xSud+
         6lGQ3Ls02G+5wq808RafLA7+hVNmoH8Qq4HDfqw2mYn+uQlJilFz6EBHMhdhEHjzK4V5
         Tbh7g+hBDAhRWRAQr8ZIXd+sqNLWpou2k+2N0ETFCtF2I5fOicqEFew4on0OP350Mk7D
         6yI2zxrZghm0LN+cDM6sZGB8AgPUPR98gNlnoRdqqTEfsS0I9dRkZ0RCf2uWKjQeUfWP
         +JAQ==
X-Gm-Message-State: APjAAAX7+lrwkmeUtclXjuGlxDHoWgjTEmSmQ2N3CUpD1vgLK7NA3nfh
	mUEeEuZECyABfDuFxAIh1wBY1qCc6nCElWeFcAjn3foFUH1qNvtfQWntoNgxCfsgjlx9iIc+/sE
	shTkWXMDvqfJbXr4zlCAYLSwc8NPei0ZAmjRbayVMtkQQKPlWrCR1UW/19xbndT/8nQ==
X-Received: by 2002:a0c:f604:: with SMTP id r4mr2535962qvm.55.1552656974316;
        Fri, 15 Mar 2019 06:36:14 -0700 (PDT)
X-Received: by 2002:a0c:f604:: with SMTP id r4mr2535873qvm.55.1552656972933;
        Fri, 15 Mar 2019 06:36:12 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552656972; cv=none;
        d=google.com; s=arc-20160816;
        b=n1/DwecbeLmZvqFQpAfNtBhgrR+mdZYX12bLGS7ja4Ccyus4T5iSpR7jXUzuO0HRZr
         A5XyTXKe3fNkaTyRvbEbHv7EHkyTXsAzLJBoLt8ePVRMAaWW98qjo8zddjJPrsnY0a9t
         xuU4MqQqIXx3bzwqh52Bb3cN60VftvclhWR51Nr2ve5Qs/O3H5TQjn5BPJ5DBlbkjEja
         Xdr9PVdrp7KCvWWbA9eoHwXGQ0TpmZ7BlCQM7ZospY/ah/R77jsthnNjKLvpeJKjrjpM
         9Gzli6p6vWX3/a1XiVTAXKT4/OWOZpVYd9GhfatkGY1dzz1qWR4T+ZwRjKuiCfQ7GtyS
         oHQg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=VKfVpaxZoxyBURh7QyO3ZULqx69a8OaThEQCt8FoTew=;
        b=00ddRGGNMMtG6wE4mwNGFoVO1eDGhirdmnMlWjRa+0nipXSO5HDq/TC9SlqK7I2Ea6
         0n+PyJ7T4bTNV2E+/KxxjTd6dqBJRE4hid5tDHZ9GqFsxaQLgzjpLGZHDzWroSOACa57
         yZv5Szq5kEtix2x/xAg5WZvNvJ/HWMlHvwO6bnyR3RjoJEmDxylUYdQ4jHU9MbR/IChO
         Y+UuPtWVh/r6fXjW3wcUrl2RPJA4MvGCrpAVM4iAgDaP3vwIxHmY77oBPrf1L2ITWe/0
         gDYqwD323FiFhbWTi9NZo3c1i9wa4h1ivU10G2o4PWoOKI73C4ctef+6COOGTbZPH3iE
         Bbhw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@joelfernandes.org header.s=google header.b=DypriJsH;
       spf=pass (google.com: domain of joel@joelfernandes.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=joel@joelfernandes.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l8sor2104703qve.69.2019.03.15.06.36.12
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 15 Mar 2019 06:36:12 -0700 (PDT)
Received-SPF: pass (google.com: domain of joel@joelfernandes.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@joelfernandes.org header.s=google header.b=DypriJsH;
       spf=pass (google.com: domain of joel@joelfernandes.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=joel@joelfernandes.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=joelfernandes.org; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=VKfVpaxZoxyBURh7QyO3ZULqx69a8OaThEQCt8FoTew=;
        b=DypriJsHzRFZ8FHMG3w+iXrHK4g88dJrwe9SlU6tuDtj36SzuZ8nyphK4opqxcD2rC
         iXyUj2WTVz6Sg5zw3n6zHK2edM7QYZygthWj5HMZuuylhy4TGmwP62F4wIa8AVE8np70
         CJFmX1ZOs7jXHhVBGCEG2BTyDzdL+xy1R3gOU=
X-Google-Smtp-Source: APXvYqwDKGSWS1TnWrym7jTm0Yjc6txyLmC1XATdlVnftbixDMdIVIiWhjfELCUcRhoCb9+SznndkQ==
X-Received: by 2002:a0c:be8f:: with SMTP id n15mr2508855qvi.203.1552656972351;
        Fri, 15 Mar 2019 06:36:12 -0700 (PDT)
Received: from localhost ([2620:0:1004:1100:cca9:fccc:8667:9bdc])
        by smtp.gmail.com with ESMTPSA id c12sm1119065qkb.86.2019.03.15.06.36.11
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 15 Mar 2019 06:36:11 -0700 (PDT)
Date: Fri, 15 Mar 2019 09:36:10 -0400
From: Joel Fernandes <joel@joelfernandes.org>
To: Daniel Colascione <dancol@google.com>
Cc: Steven Rostedt <rostedt@goodmis.org>,
	Sultan Alsawaf <sultan@kerneltoast.com>,
	Tim Murray <timmurray@google.com>, Michal Hocko <mhocko@kernel.org>,
	Suren Baghdasaryan <surenb@google.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Arve =?iso-8859-1?B?SGr4bm5lduVn?= <arve@android.com>,
	Todd Kjos <tkjos@android.com>, Martijn Coenen <maco@android.com>,
	Christian Brauner <christian@brauner.io>,
	Ingo Molnar <mingo@redhat.com>,
	Peter Zijlstra <peterz@infradead.org>,
	LKML <linux-kernel@vger.kernel.org>,
	"open list:ANDROID DRIVERS" <devel@driverdev.osuosl.org>,
	linux-mm <linux-mm@kvack.org>,
	kernel-team <kernel-team@android.com>
Subject: Re: [RFC] simple_lmk: Introduce Simple Low Memory Killer for Android
Message-ID: <20190315133610.GC3378@google.com>
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
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAKOZuetZHJzmQy3n001x4+rmWoWHEgUv2Zvow9W5+xvukxp1JQ@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Mar 14, 2019 at 09:36:43PM -0700, Daniel Colascione wrote:
[snip] 
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

The eBPF-based solution to this would be just as simple while avoiding any
kernel changes. I don't know why you think it is not load-bearing. However, I
agree the proc/pidfd approach is better and can be simpler for some users who
don't want to deal with eBPF - especially since something like this has many
usecases. I was just suggesting the eBPF solution as a better alternative to
the task_struct surgery idea from Sultan since that sounded to me quite
hackish (that could just be my opinion).

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
> 
> We definitely don't want to have to wait for a process's parent to
> reap it. Instead, we want to wait for it to become a zombie. That's
> why I designed my original exithand patch to fire death notification
> upon transition to the zombie state, not upon process table removal,
> and I expect pidfd_wait (or whatever we call it) to act the same way.

Agreed. Looking forward to the patches. :)

thanks,

 - Joel

