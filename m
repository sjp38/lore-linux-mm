Return-Path: <SRS0=9bJk=RU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2FA92C43381
	for <linux-mm@archiver.kernel.org>; Sun, 17 Mar 2019 17:11:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C9DB92082F
	for <linux-mm@archiver.kernel.org>; Sun, 17 Mar 2019 17:11:25 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="rkZweOym"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C9DB92082F
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 653C06B02E7; Sun, 17 Mar 2019 13:11:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 607D36B02E8; Sun, 17 Mar 2019 13:11:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4CEA16B02E9; Sun, 17 Mar 2019 13:11:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f200.google.com (mail-vk1-f200.google.com [209.85.221.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1A5C96B02E7
	for <linux-mm@kvack.org>; Sun, 17 Mar 2019 13:11:25 -0400 (EDT)
Received: by mail-vk1-f200.google.com with SMTP id m71so6375390vkm.10
        for <linux-mm@kvack.org>; Sun, 17 Mar 2019 10:11:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=/GHei1y2w64kC2vY4Gxqo7JmC8aL/bpPnp8L7rr1osY=;
        b=M8MgKaYECb9K93TVk3wVNzFdgMzz1/UFWZdTuiF9KWQlVrY+juUJ9Ps+q4D1/6wL0T
         PDgXzhEkwNmODvG65PhfyqV7kFXHF5SmtlbzojHLJuMUFeB8TuhXR2eJSvu4FLG6i+Yn
         b7fBDzSx3xxW4jxkb1ES2zKYzZUBZyDR75Yavpqe/sTQaL+dTA5f5DXHgAMUcjXlw621
         0SbNH9WfxadVVkMgB0oiQNWA2K0Cb3TKEv1xEyQZP+iHSeO75Ilw+ARzE5QewUM18V3B
         BLOsNEBXb2nxKhWFF289IUyvn99c8VqAcz9TiuWQXf1pv1QbETC7zzyNkbY259p0TG8M
         n6tg==
X-Gm-Message-State: APjAAAVEI8SpHQDffdAvurdmdPRYMcbUM7UFg4lE5gUTj3fU9SN350o0
	2vtIQEjY5B1Dal0c6M2ooI+r5UNQPpC6XfkYPGgZUQxKDcdSPtCNlQVhpud+2ASGVf5g5E3xLX0
	6dRQbcXhNPwBxOm6VirPG4u877xgxfR18iWrIJrecJmqqi0d1r0Q5vuxMQQTP32gI/Q==
X-Received: by 2002:a1f:8306:: with SMTP id f6mr7331157vkd.75.1552842684644;
        Sun, 17 Mar 2019 10:11:24 -0700 (PDT)
X-Received: by 2002:a1f:8306:: with SMTP id f6mr7331117vkd.75.1552842683542;
        Sun, 17 Mar 2019 10:11:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552842683; cv=none;
        d=google.com; s=arc-20160816;
        b=YFMQhBCiGuWqbrYGGItWtwzbm3j5eAUmyEP1t6gu8CBNaplsB+mQwpsO092W3DDBr8
         /inIlVDh2Q54XQ8hOEd8JI5iTX2SKjgIieyj7jrZlI/zbp75VsLRgqQ4BHZ+BjpzsLbA
         HRBfy98wEeDJHitPPgluoF7GTLxuVBCiJHK14VOBT3r5x6UpbJQ1+nQZJIfeiqzDzL4B
         RsJNWDgipX6yezbcrN24oURVv0xFBSImgMY14y6b7x+ayvdxiYba3p2lOQKd+ftb67PK
         +b5U0/vLrqhTw5bA2wSCUJ3e2BweFqiY956ovYHGTCtplcQ3t4By4F5RGShhAHHQ3GJ1
         mRvQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=/GHei1y2w64kC2vY4Gxqo7JmC8aL/bpPnp8L7rr1osY=;
        b=ZPBnjCsZU0NCg6esND6MCsmWGxVB6SyVaFQ2ru3JOZl1VVxNhs/2SZKS2Rud8ah+nB
         nL6Q91LgWZxxak4W3M0XgfnbKPl5ii20zSkj8kQM+8CVUYbzUWfy/Ui154UGwR+p/xSs
         yYwp8jWghxZeohXqJC6hd13fYTZ/U5qHoOmYEF7iFTzuva5UOysn/z6X7283L6SEMxsy
         P1/0PHTjgRFPO+Rx7q6UYTePCG3vcF17ahsR5DMxjY9gTg9/lF2WViUACtWWUQ3KRcFU
         WkEj+comDKZLRmOo3rFOZTSHpfhaaeHFX/eL5GoW0VfzITSaIxDcHl16tY8iEcWsU4nO
         C61w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=rkZweOym;
       spf=pass (google.com: domain of dancol@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dancol@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p36sor2907612uad.7.2019.03.17.10.11.23
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 17 Mar 2019 10:11:23 -0700 (PDT)
Received-SPF: pass (google.com: domain of dancol@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=rkZweOym;
       spf=pass (google.com: domain of dancol@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dancol@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=/GHei1y2w64kC2vY4Gxqo7JmC8aL/bpPnp8L7rr1osY=;
        b=rkZweOymvlwUdQnzKm3Vy45FSMcCCJGnZPBiY4xMOAfziQrQR1yqoNVgEmLqueQn9D
         SL35q9PgjhfveRZ6Wi92yL6/ONBPimu1C8WabapDOIsJ7QfntP++aaOIR24KiGdnZkTE
         Mts6ywa805r8GkrqhLAsWLo9rhwZogL5DBpJhSlDjYrwzuYNL5jyjC3OpPiIV7jQRPUK
         humlZjFH0m98oM7wd6/w8JjzVavMSPreODx2O8I1UhfAmkzARq01/fxvdahxz3H0yy/o
         uFiwlZ5gRoqkh9SpWomqroCVnRVYb8+B+69qpgFbfagAw1mXiVkjmlusp5BHQHrl/y5G
         SQbg==
X-Google-Smtp-Source: APXvYqz1BZn9XUgbLe3WtllYSqgrKDcndr6LRivDAR3H1C4JTTJGUjwY2a7ZGALIQBgQQfLOzYZUaaHdjw4HADmj9Jk=
X-Received: by 2002:ab0:6513:: with SMTP id w19mr4368759uam.19.1552842682541;
 Sun, 17 Mar 2019 10:11:22 -0700 (PDT)
MIME-Version: 1.0
References: <20190315180306.sq3z645p3hygrmt2@brauner.io> <20190315181324.GA248160@google.com>
 <20190315182426.sujcqbzhzw4llmsa@brauner.io> <20190315184903.GB248160@google.com>
 <CAJuCfpGp_9fE9MPGVCWjnTaeBE0K_Q22LS1pBqhp7zW2M=dbGw@mail.gmail.com>
 <CAKOZueuauUXRyrvhzBD0op6W4TAnydSx92bvrPN2VRWERX8iQg@mail.gmail.com>
 <20190316185726.jc53aqq5ph65ojpk@brauner.io> <CAJuCfpF-uYpUZ1RO99i2qEw5Ou4nSimSkiQvnNQ_rv8ogHKRfw@mail.gmail.com>
 <20190317015306.GA167393@google.com> <20190317114238.ab6tvvovpkpozld5@brauner.io>
 <20190317163505.GA9904@mail.hallyn.com>
In-Reply-To: <20190317163505.GA9904@mail.hallyn.com>
From: Daniel Colascione <dancol@google.com>
Date: Sun, 17 Mar 2019 10:11:10 -0700
Message-ID: <CAKOZuet+HCZoOgJBAUrcm8nxC-bQ00W7w+=k2SOh+dfXffMU4w@mail.gmail.com>
Subject: Re: [RFC] simple_lmk: Introduce Simple Low Memory Killer for Android
To: "Serge E. Hallyn" <serge@hallyn.com>
Cc: Christian Brauner <christian@brauner.io>, Joel Fernandes <joel@joelfernandes.org>, 
	Suren Baghdasaryan <surenb@google.com>, Steven Rostedt <rostedt@goodmis.org>, 
	Sultan Alsawaf <sultan@kerneltoast.com>, Tim Murray <timmurray@google.com>, 
	Michal Hocko <mhocko@kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, 
	=?UTF-8?B?QXJ2ZSBIasO4bm5ldsOlZw==?= <arve@android.com>, 
	Todd Kjos <tkjos@android.com>, Martijn Coenen <maco@android.com>, Ingo Molnar <mingo@redhat.com>, 
	Peter Zijlstra <peterz@infradead.org>, LKML <linux-kernel@vger.kernel.org>, 
	"open list:ANDROID DRIVERS" <devel@driverdev.osuosl.org>, linux-mm <linux-mm@kvack.org>, 
	kernel-team <kernel-team@android.com>, Oleg Nesterov <oleg@redhat.com>, 
	Andy Lutomirski <luto@amacapital.net>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Mar 17, 2019 at 9:35 AM Serge E. Hallyn <serge@hallyn.com> wrote:
>
> On Sun, Mar 17, 2019 at 12:42:40PM +0100, Christian Brauner wrote:
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
> > >
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
> >
> > Having pidfd_wait() return another fd will make the syscall harder to
> > swallow for a lot of people I reckon.
> > What exactly prevents us from making the pidfd itself readable/pollable
> > for the exit staus? They are "special" fds anyway. I would really like
> > to avoid polluting the api with multiple different types of fds if possible.
> >
> > ret = pidfd_wait(pidfd);
> > read or poll pidfd
>
> I'm not quite clear on what the two steps are doing here.  Is pidfd_wait()
> doing a waitpid(2), and the read gets exit status info?

pidfd_wait on an open pidfd returns a "wait handle" FD. The wait
handle works just like a pipe: you can select/epoll/whatever for
readability. read(2) on the wait handle (which blocks unless you set
O_NONBLOCK, just like a pipe) completes with a siginfo_t when the
process to which the wait handle is attached exits. Roughly,

int kill_and_wait_for_exit(int pidfd) {
  int wait_handle = pidfd_wait(pidfd);
  pidfd_send_signal(pidfd, ...);
  siginfo_t exit_info;
  read(wait_handle, &exit_info, sizeof(exit_info)); // Blocks because
we haven't configured non-blocking behavior, just like a pipe.
  close(wait_handle);
  return exit_info.si_status;
}

>
> > (Note that I'm traveling so my responses might be delayed quite a bit.)
> > (Ccing a few people that might have an opinion here.)
> >
> > Christian
>
> On its own, what you (Christian) show seems nicer.  But think about a main event
> loop (like in lxc), where we just loop over epoll_wait() on various descriptors.
> If we want to wait for any of several types of events - maybe a signalfd, socket
> traffic, or a process death - it would be nice if we can treat them all the same
> way, without having to setup a separate thread to watch the pidfd and send
> data over another fd.  Is there a nice way we can provide that with what you've
> got above?

Nobody is proposing any kind of mechanism that would require a
separate thread. What I'm proposing works with poll and read and
should be trivial to integrate into any existing event loop: from the
perspective of the event loop, it looks just like a pipe.

