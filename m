Return-Path: <SRS0=HgWV=RT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,URIBL_BLOCKED,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6AF96C43381
	for <linux-mm@archiver.kernel.org>; Sat, 16 Mar 2019 18:00:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1F91A218D0
	for <linux-mm@archiver.kernel.org>; Sat, 16 Mar 2019 18:00:25 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="Coq92k1U"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1F91A218D0
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B05D36B02D9; Sat, 16 Mar 2019 14:00:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AB61D6B02DA; Sat, 16 Mar 2019 14:00:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9CB416B02DB; Sat, 16 Mar 2019 14:00:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f198.google.com (mail-vk1-f198.google.com [209.85.221.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6E5076B02D9
	for <linux-mm@kvack.org>; Sat, 16 Mar 2019 14:00:24 -0400 (EDT)
Received: by mail-vk1-f198.google.com with SMTP id n132so5150558vke.1
        for <linux-mm@kvack.org>; Sat, 16 Mar 2019 11:00:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=y1KWqgI146pcCdR1U2CQh3JRG48myF0xT/kFf++SZRs=;
        b=ofaDrNJlslNYiLJP1x9b41om+pka1ZziZMnc31frfqRvwkySAAKcwMk/A22H593CFu
         g1NwOx//Jx/cK0bnuvDt28p7AQoxYlQp1QzR3jp4gusWzx28UuUwLbhlMonZ56XXl8h0
         vKDco5R/U8QIDLusjfie4bgVUFr2BRixOk+3k6atjx8P44AQFycnJjTiGkBaqrHCuEXn
         H3Z6S1+Lw9BpTaAVvs7eKotJLPl4Tmtmj9O4umMWt5OA/TelI9BiB3017i23yHl62bVO
         cxiDYZaqTnj5KCr9V4ZsVEK/umg3f2Bfimzi3y+cFhxWeiY8WkYlbqjNfpzAmq+brmTs
         rOTw==
X-Gm-Message-State: APjAAAUqVGaUJiW92UGFTaa2EkBK/l7qA4wtNcCVCKuS3VICxMJWZQv2
	J4uTGu3rOGM3dacFrR7Rm++Nxmd1ZQoz49PLho3HeS1uZH7mbWLZujV5ubExAqrdvAhizHzJFiO
	3rkLB8f8SLowGGzC1l/ApEomXRDOVJb5AHqoZmCgnXr3/1z7NMFd5Hr7aYVDnd2Mydw==
X-Received: by 2002:a1f:3fc5:: with SMTP id m188mr5176616vka.88.1552759224051;
        Sat, 16 Mar 2019 11:00:24 -0700 (PDT)
X-Received: by 2002:a1f:3fc5:: with SMTP id m188mr5176571vka.88.1552759222965;
        Sat, 16 Mar 2019 11:00:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552759222; cv=none;
        d=google.com; s=arc-20160816;
        b=TekdoeEvvz5jhwUXcDnc1Ejpi3sht+uObpAsu3JpjITnx+NbNEU6o7b5v0xQoE1bVb
         DvLC8TarWdHFywB7KEha/y+fN7nNRkUw3zrGNY82Uphvo2fPGDPRHhv9uU8vEZhxSZdq
         BZwLDuYDTvm//FI/IuKXJ8+d85YhEspoQcw8Wl9UU/0EDIkaQNHAnO+TxmQNSNveekVX
         1CcmA2+FzygjKDNBZkhNz0p9+zjaE71kNnl8QjeGmoX0E+rHle67pOjYmgjVAG/jVxSg
         BOieQQBmjhqdX/j/X9udgGvyu5J3CsbDcHx8o6AdKqbeinoIluFlme/ktkY6xqj8OZ4M
         9xvw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=y1KWqgI146pcCdR1U2CQh3JRG48myF0xT/kFf++SZRs=;
        b=RDVFDncg/P49a6ltQzB7hMK8Zz7u6AR578/nyAuYRjykM7L5vrsULnTfjnYzpHt15W
         zqNGv9R8iXVBmwRyvQS3+/UTnkQucU/IYxYUCnveM9qjmvnrlIHYr4UNSROXwusO91/n
         +fhCfCokOY1wOL3MZElREGVfTr6GLFzxx2CfqoQluD+2bHGk+4JC23lKfdkHDBn+NOiF
         H8oUZ8PxCrwJStRrCpsWxK6A0y7o1+lEL1RFqLa+Zo+zwsWB1Oe8+x2Y4e0ZZcZMuwYt
         aTSBfPNHOGWhsuZQth+zhw9SWO96q6PgQnZMx5Ax8phZTn65hXKHk3VgHvVXJYHePgWq
         RiYw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=Coq92k1U;
       spf=pass (google.com: domain of dancol@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dancol@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c190sor3308526vsd.54.2019.03.16.11.00.22
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 16 Mar 2019 11:00:22 -0700 (PDT)
Received-SPF: pass (google.com: domain of dancol@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=Coq92k1U;
       spf=pass (google.com: domain of dancol@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dancol@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=y1KWqgI146pcCdR1U2CQh3JRG48myF0xT/kFf++SZRs=;
        b=Coq92k1UdoV5Q253tI8ums9wCkyCqFEN3X7Ant4Okl6f1FVMmVeLNyT88lpfOsYYHp
         m7boY9BdRcNA6TztSAc3SmEjZOU3cqBGizSS6dFShpFvBCHj9QfGc0sudpXraek+kf5u
         0Dm+BnzXD2PF8fPHQUp315YZfEQZr6knDW6OkHhX8csU/feRgnhSICEQ9NkWv8QWW5iy
         vGAMW5gWcAIRu+8G1q6V7PD2XLM1UxU+DXc1yK4ATZ6qrmgldBu1sIOFRWvt30FBBeTs
         A8B+gCMYc75LlARyp9pV+JmiKDg+qig+y1WImaBSKJIGrhtklGqoOL+AlDxEizsFxX4V
         gcHQ==
X-Google-Smtp-Source: APXvYqwNNvDDR6l5GKlr6n6DeDJQfVTBZUQu2nFEDyH/YbP5PqOPzwp8wG6UT3Pi6Z4ruCHRrzVBG57zi0T9tKyMSkM=
X-Received: by 2002:a67:cc2:: with SMTP id 185mr136686vsm.77.1552759222160;
 Sat, 16 Mar 2019 11:00:22 -0700 (PDT)
MIME-Version: 1.0
References: <20190312080532.GE5721@dhcp22.suse.cz> <20190312163741.GA2762@sultan-box.localdomain>
 <CAEe=Sxn_uayj48wo7oqf8mNZ7QAGJUQVmkPcHcuEGjA_Z8ELeQ@mail.gmail.com>
 <CAEXW_YQMnbN+e-janGbZc5MH6MwdUdXNfonpLUu5O2nsSkJyeg@mail.gmail.com>
 <20190314204911.GA875@sultan-box.localdomain> <20190314231641.5a37932b@oasis.local.home>
 <CAKOZuetZHJzmQy3n001x4+rmWoWHEgUv2Zvow9W5+xvukxp1JQ@mail.gmail.com>
 <20190315180306.sq3z645p3hygrmt2@brauner.io> <20190315181324.GA248160@google.com>
 <20190315182426.sujcqbzhzw4llmsa@brauner.io> <20190315184903.GB248160@google.com>
 <CAJuCfpGp_9fE9MPGVCWjnTaeBE0K_Q22LS1pBqhp7zW2M=dbGw@mail.gmail.com>
In-Reply-To: <CAJuCfpGp_9fE9MPGVCWjnTaeBE0K_Q22LS1pBqhp7zW2M=dbGw@mail.gmail.com>
From: Daniel Colascione <dancol@google.com>
Date: Sat, 16 Mar 2019 11:00:10 -0700
Message-ID: <CAKOZueuauUXRyrvhzBD0op6W4TAnydSx92bvrPN2VRWERX8iQg@mail.gmail.com>
Subject: Re: [RFC] simple_lmk: Introduce Simple Low Memory Killer for Android
To: Suren Baghdasaryan <surenb@google.com>
Cc: Joel Fernandes <joel@joelfernandes.org>, Christian Brauner <christian@brauner.io>, 
	Steven Rostedt <rostedt@goodmis.org>, Sultan Alsawaf <sultan@kerneltoast.com>, 
	Tim Murray <timmurray@google.com>, Michal Hocko <mhocko@kernel.org>, 
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>, =?UTF-8?B?QXJ2ZSBIasO4bm5ldsOlZw==?= <arve@android.com>, 
	Todd Kjos <tkjos@android.com>, Martijn Coenen <maco@android.com>, Ingo Molnar <mingo@redhat.com>, 
	Peter Zijlstra <peterz@infradead.org>, LKML <linux-kernel@vger.kernel.org>, 
	"open list:ANDROID DRIVERS" <devel@driverdev.osuosl.org>, linux-mm <linux-mm@kvack.org>, 
	kernel-team <kernel-team@android.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Mar 16, 2019 at 10:31 AM Suren Baghdasaryan <surenb@google.com> wrote:
>
> On Fri, Mar 15, 2019 at 11:49 AM Joel Fernandes <joel@joelfernandes.org> wrote:
> >
> > On Fri, Mar 15, 2019 at 07:24:28PM +0100, Christian Brauner wrote:
> > [..]
> > > > why do we want to add a new syscall (pidfd_wait) though? Why not just use
> > > > standard poll/epoll interface on the proc fd like Daniel was suggesting.
> > > > AFAIK, once the proc file is opened, the struct pid is essentially pinned
> > > > even though the proc number may be reused. Then the caller can just poll.
> > > > We can add a waitqueue to struct pid, and wake up any waiters on process
> > > > death (A quick look shows task_struct can be mapped to its struct pid) and
> > > > also possibly optimize it using Steve's TIF flag idea. No new syscall is
> > > > needed then, let me know if I missed something?
> > >
> > > Huh, I thought that Daniel was against the poll/epoll solution?
> >
> > Hmm, going through earlier threads, I believe so now. Here was Daniel's
> > reasoning about avoiding a notification about process death through proc
> > directory fd: http://lkml.iu.edu/hypermail/linux/kernel/1811.0/00232.html
> >
> > May be a dedicated syscall for this would be cleaner after all.
>
> Ah, I wish I've seen that discussion before...
> syscall makes sense and it can be non-blocking and we can use
> select/poll/epoll if we use eventfd.

Thanks for taking a look.

> I would strongly advocate for
> non-blocking version or at least to have a non-blocking option.

Waiting for FD readiness is *already* blocking or non-blocking
according to the caller's desire --- users can pass options they want
to poll(2) or whatever. There's no need for any kind of special
configuration knob or non-blocking option. We already *have* a
non-blocking option that works universally for everything.

As I mentioned in the linked thread, waiting for process exit should
work just like waiting for bytes to appear on a pipe. Process exit
status is just another blob of bytes that a process might receive. A
process exit handle ought to be just another information source. The
reason the unix process API is so awful is that for whatever reason
the original designers treated processes as some kind of special kind
of resource instead of fitting them into the otherwise general-purpose
unix data-handling API. Let's not repeat that mistake.

> Something like this:
>
> evfd = eventfd(0, EFD_NONBLOCK | EFD_CLOEXEC);
> // register eventfd to receive death notification
> pidfd_wait(pid_to_kill, evfd);
> // kill the process
> pidfd_send_signal(pid_to_kill, ...)
> // tend to other things

Now you've lost me. pidfd_wait should return a *new* FD, not wire up
an eventfd.

Why? Because the new type FD can report process exit *status*
information (via read(2) after readability signal) as well as this
binary yes-or-no signal *that* a process exited, and this capability
is useful if you want to the pidfd interface to be a good
general-purpose process management facility to replace the awful
wait() family of functions. You can't get an exit status from an
eventfd. Wiring up an eventfd the way you've proposed also complicates
wait-causality information, complicating both tracing and any priority
inheritance we might want in the future (because all the wakeups gets
mixed into the eventfd and you can't unscramble an egg). And for what?
What do we gain by using an eventfd? Is the reason that exit.c would
be able to use eventfd_signal instead of poking a waitqueue directly?
How is that better? With an eventfd, you've increased path length on
process exit *and* complicated the API for no reason.

> ...
> // wait for the process to die
> poll_wait(evfd, ...);
>
> This simplifies userspace

Not relative to an exit handle it doesn't.

>, allows it to wait for multiple events using
> epoll

So does a process exit status handle.

> and I think kernel implementation will be also quite simple
> because it already implements eventfd_signal() that takes care of
> waitqueue handling.

What if there are multiple eventfds registered for the death of a
process? In any case, you need some mechanism to find, upon process
death, a list of waiters, then wake each of them up. That's either a
global search or a search in some list rooted in a task-related
structure (either struct task or one of its friends). Using an eventfd
here adds nothing, since upon death, you need this list search
regardless, and as I mentioned above, eventfd-wiring just makes the
API worse.

> If pidfd_send_signal could be extended to have an optional eventfd
> parameter then we would not even have to add a new syscall.

There is nothing wrong with adding a new system call. I don't know why
there's this idea circulating that adding system calls is something we
should bend over backwards to avoid. It's cheap, and support-wise,
kernel interface is kernel interface. Sending a signal has *nothing*
to do with wiring up some kind of notification and there's no reason
to mingle it with some kind of event registration.

