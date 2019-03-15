Return-Path: <SRS0=L2Uh=RS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D6580C10F00
	for <linux-mm@archiver.kernel.org>; Fri, 15 Mar 2019 16:43:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 953CD218D0
	for <linux-mm@archiver.kernel.org>; Fri, 15 Mar 2019 16:43:54 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 953CD218D0
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=goodmis.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 27D1C6B0290; Fri, 15 Mar 2019 12:43:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 204A66B0292; Fri, 15 Mar 2019 12:43:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0CD356B0293; Fri, 15 Mar 2019 12:43:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id BF49C6B0290
	for <linux-mm@kvack.org>; Fri, 15 Mar 2019 12:43:53 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id f6so10674591pgo.15
        for <linux-mm@kvack.org>; Fri, 15 Mar 2019 09:43:53 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=1xgekOBVffSTeVbtQD1XDRPdkSDm9vBxhenoNR6GhYo=;
        b=CKNohlMfV/qTrr1q+Z85sGdcK9VAdeKpgejcexnmRTBdBbCzqvl79Hf3tk1gV2Glpn
         pm8ix/mi3zEu9BOtry6bAwB9mAkUsndguFwcu7L+KOmSRYkFAffuCWEWZF+ca6cmkCj9
         TLGZS5Wbi4XcZi4bBHYfa0YCulr7uKHgN6NdjLJsm0RvRb8mVmgXJbLYRhDb7jCi4i8R
         bwUMd42ShU+6aYUGkmasvSghMpDdE+SM5eQ+vEYD4mNSp4hKJ3JvNG8oszuUULhJkv2W
         qf9IPDKWEhc+VMlJf1eu0WSmrjY7j5Xapk4ZwvvaqAK6fG3TVm00K8rdbyd5CP2edCwR
         YCog==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of srs0=vfcv=rs=goodmis.org=rostedt@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom="SRS0=VfCv=RS=goodmis.org=rostedt@kernel.org"
X-Gm-Message-State: APjAAAX/yvW5NZgAt768650RUVGsmOwdJqE2VR7OREiUTcTKFRLO1ZlH
	kysxjBUT9GwFO+FioiKpMaNdsuvL7hglZhz8IlBetLG8L5mvC/SPRwcWi0Y2DQTqnb3t5eDusAE
	toGOgnaP1DVvyqMjsjiNF1Qn5CsIu/b3Kwxisz4pYK2N5nGl2O5rdV6xqhUhiEvc=
X-Received: by 2002:a62:b502:: with SMTP id y2mr4974308pfe.212.1552668233419;
        Fri, 15 Mar 2019 09:43:53 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzJgbMeIzhAnYCUz7kUTCNpkTFyuW3DZSbcRcy7knC+TYAAHV0sRn43h4Mgnhu22U3gUphr
X-Received: by 2002:a62:b502:: with SMTP id y2mr4974183pfe.212.1552668231857;
        Fri, 15 Mar 2019 09:43:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552668231; cv=none;
        d=google.com; s=arc-20160816;
        b=egJLY3M2KW6KMGj09jZxTctvZfhUPSXIH3o/WWUqDLLGfCHGA1nxIil7sIb/8ZSQED
         5BM1hOTt+6KD3kUva6nX4MaUKHcQnL8/MyOLL7n5T4s//ZHbGzFdN2mzAapgEsvkHY0m
         D6yWcxTl3lI3p/JcDP7ldEoEZPusP4+vITPM2XI6L7Mt96MUdLbhROGIePB9Pe06uDWR
         tOzrvU1Q/+nk4855Fxtup3fGPslRC1MxPlqZj+SIVPCaQssS6LhNA5cSsQV2Rtc4v67S
         1bqxr22AdCSHMc7DuuA+5xJHPwhAYJwY8nd/iCRDDf79HRsi/cfIu5ngTc35jBXelVNm
         oDEg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=1xgekOBVffSTeVbtQD1XDRPdkSDm9vBxhenoNR6GhYo=;
        b=ACBMVflfEgnNcvlsWmJbJkwfLXHtpAqFjA0QS0edaHnZVJtePHIJUpHDGQCbsNgNsv
         HqV+y2QSjd/cW7SvLwcJNRv7NblWmn4EP9jawoT8enUbAvwMr+yVh0k2cSnyzyvkl517
         7Bv/+WqcGIxeKumZfsT/VWFMd2cvD/VBg6SA1s+1uKFS6sgOgcKBYH7QOCYOGW1bZA3t
         StANG84NT0xA0HgrNa/GaJm8yqWs8BIFeYLvtpzQWDtKRDo+irMilIB1PY+VNJ4ns5jF
         vvhgLzPf4SqJpQsBGQqC0Ok94KyJk5FMvm0dTVCmKz1DN/hB9KPI0YwkuuiLk1Md78K0
         nnKg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of srs0=vfcv=rs=goodmis.org=rostedt@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom="SRS0=VfCv=RS=goodmis.org=rostedt@kernel.org"
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id d25si2151887pgv.468.2019.03.15.09.43.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Mar 2019 09:43:51 -0700 (PDT)
Received-SPF: pass (google.com: domain of srs0=vfcv=rs=goodmis.org=rostedt@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of srs0=vfcv=rs=goodmis.org=rostedt@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom="SRS0=VfCv=RS=goodmis.org=rostedt@kernel.org"
Received: from gandalf.local.home (cpe-66-24-58-225.stny.res.rr.com [66.24.58.225])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 09713218AC;
	Fri, 15 Mar 2019 16:43:49 +0000 (UTC)
Date: Fri, 15 Mar 2019 12:43:48 -0400
From: Steven Rostedt <rostedt@goodmis.org>
To: Daniel Colascione <dancol@google.com>
Cc: Sultan Alsawaf <sultan@kerneltoast.com>, Joel Fernandes
 <joel@joelfernandes.org>, Tim Murray <timmurray@google.com>, Michal Hocko
 <mhocko@kernel.org>, Suren Baghdasaryan <surenb@google.com>, Greg
 Kroah-Hartman <gregkh@linuxfoundation.org>, Arve =?UTF-8?B?SGrDuG5uZXY=?=
 =?UTF-8?B?w6Vn?= <arve@android.com>, Todd Kjos <tkjos@android.com>, Martijn
 Coenen <maco@android.com>, Christian Brauner <christian@brauner.io>, Ingo
 Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, LKML
 <linux-kernel@vger.kernel.org>, "open list:ANDROID DRIVERS"
 <devel@driverdev.osuosl.org>, linux-mm <linux-mm@kvack.org>, kernel-team
 <kernel-team@android.com>
Subject: Re: [RFC] simple_lmk: Introduce Simple Low Memory Killer for
 Android
Message-ID: <20190315124348.528ecd87@gandalf.local.home>
In-Reply-To: <CAKOZuetZHJzmQy3n001x4+rmWoWHEgUv2Zvow9W5+xvukxp1JQ@mail.gmail.com>
References: <20190310203403.27915-1-sultan@kerneltoast.com>
	<20190311174320.GC5721@dhcp22.suse.cz>
	<20190311175800.GA5522@sultan-box.localdomain>
	<CAJuCfpHTjXejo+u--3MLZZj7kWQVbptyya4yp1GLE3hB=BBX7w@mail.gmail.com>
	<20190311204626.GA3119@sultan-box.localdomain>
	<CAJuCfpGpBxofTT-ANEEY+dFCSdwkQswox3s8Uk9Eq0BnK9i0iA@mail.gmail.com>
	<20190312080532.GE5721@dhcp22.suse.cz>
	<20190312163741.GA2762@sultan-box.localdomain>
	<CAEe=Sxn_uayj48wo7oqf8mNZ7QAGJUQVmkPcHcuEGjA_Z8ELeQ@mail.gmail.com>
	<CAEXW_YQMnbN+e-janGbZc5MH6MwdUdXNfonpLUu5O2nsSkJyeg@mail.gmail.com>
	<20190314204911.GA875@sultan-box.localdomain>
	<20190314231641.5a37932b@oasis.local.home>
	<CAKOZuetZHJzmQy3n001x4+rmWoWHEgUv2Zvow9W5+xvukxp1JQ@mail.gmail.com>
X-Mailer: Claws Mail 3.16.0 (GTK+ 2.24.32; x86_64-pc-linux-gnu)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 14 Mar 2019 21:36:43 -0700
Daniel Colascione <dancol@google.com> wrote:

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

I wasn't Cc'd on the original work, so I haven't read them.

> 
> > If you can solve this with an ebpf program, I
> > strongly suggest you do that instead.  
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
> 
> In any case, there's a clear path forward here --- general-purpose,
> cheap, and elegant --- and we should just focus on doing that instead
> of more complex proposals with few advantages.

If you add new pidfd systemcalls then making a new way to send a signal
and block till it does die or whatever is more acceptable than adding a
new signal that changes the semantics of sending signals, which is what
I was against.

I do agree with Joel about bloating task_struct too. If anything, have
a wait queue you add, where you can allocate a descriptor with the task
dieing and task killing, and just search this queue on dying. We could
add a TIF flag to the task as well to let the exiting of this task know
it should do such an operation.

-- Steve

