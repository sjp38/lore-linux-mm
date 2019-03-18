Return-Path: <SRS0=xdO8=RV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_NEOMUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3D425C43381
	for <linux-mm@archiver.kernel.org>; Mon, 18 Mar 2019 00:30:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D72F520854
	for <linux-mm@archiver.kernel.org>; Mon, 18 Mar 2019 00:30:02 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=brauner.io header.i=@brauner.io header.b="dIFIuKin"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D72F520854
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=brauner.io
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 66D696B0003; Sun, 17 Mar 2019 20:30:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 61DAD6B0006; Sun, 17 Mar 2019 20:30:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4E4AE6B0007; Sun, 17 Mar 2019 20:30:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f198.google.com (mail-it1-f198.google.com [209.85.166.198])
	by kanga.kvack.org (Postfix) with ESMTP id 272666B0003
	for <linux-mm@kvack.org>; Sun, 17 Mar 2019 20:30:02 -0400 (EDT)
Received: by mail-it1-f198.google.com with SMTP id q192so13311699itb.9
        for <linux-mm@kvack.org>; Sun, 17 Mar 2019 17:30:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=UKOWX6nRrEJIRPW41Nd5NVckoQAF65pq89yg8IuyZtw=;
        b=fxujKJAaaOv809pw0uzD/ZDNWfU5TaZbwDdnOoaQmlwvevE6ldV/1nAvFO348/h8k7
         A3JHHLpSst8inkHUfkIc8XPZAOGok4mAMLwslStutwE2MtH72V/ElKkyuGVoFgB/9/MI
         +j0IokGxsHABW2Tjv6bdbJBVnzS6lx36x/qjQ0ynGyy/mkop9MuJV9wRdG3JfI5n+RcO
         zI8lPb2URyVB43K8XowIYOUCM1eh8LWoMv6gkNs8uRF8cU12VNqokcqV75ceb5IQOq6x
         wWYE9gQq1IIJux7YmgI0EWktx70tQGldkoaZbppZB0PPUEG1Z9PClOP4eQ+g3p7YIIoy
         O2PQ==
X-Gm-Message-State: APjAAAWRRqJEd9RyaOGj/aVVFZ7kSgcCBk//z1XVbqnfH6wwYNLahKvk
	Ehd6W0cib+aSU6hbHcGxrUepDb4Pge57+OtUJPpokd69BfiDTSS6cArJHO8jPJpyh5uLYAfEVqR
	rGseoVEDkxE7gDPPOB/abRwdjlwzQeF4rjbKj+POoEijrM2TJQFJRqABNi2QLQPSoQw==
X-Received: by 2002:a24:1452:: with SMTP id 79mr8965322itg.90.1552869001833;
        Sun, 17 Mar 2019 17:30:01 -0700 (PDT)
X-Received: by 2002:a24:1452:: with SMTP id 79mr8965293itg.90.1552869000682;
        Sun, 17 Mar 2019 17:30:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552869000; cv=none;
        d=google.com; s=arc-20160816;
        b=D276BurClWinkYxQpTrNCWU5D8ZLPCtr6D8ELcTDpwzk2uhu+VneYenM/eFQ8U9tsx
         crSagLbHn4XkeTN3YnFJczHlsJN/bS/bIb9Hp9v6PEl7qIQd2BOskwNCTebn1n7HDl9f
         hSWqIl2ZUcseRqmGKa93lXydtq5XTl3AaIXhHr1sAk/jkJzNdwvoJevxXSh4e9E4Bjzo
         INmJkOoOYBXUTAJVpHzMGsD8QIP84CzmsOp1TavJoryKcHjTn120lEpEkAxa2/FCJtmE
         5gtOreuomxGVo9yoT5goIdl7ptUDmUexF7t+pyJWFDmXNQUWyD/PfrVJLK5X8/8+VEWX
         ijpw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=UKOWX6nRrEJIRPW41Nd5NVckoQAF65pq89yg8IuyZtw=;
        b=fupsAnpSUyvBFG/XXaV+LMU0EFJvdJwkDTPHAs+lugwOF1Z29u3Zb723sxh++mRDkt
         hvyqkyJo+1sRNa3JbvU7pFOjegMSxow9SZYUrvGTyoW6unV/7R7i5upADXoDKYisBYSQ
         mJ4CSKhnz9Bc2pPdlYIcwLEM8wErEnk2ZzkoFkvppiVhsgvUQPR1bOkY00NDidZIMBZS
         P3mxYu2YT4HrppVN8zjK2tDqUyT857QZUJTKaZgQCuvGpExHakqvL1tX9+p0sPOq61oq
         5oAbVHa1VhIBbo8PpVm1vJOa9jW0iyQRun3WOMwYUKWvQsvEZD7/i26ITGb7c6Gp5V+P
         +HKg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@brauner.io header.s=google header.b=dIFIuKin;
       spf=pass (google.com: domain of christian@brauner.io designates 209.85.220.65 as permitted sender) smtp.mailfrom=christian@brauner.io
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f190sor14336087itc.14.2019.03.17.17.30.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 17 Mar 2019 17:30:00 -0700 (PDT)
Received-SPF: pass (google.com: domain of christian@brauner.io designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@brauner.io header.s=google header.b=dIFIuKin;
       spf=pass (google.com: domain of christian@brauner.io designates 209.85.220.65 as permitted sender) smtp.mailfrom=christian@brauner.io
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=brauner.io; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=UKOWX6nRrEJIRPW41Nd5NVckoQAF65pq89yg8IuyZtw=;
        b=dIFIuKin1hbg1PW6Uyq63NtDCUPKhr/f6WT93VBHjSgxjn+WY5O6pCBOnwPCFg5LfH
         RM/khLaSyP72FrJFUYtpVnCUW49NVQsK6WjcRr552l1Z1Xh/oI7o/92EzeqL6waxjzWl
         WaKTQXIqhPG98TmArP2wFH7pewlmgIRnO+2VFQAOdTQrUDzuKaT0VcwbDgSqCIkvk6sa
         UZ6uK5pZVHb7TSnJ9/P5A+96v9HXvzqv7uwSpFU/P2e7HvEF8wz2b1M0m5mp8W0m+1Ma
         jDXM4JEHaYvcQdjkxjDuo+HCXXI5UvFrhYYgyEykafCszC7YwaArsOMxU+l2tr3G6ccK
         WPwQ==
X-Google-Smtp-Source: APXvYqw1ATgdE4JfBQBeM/TAuPU5ixqMrl+ubrhB8/g/1HqxNuvwNlNNL7FFKEct7dheB6UdAJeFRg==
X-Received: by 2002:a24:d14:: with SMTP id 20mr1085045itx.0.1552868999848;
        Sun, 17 Mar 2019 17:29:59 -0700 (PDT)
Received: from brauner.io ([67.133.97.99])
        by smtp.gmail.com with ESMTPSA id y18sm3308253ioa.56.2019.03.17.17.29.57
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Sun, 17 Mar 2019 17:29:59 -0700 (PDT)
Date: Mon, 18 Mar 2019 01:29:51 +0100
From: Christian Brauner <christian@brauner.io>
To: Daniel Colascione <dancol@google.com>
Cc: Joel Fernandes <joel@joelfernandes.org>,
	Suren Baghdasaryan <surenb@google.com>,
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
	kernel-team <kernel-team@android.com>,
	Oleg Nesterov <oleg@redhat.com>,
	Andy Lutomirski <luto@amacapital.net>,
	"Serge E. Hallyn" <serge@hallyn.com>
Subject: Re: [RFC] simple_lmk: Introduce Simple Low Memory Killer for Android
Message-ID: <20190318002949.mqknisgt7cmjmt7n@brauner.io>
References: <20190315181324.GA248160@google.com>
 <20190315182426.sujcqbzhzw4llmsa@brauner.io>
 <20190315184903.GB248160@google.com>
 <CAJuCfpGp_9fE9MPGVCWjnTaeBE0K_Q22LS1pBqhp7zW2M=dbGw@mail.gmail.com>
 <CAKOZueuauUXRyrvhzBD0op6W4TAnydSx92bvrPN2VRWERX8iQg@mail.gmail.com>
 <20190316185726.jc53aqq5ph65ojpk@brauner.io>
 <CAJuCfpF-uYpUZ1RO99i2qEw5Ou4nSimSkiQvnNQ_rv8ogHKRfw@mail.gmail.com>
 <20190317015306.GA167393@google.com>
 <20190317114238.ab6tvvovpkpozld5@brauner.io>
 <CAKOZuetZPhqQqSgZpyY0cLgy0jroLJRx-B93rkQzcOByL8ih_Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <CAKOZuetZPhqQqSgZpyY0cLgy0jroLJRx-B93rkQzcOByL8ih_Q@mail.gmail.com>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Mar 17, 2019 at 08:40:19AM -0700, Daniel Colascione wrote:
> On Sun, Mar 17, 2019 at 4:42 AM Christian Brauner <christian@brauner.io> wrote:
> >
> > On Sat, Mar 16, 2019 at 09:53:06PM -0400, Joel Fernandes wrote:
> > > On Sat, Mar 16, 2019 at 12:37:18PM -0700, Suren Baghdasaryan wrote:
> > > > On Sat, Mar 16, 2019 at 11:57 AM Christian Brauner <christian@brauner.io> wrote:
> > > > >
> > > > > On Sat, Mar 16, 2019 at 11:00:10AM -0700, Daniel Colascione wrote:
> > > > > > On Sat, Mar 16, 2019 at 10:31 AM Suren Baghdasaryan <surenb@google.com> wrote:
> > > > > > >
> > > > > > > On Fri, Mar 15, 2019 at 11:49 AM Joel Fernandes <joel@joelfernandes.org> wrote:
> > > > > > > >
> > > > > > > > On Fri, Mar 15, 2019 at 07:24:28PM +0100, Christian Brauner wrote:
> > > > > > > > [..]
> > > > > > > > > > why do we want to add a new syscall (pidfd_wait) though? Why not just use
> > > > > > > > > > standard poll/epoll interface on the proc fd like Daniel was suggesting.
> > > > > > > > > > AFAIK, once the proc file is opened, the struct pid is essentially pinned
> > > > > > > > > > even though the proc number may be reused. Then the caller can just poll.
> > > > > > > > > > We can add a waitqueue to struct pid, and wake up any waiters on process
> > > > > > > > > > death (A quick look shows task_struct can be mapped to its struct pid) and
> > > > > > > > > > also possibly optimize it using Steve's TIF flag idea. No new syscall is
> > > > > > > > > > needed then, let me know if I missed something?
> > > > > > > > >
> > > > > > > > > Huh, I thought that Daniel was against the poll/epoll solution?
> > > > > > > >
> > > > > > > > Hmm, going through earlier threads, I believe so now. Here was Daniel's
> > > > > > > > reasoning about avoiding a notification about process death through proc
> > > > > > > > directory fd: http://lkml.iu.edu/hypermail/linux/kernel/1811.0/00232.html
> > > > > > > >
> > > > > > > > May be a dedicated syscall for this would be cleaner after all.
> > > > > > >
> > > > > > > Ah, I wish I've seen that discussion before...
> > > > > > > syscall makes sense and it can be non-blocking and we can use
> > > > > > > select/poll/epoll if we use eventfd.
> > > > > >
> > > > > > Thanks for taking a look.
> > > > > >
> > > > > > > I would strongly advocate for
> > > > > > > non-blocking version or at least to have a non-blocking option.
> > > > > >
> > > > > > Waiting for FD readiness is *already* blocking or non-blocking
> > > > > > according to the caller's desire --- users can pass options they want
> > > > > > to poll(2) or whatever. There's no need for any kind of special
> > > > > > configuration knob or non-blocking option. We already *have* a
> > > > > > non-blocking option that works universally for everything.
> > > > > >
> > > > > > As I mentioned in the linked thread, waiting for process exit should
> > > > > > work just like waiting for bytes to appear on a pipe. Process exit
> > > > > > status is just another blob of bytes that a process might receive. A
> > > > > > process exit handle ought to be just another information source. The
> > > > > > reason the unix process API is so awful is that for whatever reason
> > > > > > the original designers treated processes as some kind of special kind
> > > > > > of resource instead of fitting them into the otherwise general-purpose
> > > > > > unix data-handling API. Let's not repeat that mistake.
> > > > > >
> > > > > > > Something like this:
> > > > > > >
> > > > > > > evfd = eventfd(0, EFD_NONBLOCK | EFD_CLOEXEC);
> > > > > > > // register eventfd to receive death notification
> > > > > > > pidfd_wait(pid_to_kill, evfd);
> > > > > > > // kill the process
> > > > > > > pidfd_send_signal(pid_to_kill, ...)
> > > > > > > // tend to other things
> > > > > >
> > > > > > Now you've lost me. pidfd_wait should return a *new* FD, not wire up
> > > > > > an eventfd.
> > > > > >
> > > >
> > > > Ok, I probably misunderstood your post linked by Joel. I though your
> > > > original proposal was based on being able to poll a file under
> > > > /proc/pid and then you changed your mind to have a separate syscall
> > > > which I assumed would be a blocking one to wait for process exit.
> > > > Maybe you can describe the new interface you are thinking about in
> > > > terms of userspace usage like I did above? Several lines of code would
> > > > explain more than paragraphs of text.
> > >
> > > Hey, Thanks Suren for the eventfd idea. I agree with Daniel on this. The idea
> > > from Daniel here is to wait for process death and exit events by just
> > > referring to a stable fd, independent of whatever is going on in /proc.
> > >
> > > What is needed is something like this (in highly pseudo-code form):
> > >
> > > pidfd = opendir("/proc/<pid>",..);
> > > wait_fd = pidfd_wait(pidfd);
> > > read or poll wait_fd (non-blocking or blocking whichever)
> > >
> > > wait_fd will block until the task has either died or reaped. In both these
> > > cases, it can return a suitable string such as "dead" or "reaped" although an
> > > integer with some predefined meaning is also Ok.
> 
> I want to return a siginfo_t: we already use this structure in other
> contexts to report exit status.
> 
> > > What that guarantees is, even if the task's PID has been reused, or the task
> > > has already died or already died + reaped, all of these events cannot race
> > > with the code above and the information passed to the user is race-free and
> > > stable / guaranteed.
> > >
> > > An eventfd seems to not fit well, because AFAICS passing the raw PID to
> > > eventfd as in your example would still race since the PID could have been
> > > reused by another process by the time the eventfd is created.
> > >
> > > Also Andy's idea in [1] seems to use poll flags to communicate various tihngs
> > > which is still not as explicit about the PID's status so that's a poor API
> > > choice compared to the explicit syscall.
> > >
> > > I am planning to work on a prototype patch based on Daniel's idea and post something
> > > soon (chatted with Daniel about it and will reference him in the posting as
> > > well), during this posting I will also summarize all the previous discussions
> > > and come up with some tests as well.  I hope to have something soon.
> 
> Thanks.
> 
> > Having pidfd_wait() return another fd will make the syscall harder to
> > swallow for a lot of people I reckon.
> > What exactly prevents us from making the pidfd itself readable/pollable
> > for the exit staus? They are "special" fds anyway. I would really like
> > to avoid polluting the api with multiple different types of fds if possible.
> 
> If pidfds had been their own file type, I'd agree with you. But pidfds
> are directories, which means that we're beholden to make them behave
> like directories normally do. I'd rather introduce another FD than
> heavily overload the semantics of a directory FD in one particular
> context. In no other circumstances are directory FDs also weird
> IO-data sources. Our providing a facility to get a new FD to which we
> *can* give pipe-like behavior does no harm and *usage* cleaner and
> easier to reason about.

I have two things I'm currently working on:
- hijacking translate_pid()
- pidfd_clone() essentially

My first goal is to talk to Eric about taking the translate_pid()
syscall that has been sitting in his tree and expanding it.
translate_pid() currently allows you to either get an fd for the pid
namespace a pid resides in or the pid number of a given process in
another pid namespace relative to a passed in pid namespace fd. I would
like to make it possible for this syscall to also give us back pidfds.
One question I'm currently struggling with is exactly what you said
above: what type of file descriptor these are going to give back to us.
It seems that a regular file instead of directory would make the most
sense and would lead to a nicer API and I'm very much leaning towards
that.

Christian

