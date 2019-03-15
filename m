Return-Path: <SRS0=L2Uh=RS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DD34CC43381
	for <linux-mm@archiver.kernel.org>; Fri, 15 Mar 2019 02:54:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9B7092186A
	for <linux-mm@archiver.kernel.org>; Fri, 15 Mar 2019 02:54:52 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=joelfernandes.org header.i=@joelfernandes.org header.b="yI4EShvC"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9B7092186A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=joelfernandes.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 33E306B000D; Thu, 14 Mar 2019 22:54:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2C54F6B000E; Thu, 14 Mar 2019 22:54:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 165456B0010; Thu, 14 Mar 2019 22:54:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id D9F926B000D
	for <linux-mm@kvack.org>; Thu, 14 Mar 2019 22:54:51 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id k21so6593801qkg.19
        for <linux-mm@kvack.org>; Thu, 14 Mar 2019 19:54:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=HUgh40+C8/2OCmX/UW2ZUro8RAG3vLQ9m//fEUxwous=;
        b=QjbdTl43f6/bdJzk72TcnpYUx3q7F/QSatrwBtyRh2G6uTUhuoGwrnWVR6P89taIlQ
         nQcZY9+38vwN0PyG8OhRJ8vlZSllA2ndN0q+8rzw5OzQVohIk0uTJ2MPiLHtZ1C3XTd+
         gMrQCrWWN3bn2/Ey3iUGY1noBDkAuBUhsmgqyjkeFbHLa4dAtWJOOnNb3PSfkLaHEdr/
         VO78at9SAToJqa+5wppBFsDSqj6qPOz2teJaLPWQnIJjYvnNPGbI5KjOKlcZ5vrUtMbf
         l8FTUrk1nlK1+BLCxp/syNDfhSb3M1RRGncLUzQMCT1CWeKrd1kB3OsCBf46CHQH+Cg2
         aQsg==
X-Gm-Message-State: APjAAAU8fK/ofLY+hHuK3yCa7bAw1d1wWXmrOM/pC68vZvbDshwQAn5l
	wVK4rdzrQQ1LImzkcmJOAPJFmYhCcwK17clxUpC3H0z+1pLSXrcD5GhOuhtlBpOwTIw3ezHKbtp
	JeRhF3gr6aI1W/qma9jaWs10BKSJp6hBA5Z0IZ/KGslAzgMkj+1y0+tPN60j2BH7LNA==
X-Received: by 2002:a0c:d1f4:: with SMTP id k49mr867257qvh.164.1552618491608;
        Thu, 14 Mar 2019 19:54:51 -0700 (PDT)
X-Received: by 2002:a0c:d1f4:: with SMTP id k49mr867217qvh.164.1552618490668;
        Thu, 14 Mar 2019 19:54:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552618490; cv=none;
        d=google.com; s=arc-20160816;
        b=JOSgdfHDoJzVAYrmJ4G6IHenzefZG1EE91/Q+pfwtZXWvUrowNv+3KVsYsLjrR5tUq
         Vfz66ODaGxZRsagwXYplLamub87ywf6aybXBSXnDi9tPeBNIKJct+Ow7GEpIxA55Fe8B
         6jXEehO22lL4EJQiisuLtw2cQ78voyEs+sImA0NMH7YCryx/mASBTVPDcrhpXVZZrnlL
         QlwX9eMu5Z6ei0JlkfUuhvRxTtDrVTNV+rrDKq91tf9ESbPJ5M5dv5X3Yo+YSipfYM+r
         8Rtdft60l03c5do+cbn2iztnPSIUQgG9+kMmeyiyLFSwvR/5MW76kRQKTQmPovKIMYG7
         57fw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=HUgh40+C8/2OCmX/UW2ZUro8RAG3vLQ9m//fEUxwous=;
        b=038humvFst24O+qORhYPd86QJuZ6cDC7tLd6ViuM+iiu6L/lriJ9lBojtYB+Gd/UJl
         pkjD+JCKJeDWTGuubKcS0RZvdIwQr7yCIT5KufQy381m+hmI9zy6LIl0/ze8rh55BB5X
         sge2h6lciuXlt0x2Y/iN93mAwakKb4BERTIxhLB9x2hvPex+SK7ewOTa1xY1n4PVoHIh
         E6hqIN5CI68ytWg+QgsNvZxFhhGnMUB4VerEjBHpkIUnau00KRzkBrXRfqFepxM2arEs
         eJYpceyKE+IPIwqp3okc5PC0RSdKHffVhODPL+5+MZ3EYez/897rkgSkfkoQhiyHhv84
         RfUQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@joelfernandes.org header.s=google header.b=yI4EShvC;
       spf=pass (google.com: domain of joel@joelfernandes.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=joel@joelfernandes.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b21sor866921qta.61.2019.03.14.19.54.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 14 Mar 2019 19:54:50 -0700 (PDT)
Received-SPF: pass (google.com: domain of joel@joelfernandes.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@joelfernandes.org header.s=google header.b=yI4EShvC;
       spf=pass (google.com: domain of joel@joelfernandes.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=joel@joelfernandes.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=joelfernandes.org; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=HUgh40+C8/2OCmX/UW2ZUro8RAG3vLQ9m//fEUxwous=;
        b=yI4EShvCw/j4gXJcpUISzIi8Bw5cyKpRaLwfltUsa6vojDsQPaxDnRHeimDILntWAj
         YMRMNndwkBlmTVzNFtYnRPkbZSdm/oMuzz6LM5ALkQPzKZtYlYTfQ3qAtr2sAaUmXu8H
         TZybdGHGjVN1QkU953zx10q6o0GqeocdPA9Go=
X-Google-Smtp-Source: APXvYqwmSeslzsMFyhE1hdB2M/6gE5HGS+bSWP4pkJjMaob6xQq6c98ZXFsBaiV/FMTpT0VUQjZmSA==
X-Received: by 2002:ac8:7606:: with SMTP id t6mr1020145qtq.243.1552618490194;
        Thu, 14 Mar 2019 19:54:50 -0700 (PDT)
Received: from localhost ([2620:0:1004:1100:cca9:fccc:8667:9bdc])
        by smtp.gmail.com with ESMTPSA id 50sm413653qtr.96.2019.03.14.19.54.48
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 14 Mar 2019 19:54:48 -0700 (PDT)
Date: Thu, 14 Mar 2019 22:54:48 -0400
From: Joel Fernandes <joel@joelfernandes.org>
To: Sultan Alsawaf <sultan@kerneltoast.com>
Cc: Tim Murray <timmurray@google.com>, Michal Hocko <mhocko@kernel.org>,
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
	kernel-team <kernel-team@android.com>,
	Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [RFC] simple_lmk: Introduce Simple Low Memory Killer for Android
Message-ID: <20190315025448.GA3378@google.com>
References: <20190311174320.GC5721@dhcp22.suse.cz>
 <20190311175800.GA5522@sultan-box.localdomain>
 <CAJuCfpHTjXejo+u--3MLZZj7kWQVbptyya4yp1GLE3hB=BBX7w@mail.gmail.com>
 <20190311204626.GA3119@sultan-box.localdomain>
 <CAJuCfpGpBxofTT-ANEEY+dFCSdwkQswox3s8Uk9Eq0BnK9i0iA@mail.gmail.com>
 <20190312080532.GE5721@dhcp22.suse.cz>
 <20190312163741.GA2762@sultan-box.localdomain>
 <CAEe=Sxn_uayj48wo7oqf8mNZ7QAGJUQVmkPcHcuEGjA_Z8ELeQ@mail.gmail.com>
 <CAEXW_YQMnbN+e-janGbZc5MH6MwdUdXNfonpLUu5O2nsSkJyeg@mail.gmail.com>
 <20190314204911.GA875@sultan-box.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190314204911.GA875@sultan-box.localdomain>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Mar 14, 2019 at 01:49:11PM -0700, Sultan Alsawaf wrote:
> On Thu, Mar 14, 2019 at 10:47:17AM -0700, Joel Fernandes wrote:
> > About the 100ms latency, I wonder whether it is that high because of
> > the way Android's lmkd is observing that a process has died. There is
> > a gap between when a process memory is freed and when it disappears
> > from the process-table.  Once a process is SIGKILLed, it becomes a
> > zombie. Its memory is freed instantly during the SIGKILL delivery (I
> > traced this so that's how I know), but until it is reaped by its
> > parent thread, it will still exist in /proc/<pid> . So if testing the
> > existence of /proc/<pid> is how Android is observing that the process
> > died, then there can be a large latency where it takes a very long
> > time for the parent to actually reap the child way after its memory
> > was long freed. A quicker way to know if a process's memory is freed
> > before it is reaped could be to read back /proc/<pid>/maps in
> > userspace of the victim <pid>, and that file will be empty for zombie
> > processes. So then one does not need wait for the parent to reap it. I
> > wonder how much of that 100ms you mentioned is actually the "Waiting
> > while Parent is reaping the child", than "memory freeing time". So
> > yeah for this second problem, the procfds work will help.
> >
> > By the way another approach that can provide a quick and asynchronous
> > notification of when the process memory is freed, is to monitor
> > sched_process_exit trace event using eBPF. You can tell eBPF the PID
> > that you want to monitor before the SIGKILL. As soon as the process
> > dies and its memory is freed, the eBPF program can send a notification
> > to user space (using the perf_events polling infra). The
> > sched_process_exit fires just after the mmput() happens so it is quite
> > close to when the memory is reclaimed. This also doesn't need any
> > kernel changes. I could come up with a prototype for this and
> > benchmark it on Android, if you want. Just let me know.
> 
> Perhaps I'm missing something, but if you want to know when a process has died
> after sending a SIGKILL to it, then why not just make the SIGKILL optionally
> block until the process has died completely? It'd be rather trivial to just
> store a pointer to an onstack completion inside the victim process' task_struct,
> and then complete it in free_task().

I'm not sure if that makes much semantic sense for how the signal handling is
supposed to work. Imagine a parent sends SIGKILL to its child, and then does
a wait(2). Because the SIGKILL blocks in your idea, then the wait cannot
execute, and because the wait cannot execute, the zombie task will not get
reaped and so the SIGKILL senders never gets unblocked and the whole thing
just gets locked up. No? I don't know it just feels incorrect.

Further, in your idea adding stuff to task_struct will simply bloat it - when
this task can easily be handled using eBPF without making any kernel changes.
Either by probing sched_process_free or sched_process_exit tracepoints.
Scheduler maintainers generally frown on adding stuff to task_struct
pointlessly there's a good reason since bloating it effects the performance
etc, and something like this would probably never be ifdef'd out behind a
CONFIG.

thanks,

 - Joel

