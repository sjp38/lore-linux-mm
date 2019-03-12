Return-Path: <SRS0=zC2G=RP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 59310C43381
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 17:17:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F3617217D4
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 17:17:57 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="S/lWy1OY"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F3617217D4
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 93C7C8E0003; Tue, 12 Mar 2019 13:17:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 89AFE8E0002; Tue, 12 Mar 2019 13:17:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 764528E0003; Tue, 12 Mar 2019 13:17:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f69.google.com (mail-io1-f69.google.com [209.85.166.69])
	by kanga.kvack.org (Postfix) with ESMTP id 50B828E0002
	for <linux-mm@kvack.org>; Tue, 12 Mar 2019 13:17:57 -0400 (EDT)
Received: by mail-io1-f69.google.com with SMTP id y13so2320067iol.1
        for <linux-mm@kvack.org>; Tue, 12 Mar 2019 10:17:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=2NlXEi3emhG/WYSsl8nOZrJjFK+P8wjzHIuDi4pDMGw=;
        b=m0H1RJ8E9Hznfirj3K7CfD9RRFs4VZMMJgK8Iw4Gb4BV1eFKOF1r9iexuae3Z4pGlE
         D45TwQiaj5Rv4bKPX4q1Q74KXJva8IEtUjBcpqpNOfIJbJhJJuqdMqp+CNmXzsaJ0PB1
         5zDuDNII7B1K5CJZBpBWGzsEEE/b8NmZNKECQfuGRxORcL45GQGpg/jgPnjQ/E+g85WG
         0Ppi2uMVn5yZ8B31yFr1W/Rst1gUsYTQU6uphywcIhDwNdz3N1MdE4fJtYh9XY4m+4wF
         C/aF0RTW3cJlgmdJKF48Eq+b4h2chFJ8InerR490FE5g3WZbrZPQmy+kBab6+I9EbpN3
         KC6g==
X-Gm-Message-State: APjAAAVW1vpfxqiPBs9Kf0f/w4NQiygMDf+ZCd/BlQpYFScY47UVZD92
	t6iWL6+jzLgg7fM3nGg/ZMy6zcvVbCt4ZgwNv/sETHyCLe3NUT/k/nA6HfQ+pH++Aqn6b820dNd
	B/T+uEaNrMlZlJhTI5Ed1t+m0Ls5yABj0W/AQcmKADTyS2tsrmQ0U5F0c+WYeBrEGbkzwo59V4y
	hl4Ht4QOLdOgvoHST5hirMkDMnBeEagrlRIoF+UBsyKDxM/Lwc98znSe4AAgelIeDAuXR/4/iDP
	Mq359eZyRuKOOIVM+P+KCD8fD+rtrmH0XVRr1TZYwRp4ZOAKpuqdyDzdUzmdfBzw864VQ8l5CeU
	0VL+sPqMbKSwaCtwQC6y5qPm3Zw0svkqTOUVB66eJgs/V5UyOEzk5IZbcoGwUEVj9UPSnJKPQrW
	y
X-Received: by 2002:a02:1c49:: with SMTP id c70mr3531283jac.92.1552411076691;
        Tue, 12 Mar 2019 10:17:56 -0700 (PDT)
X-Received: by 2002:a02:1c49:: with SMTP id c70mr3531227jac.92.1552411075434;
        Tue, 12 Mar 2019 10:17:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552411075; cv=none;
        d=google.com; s=arc-20160816;
        b=AmvKRBqKpwgHxXcb71MMszgrypkFzjdLpq3HygYSUCn1Esz6WQO3X3Wp+3BwvZVfWV
         6wQRopytwifz9XnXFsmOMYEsZzY8iuGAx0FKH59sCCKPLzouzb7Lysd/XhOgESxFtx2J
         cpO1jToNVCilhTjgwmeMc634EZ3emTrqApVaxlq2kkCqDiMVSX54HMVyxXMA0N3eWdnu
         N7mXR21XXymEntotcWR+p0Vb7YKu/jhGgX0xo2lMjdvcb1w+ZHdl1+XBSwtcOo0puJiQ
         C7p4PKQwfEXHkBtgUrkNnsTbyvCh9cmX0g+xu4ZySm1meH3QIiFM3oggSsrxMKsHS+go
         GXrw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=2NlXEi3emhG/WYSsl8nOZrJjFK+P8wjzHIuDi4pDMGw=;
        b=Cd+Jt+mi8ZyEGNTIK+dIHfjOQqTo5t+XVJwwFRXicLB6S2QZZXrMQE5oW+6jJ6Gw9J
         ha+qtLrcesfrY5Sp7HsCao6sgl7b11YOLNtPrVkMI/zQojxtedP+hX8GW2NegytG63sY
         mltWgI6Tu0/zKwmoMvdioVmfKMN4cWRCHc9S/Drj4e+jB4sCwns4jM/85M+XLECnV7rq
         tbvXplXvpJxFiGWXc641Mil2PLX2l8V4azmIQX2R/sTUkV7VeF5cfeTEinKd+4x11OV6
         wmr9HtTFgfevYzF4jGCDk8IE7qmI5F/r8jbNfM78eO6FEtwfq7D13753++dwjam414fd
         Bpsw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="S/lWy1OY";
       spf=pass (google.com: domain of timmurray@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=timmurray@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q135sor4881417itb.16.2019.03.12.10.17.55
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 12 Mar 2019 10:17:55 -0700 (PDT)
Received-SPF: pass (google.com: domain of timmurray@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="S/lWy1OY";
       spf=pass (google.com: domain of timmurray@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=timmurray@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=2NlXEi3emhG/WYSsl8nOZrJjFK+P8wjzHIuDi4pDMGw=;
        b=S/lWy1OYNMcZAszvY/+S7u7iFYwB2tvImYNHp+h2BZ1K/Qpw9siYUo1kfqyOtBr11n
         7uI5B0cXPo9fJM7fc0psjlMxFUFi8RcfZ8Qug4Ztk0U72111mMpX7GGa3vAXDs50wj2F
         7ocGYkrxrH2/yvN9k0oRg8t4WNvS2cdseKRn6WjnEHA1FxvsxMfnqVBzopnTOJ5GjVkh
         +bk2LxlWFMW7/obEuady1Ys9ctDnwQ2tzfZhHl5n2ukImhNSycJ4NAFqpVeLxbTFq5bt
         bB3YmQqQx0lcG0pRG3V4LGfBPhyisqifZ7xft7jCv5i1kKLv9kwhnCa8h1enJfI3JYjG
         Vj5g==
X-Google-Smtp-Source: APXvYqxOaQUOdbWABKdxQHmSBWB0t1gYlMOlKqK+MvAw6URM2JbAF8wERAX49ZZEu7Qx0kyT3DYE7kryqetUW6U5jxM=
X-Received: by 2002:a24:3a8b:: with SMTP id m133mr2651650itm.26.1552411074982;
 Tue, 12 Mar 2019 10:17:54 -0700 (PDT)
MIME-Version: 1.0
References: <20190310203403.27915-1-sultan@kerneltoast.com>
 <20190311174320.GC5721@dhcp22.suse.cz> <20190311175800.GA5522@sultan-box.localdomain>
 <CAJuCfpHTjXejo+u--3MLZZj7kWQVbptyya4yp1GLE3hB=BBX7w@mail.gmail.com>
 <20190311204626.GA3119@sultan-box.localdomain> <CAJuCfpGpBxofTT-ANEEY+dFCSdwkQswox3s8Uk9Eq0BnK9i0iA@mail.gmail.com>
 <20190312080532.GE5721@dhcp22.suse.cz> <20190312163741.GA2762@sultan-box.localdomain>
In-Reply-To: <20190312163741.GA2762@sultan-box.localdomain>
From: Tim Murray <timmurray@google.com>
Date: Tue, 12 Mar 2019 10:17:43 -0700
Message-ID: <CAEe=Sxn_uayj48wo7oqf8mNZ7QAGJUQVmkPcHcuEGjA_Z8ELeQ@mail.gmail.com>
Subject: Re: [RFC] simple_lmk: Introduce Simple Low Memory Killer for Android
To: Sultan Alsawaf <sultan@kerneltoast.com>
Cc: Michal Hocko <mhocko@kernel.org>, Suren Baghdasaryan <surenb@google.com>, 
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>, =?UTF-8?B?QXJ2ZSBIasO4bm5ldsOlZw==?= <arve@android.com>, 
	Todd Kjos <tkjos@android.com>, Martijn Coenen <maco@android.com>, 
	Joel Fernandes <joel@joelfernandes.org>, Christian Brauner <christian@brauner.io>, 
	Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, 
	LKML <linux-kernel@vger.kernel.org>, devel@driverdev.osuosl.org, 
	linux-mm <linux-mm@kvack.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 12, 2019 at 9:37 AM Sultan Alsawaf <sultan@kerneltoast.com> wrote:
>
> On Tue, Mar 12, 2019 at 09:05:32AM +0100, Michal Hocko wrote:
> > The only way to control the OOM behavior pro-actively is to throttle
> > allocation speed. We have memcg high limit for that purpose. Along with
> > PSI, I can imagine a reasonably working user space early oom
> > notifications and reasonable acting upon that.
>
> The issue with pro-active memory management that prompted me to create this was
> poor memory utilization. All of the alternative means of reclaiming pages in the
> page allocator's slow path turn out to be very useful for maximizing memory
> utilization, which is something that we would have to forgo by relying on a
> purely pro-active solution. I have not had a chance to look at PSI yet, but
> unless a PSI-enabled solution allows allocations to reach the same point as when
> the OOM killer is invoked (which is contradictory to what it sets out to do),
> then it cannot take advantage of all of the alternative memory-reclaim means
> employed in the slowpath, and will result in killing a process before it is
> _really_ necessary.

There are two essential parts of a lowmemorykiller implementation:
when to kill and how to kill.

There are a million possible approaches to decide when to kill an
unimportant process. They usually trade off between the same two
failure modes depending on the workload.

If you kill too aggressively, a transient spike that could be
imperceptibly absorbed by evicting some file pages or moving some
pages to ZRAM will result in killing processes, which then get started
up later and have a performance/battery cost.

If you don't kill aggressively enough, you will encounter a workload
that thrashes the page cache, constantly evicting and reloading file
pages and moving things in and out of ZRAM, which makes the system
unusable when a process should have been killed instead.

As far as I've seen, any methodology that uses single points in time
to decide when to kill without completely biasing toward one or the
other is susceptible to both. The minfree approach used by
lowmemorykiller/lmkd certainly is; it is both too aggressive for some
workloads and not aggressive enough for other workloads. My guess is
that simple LMK won't kill on transient spikes but will be extremely
susceptible to page cache thrashing. This is not an improvement; page
cache thrashing manifests as the entire system running very slowly.

What you actually want from lowmemorykiller/lmkd on Android is to only
kill once it becomes clear that the system will continue to try to
reclaim memory to the extent that it could impact what the user
actually cares about. That means tracking how much time is spent in
reclaim/paging operations and the like, and that's exactly what PSI
does. lmkd has had support for using PSI as a replacement for
vmpressure for use as a wakeup trigger (to check current memory levels
against the minfree thresholds) since early February. It works fine;
unsurprisingly it's better than vmpressure at avoiding false wakeups.

Longer term, there's a lot of work to be done in lmkd to turn PSI into
a kill trigger and remove minfree entirely. It's tricky (mainly
because of the "when to kill another process" problem discussed
later), but I believe it's feasible.

How to kill is similarly messy. The latency of reclaiming memory post
SIGKILL can be severe (usually tens of milliseconds, occasionally
>100ms). The latency we see on Android usually isn't because those
threads are blocked in uninterruptible sleep, it's because times of
memory pressure are also usually times of significant CPU contention
and these are overwhelmingly CFS threads, some of which may be
assigned a very low priority. lmkd now sets priorities and resets
cpusets upon killing a process, and we have seen improved reclaim
latency because of this. oom reaper might be a good approach to avoid
this latency (I think some in-kernel lowmemorykiller implementations
rely on it), but we can't use it from userspace. Something for future
consideration.

A non-obvious consequence of both of these concerns is that when to
kill a second process is a distinct and more difficult problem than
when to kill the first. A second process should be killed if reclaim
from the first process has finished and there has been insufficient
memory reclaimed to avoid perceptible impact. Identifying whether
memory pressure continues at the same level can probably be handled
through multiple PSI monitors with different thresholds and window
lengths, but this is an area of future work.

Knowing whether a SIGKILL'd process has finished reclaiming is as far
as I know not possible without something like procfds. That's where
the 100ms timeout in lmkd comes in. lowmemorykiller and lmkd both
attempt to wait up to 100ms for reclaim to finish by checking for the
continued existence of the thread that received the SIGKILL, but this
really means that they wait up to 100ms for the _thread_ to finish,
which doesn't tell you anything about the memory used by that process.
If those threads terminate early and lowmemorykiller/lmkd get a signal
to kill again, then there may be two processes competing for CPU time
to reclaim memory. That doesn't reclaim any faster and may be an
unnecessary kill.

So, in summary, the impactful LMK improvements seem like

- get lmkd and PSI to the point that lmkd can use PSI signals as a
kill trigger and remove all static memory thresholds from lmkd
completely. I think this is mostly on the lmkd side, but there may be
some PSI or PSI monitor changes that would help
- give userspace some path to start reclaiming memory without waiting
for every thread in a process to be scheduled--could be oom reaper,
could be something else
- offer a way to wait for process termination so lmkd can tell when
reclaim has finished and know when killing another process is
appropriate

