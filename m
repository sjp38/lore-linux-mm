Return-Path: <SRS0=9bJk=RU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_NEOMUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 36769C43381
	for <linux-mm@archiver.kernel.org>; Sun, 17 Mar 2019 11:42:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C864C21019
	for <linux-mm@archiver.kernel.org>; Sun, 17 Mar 2019 11:42:45 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=brauner.io header.i=@brauner.io header.b="ZIPxt6SS"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C864C21019
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=brauner.io
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4AE666B02EB; Sun, 17 Mar 2019 07:42:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 45D236B02EC; Sun, 17 Mar 2019 07:42:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 327B56B02ED; Sun, 17 Mar 2019 07:42:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id CA9DE6B02EB
	for <linux-mm@kvack.org>; Sun, 17 Mar 2019 07:42:44 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id x13so5756226edq.11
        for <linux-mm@kvack.org>; Sun, 17 Mar 2019 04:42:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=YclABiHuTnjl2QFtYMQH4ry+g51OvyNkv8LG/hhb3tI=;
        b=kEEC5vuKItUwjFjFg8/jLDvpj/aEB1P4g4LCK4CJ97yFDKdSWvz5K1geterLGufDUA
         v9awIjzVkkdQ5XGHCMYRU1/HIS7d0VAsdoeHov3bjxH54g8y9RwN0Bg119XO/KsMOPvI
         h0fFbBGQcBbvY/jivokxfDC3Sa+KHzZr546y8MtKxr5l8gYi3BQeUQeX+CIpaKWYKAVB
         MiT5tZD7T3M/OePMCs6EAAM9PLAfQy/xgV7a32HJ1b1Z63ZIcmi+3+GjuescCzqUblfT
         gLfE5Q57XC9XbvbokeTD3AmEG6hZVG7YjyaZij5l/+8qkbRlvT41HUNZExjcFcWtyVan
         fV/A==
X-Gm-Message-State: APjAAAUB8UovZUMNzueqttxvnIz+JsoN7mxhrT0mgoWJTOat3PM4XoIQ
	7r9wW3KHSn6MU1PTAhF6YZkoHZZbwQE1VpzAeF6EzBb9YHOoj3J4BqFwlosBrko1u2NqTuYdHsw
	GjK34+EpBlwBOHUTbQwba6QDJMJ4+B3qCjMnI/DBz1TKlocDPYKdN7KC7i+opDrolCg==
X-Received: by 2002:aa7:d9d2:: with SMTP id v18mr9248646eds.74.1552822964245;
        Sun, 17 Mar 2019 04:42:44 -0700 (PDT)
X-Received: by 2002:aa7:d9d2:: with SMTP id v18mr9248603eds.74.1552822963198;
        Sun, 17 Mar 2019 04:42:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552822963; cv=none;
        d=google.com; s=arc-20160816;
        b=d1VK4gU9W+C7wWH2Sf7a+pwQ8FkRsx4dr84a4a5WcKmaqi3vBn/fBCsOhCJUIOjzDr
         z4RZgZFRduraGhsfvVBgUYh1uR3GYI0JOxZAtoSbfPlfjd4/dGUN0NKOAXZ6nh+2F9cq
         nV8q8Wqx9WzCqCdjWhutfGqgvkkJlRPNRBZuxY9yssVwgrEYicQnXHcSf4/Zd813HMle
         6UYiF5NqFhY5PQM4NICwcYflXV1vQQ26EDMWXSLCFfbz6AhjajGsUet4nxFx8W3vCjT4
         VVx4QHoaMyDsa1Pp/Ad6I9zPx7CS9PqbW5wiS7XdRpKDEGCSalPKTgaC3+rb0cYyozr1
         zF/w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=YclABiHuTnjl2QFtYMQH4ry+g51OvyNkv8LG/hhb3tI=;
        b=pZMg3FpicxHYVHBXd78Ut35iGtufk7Xky0sWLyvtCNspYW9tKAfC6SeVeeevNUPWJu
         qb6lqE0oIhlpBfIDY8J5WUNi2dBF5K07V3ewikvja9u1GWgzWeZFFMUQ6YiMMp1Qj+8s
         z4KcuYU+gGAdfNCy1CTDY2mbCSyw8bP3+m40xzLXrSkmDwoDb0YiT9dZrHpaOANKDAFM
         PwtaqRljBkprD3i9fBs2zMitF+uvLZBtoIDpDnl1iMRBUiLs+nGsQPMSpK5jFOM7HYKq
         c40dcZpNJvjfGn9230Jx045BNV8ULht4/oeAmz8X7RixiDIj23uZXWJKNfypSTd6+vJH
         xAVQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@brauner.io header.s=google header.b=ZIPxt6SS;
       spf=pass (google.com: domain of christian@brauner.io designates 209.85.220.65 as permitted sender) smtp.mailfrom=christian@brauner.io
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w22sor3700537edd.25.2019.03.17.04.42.43
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 17 Mar 2019 04:42:43 -0700 (PDT)
Received-SPF: pass (google.com: domain of christian@brauner.io designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@brauner.io header.s=google header.b=ZIPxt6SS;
       spf=pass (google.com: domain of christian@brauner.io designates 209.85.220.65 as permitted sender) smtp.mailfrom=christian@brauner.io
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=brauner.io; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=YclABiHuTnjl2QFtYMQH4ry+g51OvyNkv8LG/hhb3tI=;
        b=ZIPxt6SSVDiLulatoUNz98X0CNjmV6Ds1efoD235rftaX8w9b8tnnJtqLeyz1SIuvQ
         ptGQj1RMfH6DURu3CFIqpVPXkPk6p3KuICtI+xBq5XfRL4bpvDmhiKnNpPzrEAdgGvRH
         2QAOKkzJ0wpuznKaC2e46KtXSIOAC5FGZWxOI7CiamsYQGiIaLq6bcUbSmSBXXWopv+e
         +GguqJieiTV5nluiBbBO1OSlwqc1fLYxDOFrOe1sXeThfdrviamX3JAuMoAV7gCE9qV4
         t/NW0sxVP8lo5XBfaMxz4+n4nhrOfC29AWyU1xJHGqY3EQ5bkS/EDjHB/6tI63ILC2Er
         CD2Q==
X-Google-Smtp-Source: APXvYqxdkEJ/In5R0Lt1K65CD08NBBRFEvd7oogj0quACTIgt8R00GztjQkANsFFKxP0iu5gJ/QsAA==
X-Received: by 2002:aa7:db04:: with SMTP id t4mr9116387eds.173.1552822962825;
        Sun, 17 Mar 2019 04:42:42 -0700 (PDT)
Received: from brauner.io ([88.128.80.37])
        by smtp.gmail.com with ESMTPSA id n10sm1713459ejl.22.2019.03.17.04.42.41
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Sun, 17 Mar 2019 04:42:42 -0700 (PDT)
Date: Sun, 17 Mar 2019 12:42:40 +0100
From: Christian Brauner <christian@brauner.io>
To: Joel Fernandes <joel@joelfernandes.org>
Cc: Suren Baghdasaryan <surenb@google.com>,
	Daniel Colascione <dancol@google.com>,
	Steven Rostedt <rostedt@goodmis.org>,
	Sultan Alsawaf <sultan@kerneltoast.com>,
	Tim Murray <timmurray@google.com>, Michal Hocko <mhocko@kernel.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Arve =?utf-8?B?SGrDuG5uZXbDpWc=?= <arve@android.com>,
	Todd Kjos <tkjos@android.com>, Martijn Coenen <maco@android.com>,
	Ingo Molnar <mingo@redhat.com>,
	Peter Zijlstra <peterz@infradead.org>,
	LKML <linux-kernel@vger.kernel.org>,
	"open list:ANDROID DRIVERS" <devel@driverdev.osuosl.org>,
	linux-mm <linux-mm@kvack.org>,
	kernel-team <kernel-team@android.com>, oleg@redhat.com,
	luto@amacapital.net, serge@hallyn.com
Subject: Re: [RFC] simple_lmk: Introduce Simple Low Memory Killer for Android
Message-ID: <20190317114238.ab6tvvovpkpozld5@brauner.io>
References: <CAKOZuetZHJzmQy3n001x4+rmWoWHEgUv2Zvow9W5+xvukxp1JQ@mail.gmail.com>
 <20190315180306.sq3z645p3hygrmt2@brauner.io>
 <20190315181324.GA248160@google.com>
 <20190315182426.sujcqbzhzw4llmsa@brauner.io>
 <20190315184903.GB248160@google.com>
 <CAJuCfpGp_9fE9MPGVCWjnTaeBE0K_Q22LS1pBqhp7zW2M=dbGw@mail.gmail.com>
 <CAKOZueuauUXRyrvhzBD0op6W4TAnydSx92bvrPN2VRWERX8iQg@mail.gmail.com>
 <20190316185726.jc53aqq5ph65ojpk@brauner.io>
 <CAJuCfpF-uYpUZ1RO99i2qEw5Ou4nSimSkiQvnNQ_rv8ogHKRfw@mail.gmail.com>
 <20190317015306.GA167393@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20190317015306.GA167393@google.com>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Mar 16, 2019 at 09:53:06PM -0400, Joel Fernandes wrote:
> On Sat, Mar 16, 2019 at 12:37:18PM -0700, Suren Baghdasaryan wrote:
> > On Sat, Mar 16, 2019 at 11:57 AM Christian Brauner <christian@brauner.io> wrote:
> > >
> > > On Sat, Mar 16, 2019 at 11:00:10AM -0700, Daniel Colascione wrote:
> > > > On Sat, Mar 16, 2019 at 10:31 AM Suren Baghdasaryan <surenb@google.com> wrote:
> > > > >
> > > > > On Fri, Mar 15, 2019 at 11:49 AM Joel Fernandes <joel@joelfernandes.org> wrote:
> > > > > >
> > > > > > On Fri, Mar 15, 2019 at 07:24:28PM +0100, Christian Brauner wrote:
> > > > > > [..]
> > > > > > > > why do we want to add a new syscall (pidfd_wait) though? Why not just use
> > > > > > > > standard poll/epoll interface on the proc fd like Daniel was suggesting.
> > > > > > > > AFAIK, once the proc file is opened, the struct pid is essentially pinned
> > > > > > > > even though the proc number may be reused. Then the caller can just poll.
> > > > > > > > We can add a waitqueue to struct pid, and wake up any waiters on process
> > > > > > > > death (A quick look shows task_struct can be mapped to its struct pid) and
> > > > > > > > also possibly optimize it using Steve's TIF flag idea. No new syscall is
> > > > > > > > needed then, let me know if I missed something?
> > > > > > >
> > > > > > > Huh, I thought that Daniel was against the poll/epoll solution?
> > > > > >
> > > > > > Hmm, going through earlier threads, I believe so now. Here was Daniel's
> > > > > > reasoning about avoiding a notification about process death through proc
> > > > > > directory fd: http://lkml.iu.edu/hypermail/linux/kernel/1811.0/00232.html
> > > > > >
> > > > > > May be a dedicated syscall for this would be cleaner after all.
> > > > >
> > > > > Ah, I wish I've seen that discussion before...
> > > > > syscall makes sense and it can be non-blocking and we can use
> > > > > select/poll/epoll if we use eventfd.
> > > >
> > > > Thanks for taking a look.
> > > >
> > > > > I would strongly advocate for
> > > > > non-blocking version or at least to have a non-blocking option.
> > > >
> > > > Waiting for FD readiness is *already* blocking or non-blocking
> > > > according to the caller's desire --- users can pass options they want
> > > > to poll(2) or whatever. There's no need for any kind of special
> > > > configuration knob or non-blocking option. We already *have* a
> > > > non-blocking option that works universally for everything.
> > > >
> > > > As I mentioned in the linked thread, waiting for process exit should
> > > > work just like waiting for bytes to appear on a pipe. Process exit
> > > > status is just another blob of bytes that a process might receive. A
> > > > process exit handle ought to be just another information source. The
> > > > reason the unix process API is so awful is that for whatever reason
> > > > the original designers treated processes as some kind of special kind
> > > > of resource instead of fitting them into the otherwise general-purpose
> > > > unix data-handling API. Let's not repeat that mistake.
> > > >
> > > > > Something like this:
> > > > >
> > > > > evfd = eventfd(0, EFD_NONBLOCK | EFD_CLOEXEC);
> > > > > // register eventfd to receive death notification
> > > > > pidfd_wait(pid_to_kill, evfd);
> > > > > // kill the process
> > > > > pidfd_send_signal(pid_to_kill, ...)
> > > > > // tend to other things
> > > >
> > > > Now you've lost me. pidfd_wait should return a *new* FD, not wire up
> > > > an eventfd.
> > > >
> > 
> > Ok, I probably misunderstood your post linked by Joel. I though your
> > original proposal was based on being able to poll a file under
> > /proc/pid and then you changed your mind to have a separate syscall
> > which I assumed would be a blocking one to wait for process exit.
> > Maybe you can describe the new interface you are thinking about in
> > terms of userspace usage like I did above? Several lines of code would
> > explain more than paragraphs of text.
> 
> Hey, Thanks Suren for the eventfd idea. I agree with Daniel on this. The idea
> from Daniel here is to wait for process death and exit events by just
> referring to a stable fd, independent of whatever is going on in /proc.
> 
> What is needed is something like this (in highly pseudo-code form):
> 
> pidfd = opendir("/proc/<pid>",..);
> wait_fd = pidfd_wait(pidfd);
> read or poll wait_fd (non-blocking or blocking whichever)
> 
> wait_fd will block until the task has either died or reaped. In both these
> cases, it can return a suitable string such as "dead" or "reaped" although an
> integer with some predefined meaning is also Ok.
> 
> What that guarantees is, even if the task's PID has been reused, or the task
> has already died or already died + reaped, all of these events cannot race
> with the code above and the information passed to the user is race-free and
> stable / guaranteed.
> 
> An eventfd seems to not fit well, because AFAICS passing the raw PID to
> eventfd as in your example would still race since the PID could have been
> reused by another process by the time the eventfd is created.
> 
> Also Andy's idea in [1] seems to use poll flags to communicate various tihngs
> which is still not as explicit about the PID's status so that's a poor API
> choice compared to the explicit syscall.
> 
> I am planning to work on a prototype patch based on Daniel's idea and post something
> soon (chatted with Daniel about it and will reference him in the posting as
> well), during this posting I will also summarize all the previous discussions
> and come up with some tests as well.  I hope to have something soon.

Having pidfd_wait() return another fd will make the syscall harder to
swallow for a lot of people I reckon.
What exactly prevents us from making the pidfd itself readable/pollable
for the exit staus? They are "special" fds anyway. I would really like
to avoid polluting the api with multiple different types of fds if possible.

ret = pidfd_wait(pidfd);
read or poll pidfd
(Note that I'm traveling so my responses might be delayed quite a bit.)
(Ccing a few people that might have an opinion here.)

Christian

