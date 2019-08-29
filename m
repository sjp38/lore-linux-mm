Return-Path: <SRS0=qe68=WZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8A449C3A5A6
	for <linux-mm@archiver.kernel.org>; Thu, 29 Aug 2019 15:20:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 380652339E
	for <linux-mm@archiver.kernel.org>; Thu, 29 Aug 2019 15:20:20 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=arista.com header.i=@arista.com header.b="ajKfR8Wm"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 380652339E
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=arista.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DA9AF6B0269; Thu, 29 Aug 2019 11:20:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D34536B026A; Thu, 29 Aug 2019 11:20:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C48416B026B; Thu, 29 Aug 2019 11:20:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0081.hostedemail.com [216.40.44.81])
	by kanga.kvack.org (Postfix) with ESMTP id A0AAF6B0269
	for <linux-mm@kvack.org>; Thu, 29 Aug 2019 11:20:19 -0400 (EDT)
Received: from smtpin28.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 2399A180AD7C1
	for <linux-mm@kvack.org>; Thu, 29 Aug 2019 15:20:19 +0000 (UTC)
X-FDA: 75875826558.28.van21_2b213cfe1e41
X-HE-Tag: van21_2b213cfe1e41
X-Filterd-Recvd-Size: 7269
Received: from mail-io1-f65.google.com (mail-io1-f65.google.com [209.85.166.65])
	by imf40.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 29 Aug 2019 15:20:18 +0000 (UTC)
Received: by mail-io1-f65.google.com with SMTP id q12so7697517iog.4
        for <linux-mm@kvack.org>; Thu, 29 Aug 2019 08:20:18 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=arista.com; s=googlenew;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=9iGYmCEiptvqIZxLPzxTrn9/HqDtZTsAATxoz/a+FeY=;
        b=ajKfR8WmQH2jAsoipDnkYbdg4QxYVjBRrwVKbgdkZvDqfmUZT4lxfBjj4IxSQInSAl
         rE0+ffA6yeCWxHunh0J/zSmLRmTiUqNIvh2e87x4KkaYwlI9W9qV5GTe4VfiPJ7YUWcW
         H0/D7ljhYVJLZP3bINjjneQAkjk6+sIhzcvHKbyCVbm2NBgCWpkCK3ELtOA5eE+60Egu
         xde0s9Ex71CBC/Rpw6ko8A4G8bxWxCKwtShOudlqRuVcVj6BQhulFc3uCeA97GXI5ppx
         snAZDYMGj6OJhvrxaYT9K7B7c3VpTp3FiPlYbXfDBsO36RfiHf8waO4/Zz2IlNdXU+db
         44ZA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=9iGYmCEiptvqIZxLPzxTrn9/HqDtZTsAATxoz/a+FeY=;
        b=JsoZTf6MeZqAFb4NBY+rHTAxkzXfgynLJyLaTJmB3gpAYSTDPe8uory7C/rMdDxJbZ
         Gt048IWYBEzalElS+ZjcI6nk2GwnIPYhp9AWzMETPGb235WWOCM4qx90/2+lUXR2/ZFj
         t7AkMYqSlYof8PPuJIyBUKjg8OeHy0+pMFQ6jBJtEi10q7NKR1A4Z0MMxIqdyLCFVXp0
         8me5qtUTeqh293HansKHx0f+DRmoyqsyJhbmGBy8MipAMBNvecvas3bGOji/D4h/EDo5
         ING9HaRG4nL5mxDUWIoU9WE013zxLp7P61Ok9GWB2njK2ckusz+hM+KSeaiO9T6d7whv
         Z00A==
X-Gm-Message-State: APjAAAU9ynmq2gLigBxZ8zwLwcjfEMHDJq+GymMIZVqyzZc6XfNo9PfU
	twt6rv6LgIQzlt6IjSCKLT9I6vjoAijpuJpH8tPFgQ==
X-Google-Smtp-Source: APXvYqy6YoShfCpFvhhWS2elsguTFduZWQbNVJA3a3MV47qQbaX5VoOHg78NDfCtnnFi1Skwu+2Z+9eFH2zKt0EaDLY=
X-Received: by 2002:a5d:8591:: with SMTP id f17mr1320810ioj.5.1567092017615;
 Thu, 29 Aug 2019 08:20:17 -0700 (PDT)
MIME-Version: 1.0
References: <20190826193638.6638-1-echron@arista.com> <20190827071523.GR7538@dhcp22.suse.cz>
 <CAM3twVRZfarAP6k=LLWH0jEJXu8C8WZKgMXCFKBZdRsTVVFrUQ@mail.gmail.com>
 <20190828065955.GB7386@dhcp22.suse.cz> <CAM3twVR_OLffQ1U-SgQOdHxuByLNL5sicfnObimpGpPQ1tJ0FQ@mail.gmail.com>
 <20190829071105.GQ28313@dhcp22.suse.cz>
In-Reply-To: <20190829071105.GQ28313@dhcp22.suse.cz>
From: Edward Chron <echron@arista.com>
Date: Thu, 29 Aug 2019 08:20:05 -0700
Message-ID: <CAM3twVQrgJUR7n2=Q5FY4zv-0fc8C9Mj3Cn0pxYFY7s3sMXUJw@mail.gmail.com>
Subject: Re: [PATCH 00/10] OOM Debug print selection and additional information
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Roman Gushchin <guro@fb.com>, 
	Johannes Weiner <hannes@cmpxchg.org>, David Rientjes <rientjes@google.com>, 
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Shakeel Butt <shakeelb@google.com>, 
	linux-mm@kvack.org, linux-kernel@vger.kernel.org, 
	Ivan Delalande <colona@arista.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Aug 29, 2019 at 12:11 AM Michal Hocko <mhocko@kernel.org> wrote:
>
> On Wed 28-08-19 12:46:20, Edward Chron wrote:
> [...]
> > Our belief is if you really think eBPF is the preferred mechanism
> > then move OOM reporting to an eBPF.
>
> I've said that all this additional information has to be dynamically
> extensible rather than a part of the core kernel. Whether eBPF is the
> suitable tool, I do not know. I haven't explored that. There are other
> ways to inject code to the kernel. systemtap/kprobes, kernel modules and
> probably others.

For simple code injections eBPF or kprobe works and a tracepoint would
help with that. For example we could add our one line of task information
that we find very useful this way.

For adding controls to limit output for processes, slabs and vmalloc entries
it would be harder to inject code for that. Our solution was to use debugfs.
An alternate could to be add simple sysctl if using debugfs is not appropriate.
As our code illustrated this can be added without changing the existing report
in any substantive way. I think there is value in this and this is core to what
the OOM report should provide. Additional items may be add ons that are
environment specific but these are OOM reporting essentials IMHO.

>
> > I mentioned this before but I will reiterate this here.
> >
> > So how do we get there? Let's look at the existing report which we know
> > has issues.
> >
> > Other than a few essential OOM messages the OOM code should produce,
> > such as the Killed process message message sequence being included,
> > you could have the entire OOM report moved to an eBPF script and
> > therefore make it customizable, configurable or if you prefer programmable.
>
> I believe we should keep the current reporting in place and allow
> additional information via dynamic mechanism. Be it a registration
> mechanism that modules can hook into or other more dynamic way.
> The current reporting has proven to be useful in many typical oom
> situations in my past years of experience. It gives the rough state of
> the failing allocation, MM subsystem, tasks that are eligible and task
> that is killed so that you can understand why the event happened.
>
> I would argue that the eligible tasks should be printed on the opt-in
> bases because this is more of relict from the past when the victim
> selection was less deterministic. But that is another story.
>
> All the rest of dump_header should stay IMHO as a reasonable default and
> bare minimum.
>
> > Why? Because as we all agree, you'll never have a perfect OOM Report.
> > So if you believe this, than if you will, put your money where your mouth
> > is (so to speak) and make the entire OOM Report and eBPF script.
> > We'd be willing to help with this.
> >
> > I'll give specific reasons why you want to do this.
> >
> >    - Don't want to maintain a lot of code in the kernel (eBPF code doesn't
> >    count).
> >    - Can't produce an ideal OOM report.
> >    - Don't like configuring things but favor programmatic solutions.
> >    - Agree the existing OOM report doesn't work for all environments.
> >    - Want to allow flexibility but can't support everything people might
> >    want.
> >    - Then installing an eBPF for OOM Reporting isn't an option, it's
> >    required.
>
> This is going into an extreme. We cannot serve all cases but that is
> true for any other heuristics/reporting in the kernel. We do care about
> most.

Unfortunately my argument for this is moot, this can't be done with
eBPF, at least not now.

>
> > The last reason is huge for people who live in a world with large data
> > centers. Data center managers are very conservative. They don't want to
> > deviate from standard operating procedure unless absolutely necessary.
> > If loading an OOM Report eBPF is standard to get OOM Reporting output,
> > then they'll accept that.
>
> I have already responded to this kind of argumentation elsewhere. This
> is not a relevant argument for any kernel implementation. This is a data
> process management process.
>
> --
> Michal Hocko
> SUSE Labs

