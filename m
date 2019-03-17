Return-Path: <SRS0=9bJk=RU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7BE80C43381
	for <linux-mm@archiver.kernel.org>; Sun, 17 Mar 2019 01:53:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E379B218AC
	for <linux-mm@archiver.kernel.org>; Sun, 17 Mar 2019 01:53:11 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=joelfernandes.org header.i=@joelfernandes.org header.b="lvYZldWO"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E379B218AC
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=joelfernandes.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 44CAC6B02E5; Sat, 16 Mar 2019 21:53:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3D5C36B02E6; Sat, 16 Mar 2019 21:53:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 276056B02E7; Sat, 16 Mar 2019 21:53:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 035556B02E5
	for <linux-mm@kvack.org>; Sat, 16 Mar 2019 21:53:11 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id f15so12720271qtk.16
        for <linux-mm@kvack.org>; Sat, 16 Mar 2019 18:53:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=ILZkJlDHGluZka2fkzTeUgYzxOyrE8GxGuvdCPMf3yI=;
        b=iFeDhswrgsTIQeohHtrkLOPw77TB1120SKWo+3SyuK4semvfpLCFnSAXlwpe76XEit
         9qKdA6uYLEuFOsO9hlRR2gmAFgPzZLkrHeW96Ulq1Ki/bzJBYnAzjnubeYkIAxmHHDfB
         rIkaOjrqnbwLgOJPuHMI9o9PC+4qmgaZAQfk8R+AID+ChcACOnXv5mWnKrDutgETimro
         AkWWpEt9ZqP+bG39GXgxAFq6XTVcCS8gabVKRlEeAULafqdp7ScJad9Jje361MwR5AJj
         YoJH5BCi4qSdgADPv2nAroXBdG87zVkOU8gxH2qJEP6ju2jhExAZWP7TrAAp2S4ATAjy
         QsHA==
X-Gm-Message-State: APjAAAWHSH20QiGPRcjgK2DNML/C7eKJmSJ/d8Zm5LDOQ5kHpxhV0PK8
	p/n32eY0YLxPmnMPG4fx9c4LPwuZJm0GFcO2x4nXgf3Awa0LkwtUkuD2zMkBTqbYxlCXj7oGX5I
	IU8f7GhYgnwIW13/hIwA+B5JYlJzdAFJf3T+FgWNNzVamcIyZI0D9iK/BirVRmw6rAg==
X-Received: by 2002:a0c:b785:: with SMTP id l5mr8112912qve.225.1552787590663;
        Sat, 16 Mar 2019 18:53:10 -0700 (PDT)
X-Received: by 2002:a0c:b785:: with SMTP id l5mr8112879qve.225.1552787589508;
        Sat, 16 Mar 2019 18:53:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552787589; cv=none;
        d=google.com; s=arc-20160816;
        b=INcw7xcdxua9EZWWzsNKbV634/7jwnBW+8OrpD8GbjsnRbySrasRARTwXwNbvAT1l9
         g7GtDHxCC48RiPqx/0Ju/atV+5LDKCHcj267x2E8SemZly7eefQ7gDYPQoLmuPRgCdX+
         GFX/HTAnyKj32FDENv/wy/Duq7++h81za6izhpAt9sgliZU7SqrCglMZnAsppk4QWFtk
         AAg2g6M5ojlEhoVCAQtvlaCh0vnT8mOmABb1bqkReOlQZOqcdsxKjF033qirpN3AIrh+
         MiqRBZtKhiat9h7Rk7V4zJeuR6fGDgFP0AOSUifzvFs0oH70QhkAihpINEELnET81TFL
         uokQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=ILZkJlDHGluZka2fkzTeUgYzxOyrE8GxGuvdCPMf3yI=;
        b=dhDGh2HrAm6/+Uz/Ov+iodrztVwUciwpg+GdO0HELqEZKL0MtDXaNu0JCbArM5ltnT
         YM+2GCSXJTA7hUachbk3/o2nzCcvxBQs2BOHLmABjKedWWYXaQun+RvHiIIU0bgUocFH
         1t1bjnlNux7DtuYyfmEe2HYCFPzy4ZoQo/8nWczJRDP3gXU1QvMzR74KYAGoGiJSs+C9
         OneR+7lYQsFRiTmofdcoMc+iMAXikHanIk8WcF5mxd22z2c7ZfpeNOgc9HfyEqB0mtYo
         5E6RdOdyQAl8V16cWS7NtvQRvPHsOgKFID/IrQ1NrN/g75irVmJhRu1n4Du7JoCLd5ox
         SQHg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@joelfernandes.org header.s=google header.b=lvYZldWO;
       spf=pass (google.com: domain of joel@joelfernandes.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=joel@joelfernandes.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k42sor7539554qtk.11.2019.03.16.18.53.09
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 16 Mar 2019 18:53:09 -0700 (PDT)
Received-SPF: pass (google.com: domain of joel@joelfernandes.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@joelfernandes.org header.s=google header.b=lvYZldWO;
       spf=pass (google.com: domain of joel@joelfernandes.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=joel@joelfernandes.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=joelfernandes.org; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=ILZkJlDHGluZka2fkzTeUgYzxOyrE8GxGuvdCPMf3yI=;
        b=lvYZldWOAMU2KQIk7kbFNCZvktBiCenIXI3oL2zOpwkzjlj4gAlJsm//3Ay98MT0S2
         Mf7QGFysehnvhN7SA0qDcAOh3bEq3c/JqnnfA1zgc09pcD+LFjSkkx28iSs1MkfAcF/g
         SJHU7ubRoIIHDNdXY1XC4iRMZdOo5KPkZic+0=
X-Google-Smtp-Source: APXvYqyVKiesYnL8uDLY0KIeLwDxZeNBKT5h0fYiIf0SKrQkIIdFB6queW6UciuCeMh1mZaa0gK8pg==
X-Received: by 2002:aed:3b9c:: with SMTP id r28mr8864538qte.22.1552787588984;
        Sat, 16 Mar 2019 18:53:08 -0700 (PDT)
Received: from localhost ([2620:0:1004:1100:cca9:fccc:8667:9bdc])
        by smtp.gmail.com with ESMTPSA id m8sm3554479qkk.45.2019.03.16.18.53.07
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sat, 16 Mar 2019 18:53:07 -0700 (PDT)
Date: Sat, 16 Mar 2019 21:53:06 -0400
From: Joel Fernandes <joel@joelfernandes.org>
To: Suren Baghdasaryan <surenb@google.com>
Cc: Christian Brauner <christian@brauner.io>,
	Daniel Colascione <dancol@google.com>,
	Steven Rostedt <rostedt@goodmis.org>,
	Sultan Alsawaf <sultan@kerneltoast.com>,
	Tim Murray <timmurray@google.com>, Michal Hocko <mhocko@kernel.org>,
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
Message-ID: <20190317015306.GA167393@google.com>
References: <20190314231641.5a37932b@oasis.local.home>
 <CAKOZuetZHJzmQy3n001x4+rmWoWHEgUv2Zvow9W5+xvukxp1JQ@mail.gmail.com>
 <20190315180306.sq3z645p3hygrmt2@brauner.io>
 <20190315181324.GA248160@google.com>
 <20190315182426.sujcqbzhzw4llmsa@brauner.io>
 <20190315184903.GB248160@google.com>
 <CAJuCfpGp_9fE9MPGVCWjnTaeBE0K_Q22LS1pBqhp7zW2M=dbGw@mail.gmail.com>
 <CAKOZueuauUXRyrvhzBD0op6W4TAnydSx92bvrPN2VRWERX8iQg@mail.gmail.com>
 <20190316185726.jc53aqq5ph65ojpk@brauner.io>
 <CAJuCfpF-uYpUZ1RO99i2qEw5Ou4nSimSkiQvnNQ_rv8ogHKRfw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAJuCfpF-uYpUZ1RO99i2qEw5Ou4nSimSkiQvnNQ_rv8ogHKRfw@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Mar 16, 2019 at 12:37:18PM -0700, Suren Baghdasaryan wrote:
> On Sat, Mar 16, 2019 at 11:57 AM Christian Brauner <christian@brauner.io> wrote:
> >
> > On Sat, Mar 16, 2019 at 11:00:10AM -0700, Daniel Colascione wrote:
> > > On Sat, Mar 16, 2019 at 10:31 AM Suren Baghdasaryan <surenb@google.com> wrote:
> > > >
> > > > On Fri, Mar 15, 2019 at 11:49 AM Joel Fernandes <joel@joelfernandes.org> wrote:
> > > > >
> > > > > On Fri, Mar 15, 2019 at 07:24:28PM +0100, Christian Brauner wrote:
> > > > > [..]
> > > > > > > why do we want to add a new syscall (pidfd_wait) though? Why not just use
> > > > > > > standard poll/epoll interface on the proc fd like Daniel was suggesting.
> > > > > > > AFAIK, once the proc file is opened, the struct pid is essentially pinned
> > > > > > > even though the proc number may be reused. Then the caller can just poll.
> > > > > > > We can add a waitqueue to struct pid, and wake up any waiters on process
> > > > > > > death (A quick look shows task_struct can be mapped to its struct pid) and
> > > > > > > also possibly optimize it using Steve's TIF flag idea. No new syscall is
> > > > > > > needed then, let me know if I missed something?
> > > > > >
> > > > > > Huh, I thought that Daniel was against the poll/epoll solution?
> > > > >
> > > > > Hmm, going through earlier threads, I believe so now. Here was Daniel's
> > > > > reasoning about avoiding a notification about process death through proc
> > > > > directory fd: http://lkml.iu.edu/hypermail/linux/kernel/1811.0/00232.html
> > > > >
> > > > > May be a dedicated syscall for this would be cleaner after all.
> > > >
> > > > Ah, I wish I've seen that discussion before...
> > > > syscall makes sense and it can be non-blocking and we can use
> > > > select/poll/epoll if we use eventfd.
> > >
> > > Thanks for taking a look.
> > >
> > > > I would strongly advocate for
> > > > non-blocking version or at least to have a non-blocking option.
> > >
> > > Waiting for FD readiness is *already* blocking or non-blocking
> > > according to the caller's desire --- users can pass options they want
> > > to poll(2) or whatever. There's no need for any kind of special
> > > configuration knob or non-blocking option. We already *have* a
> > > non-blocking option that works universally for everything.
> > >
> > > As I mentioned in the linked thread, waiting for process exit should
> > > work just like waiting for bytes to appear on a pipe. Process exit
> > > status is just another blob of bytes that a process might receive. A
> > > process exit handle ought to be just another information source. The
> > > reason the unix process API is so awful is that for whatever reason
> > > the original designers treated processes as some kind of special kind
> > > of resource instead of fitting them into the otherwise general-purpose
> > > unix data-handling API. Let's not repeat that mistake.
> > >
> > > > Something like this:
> > > >
> > > > evfd = eventfd(0, EFD_NONBLOCK | EFD_CLOEXEC);
> > > > // register eventfd to receive death notification
> > > > pidfd_wait(pid_to_kill, evfd);
> > > > // kill the process
> > > > pidfd_send_signal(pid_to_kill, ...)
> > > > // tend to other things
> > >
> > > Now you've lost me. pidfd_wait should return a *new* FD, not wire up
> > > an eventfd.
> > >
> 
> Ok, I probably misunderstood your post linked by Joel. I though your
> original proposal was based on being able to poll a file under
> /proc/pid and then you changed your mind to have a separate syscall
> which I assumed would be a blocking one to wait for process exit.
> Maybe you can describe the new interface you are thinking about in
> terms of userspace usage like I did above? Several lines of code would
> explain more than paragraphs of text.

Hey, Thanks Suren for the eventfd idea. I agree with Daniel on this. The idea
from Daniel here is to wait for process death and exit events by just
referring to a stable fd, independent of whatever is going on in /proc.

What is needed is something like this (in highly pseudo-code form):

pidfd = opendir("/proc/<pid>",..);
wait_fd = pidfd_wait(pidfd);
read or poll wait_fd (non-blocking or blocking whichever)

wait_fd will block until the task has either died or reaped. In both these
cases, it can return a suitable string such as "dead" or "reaped" although an
integer with some predefined meaning is also Ok.

What that guarantees is, even if the task's PID has been reused, or the task
has already died or already died + reaped, all of these events cannot race
with the code above and the information passed to the user is race-free and
stable / guaranteed.

An eventfd seems to not fit well, because AFAICS passing the raw PID to
eventfd as in your example would still race since the PID could have been
reused by another process by the time the eventfd is created.

Also Andy's idea in [1] seems to use poll flags to communicate various tihngs
which is still not as explicit about the PID's status so that's a poor API
choice compared to the explicit syscall.

I am planning to work on a prototype patch based on Daniel's idea and post something
soon (chatted with Daniel about it and will reference him in the posting as
well), during this posting I will also summarize all the previous discussions
and come up with some tests as well.  I hope to have something soon.

Let me know if I hit all the points correctly and I hope we are all on the
same page.

Thanks!

 - Joel

[1] http://lkml.iu.edu/hypermail//linux/kernel/1212.0/00808.html

