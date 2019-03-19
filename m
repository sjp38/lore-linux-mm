Return-Path: <SRS0=zC3H=RW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_NEOMUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D69B7C43381
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 23:10:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7B6582175B
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 23:10:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=brauner.io header.i=@brauner.io header.b="M+ReO8ag"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7B6582175B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=brauner.io
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1216C6B0003; Tue, 19 Mar 2019 19:10:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0D2E06B0006; Tue, 19 Mar 2019 19:10:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F2AD16B0007; Tue, 19 Mar 2019 19:10:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id CF0056B0003
	for <linux-mm@kvack.org>; Tue, 19 Mar 2019 19:10:29 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id x18so19064930qkf.8
        for <linux-mm@kvack.org>; Tue, 19 Mar 2019 16:10:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=6FWypQkapP8gnmtBtLQAKuuE6zk0IbVIm8LRbFhdYXc=;
        b=mBc3LdjqP3nIn4xiZqxszjv9LQf/Em63IOxh2SaWnTH2tJ+gfoZlB4TqOBAKJ3vjDo
         y+hLVAs9u1oKiJXD7pfRXDLVO6hGWAMQB6bYxCb1yJ9jaYqaotSP/G6amTJqHIdbz/JZ
         E70xI/LCnvHemDNG06Klfyn5DPleUapu99JeQ5UD6SG+zvoehguhI4mCHNRNSby7R6Q0
         k0g0tmPBekvFFLgGlWZam7YkG0+xPeTRsE5YIWFzYsV08Lu1kjfGPmKWJbrXJTjA2K0L
         5ojNQhwZ4UD+lTYNp0SnWqr8EDwdGI1TpAdzi2dn7L/mNXZkgGoMDiL8c7s9AW/aIBOt
         9mlA==
X-Gm-Message-State: APjAAAVml6H36A1YvcU1KE+QKNxT4cVzhHGMguA6NsQ5B89IR+XO4cQ5
	T7vk/tuRakGUHhnhtkjlBBQ+PTUryDP+gM/WJMrDlzi2xafS4jsWzayifIBxy2a36hoXUfPkfEu
	/QdN/hOAKk1AZhzmBKVB/sViAkOvyuSlN7mtbJo28zMq1pgW0+kzVhe1NlvJpi+XpNA==
X-Received: by 2002:ac8:263d:: with SMTP id u58mr4183346qtu.295.1553037029505;
        Tue, 19 Mar 2019 16:10:29 -0700 (PDT)
X-Received: by 2002:ac8:263d:: with SMTP id u58mr4183282qtu.295.1553037028429;
        Tue, 19 Mar 2019 16:10:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553037028; cv=none;
        d=google.com; s=arc-20160816;
        b=w8in3XvXy9kwU+PSgIa7J4R4KyFfzW8dPJnZoJ5UwV/ywS9fICjBbA7hYsKsMOCbip
         KW51MAAiPoUMn0eQFI1qZd0DWlk7xXhTQCglVddkGwyKb1EXsFxPWonNfcmt2ZS3fNM9
         Mbv0sPOQHFSId+vP1g9G43Rq6NU0LwYuUpcoxEcWQPxgwr3xJ7AswkZmArJo1t+1WCpG
         4h0A4MMUCAtv0tg1aeLS0kEJu+1LZ4WQoUYbpULF49cPEF9n++aGMC/RHIua1/u1Ucnx
         pcMCMeVJD3CU/eo/myHRk3E3JINsfZ6iHAsj/9vboBsrBEGsi9MDKhnAgGLkj6qJG0n2
         3pSQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=6FWypQkapP8gnmtBtLQAKuuE6zk0IbVIm8LRbFhdYXc=;
        b=dqign5YUVQrTbPBFyp/SxTm5aSwVb5rBq1kBiZsi2WeaClvyxDQ5NFdWjCo0uOwDos
         aDSJWJadHtrVQLge3E5QMWAGJ/ZnZGNgdBHedWoct7EQn96/gWtdxFErJUALOCfUIwae
         b4/8g3qbBeVfJVopwRlCLq6AWRUnqtxv0WOttMWYHHfYn2XCqBAzBbKZERQUH7eoEbnj
         9OI6wvXDhCmSeEtRg/nZ9tSNnuKGiXUQWkN+L+O3esVEilJiVU0DVn9vlg9q9Lt+4vyn
         kHpVAoNW2moASTxDr1hz0eZViE15e7gq7LcKA2riUmXxgBZD3r+lW5/a64l57P3gDDRT
         D/UA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@brauner.io header.s=google header.b=M+ReO8ag;
       spf=pass (google.com: domain of christian@brauner.io designates 209.85.220.65 as permitted sender) smtp.mailfrom=christian@brauner.io
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f12sor695182qte.43.2019.03.19.16.10.28
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 19 Mar 2019 16:10:28 -0700 (PDT)
Received-SPF: pass (google.com: domain of christian@brauner.io designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@brauner.io header.s=google header.b=M+ReO8ag;
       spf=pass (google.com: domain of christian@brauner.io designates 209.85.220.65 as permitted sender) smtp.mailfrom=christian@brauner.io
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=brauner.io; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=6FWypQkapP8gnmtBtLQAKuuE6zk0IbVIm8LRbFhdYXc=;
        b=M+ReO8agDfxcUZE1BC6jIroXPpA/3rFDw7WL2eBF6QPi8+fe4q1yfE3cc0ZNNln0tP
         3Dutwt74X0Mb9BEPu7GbrMZZWOuKVdH78KU+HAbkslsG02wo4iK6ObbXFZIoJvse5hPt
         +mNSLNRsZHvFLQ4ytrymOevkVA91aSIXV02lVyagkwxkXhUuYamp7vkRAOrO2Z+riYjx
         7iDcO0ceMht3+Sfv53hEyNRAiX3hMmxRqjcgVLTi/UdEAQ7Fpt8Na61DjVKqaRKcg0ZT
         c6uHvd7we28+D1ALMCmPsoULQb1zPqsGc8VZi23DjfCjNIdsYvHONVsI2or/qGNiNMh1
         BQEw==
X-Google-Smtp-Source: APXvYqxwNsa8SsSdl8LqERXal6FHQWmFo7gdTiOZy3amFeU+WySgqgoRQgKFw4lJtMZx/FhDpN1fcQ==
X-Received: by 2002:ac8:2850:: with SMTP id 16mr4256446qtr.84.1553037028006;
        Tue, 19 Mar 2019 16:10:28 -0700 (PDT)
Received: from brauner.io ([38.127.230.10])
        by smtp.gmail.com with ESMTPSA id j10sm59557qth.14.2019.03.19.16.10.24
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 19 Mar 2019 16:10:27 -0700 (PDT)
Date: Wed, 20 Mar 2019 00:10:23 +0100
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
	"Serge E. Hallyn" <serge@hallyn.com>,
	Kees Cook <keescook@chromium.org>
Subject: Re: [RFC] simple_lmk: Introduce Simple Low Memory Killer for Android
Message-ID: <20190319231020.tdcttojlbmx57gke@brauner.io>
References: <CAKOZueuauUXRyrvhzBD0op6W4TAnydSx92bvrPN2VRWERX8iQg@mail.gmail.com>
 <20190316185726.jc53aqq5ph65ojpk@brauner.io>
 <CAJuCfpF-uYpUZ1RO99i2qEw5Ou4nSimSkiQvnNQ_rv8ogHKRfw@mail.gmail.com>
 <20190317015306.GA167393@google.com>
 <20190317114238.ab6tvvovpkpozld5@brauner.io>
 <CAKOZuetZPhqQqSgZpyY0cLgy0jroLJRx-B93rkQzcOByL8ih_Q@mail.gmail.com>
 <20190318002949.mqknisgt7cmjmt7n@brauner.io>
 <20190318235052.GA65315@google.com>
 <20190319221415.baov7x6zoz7hvsno@brauner.io>
 <CAKOZuessqcjrZ4rfGLgrnOhrLnsVYiVJzOj4Aa=o3ZuZ013d0g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <CAKOZuessqcjrZ4rfGLgrnOhrLnsVYiVJzOj4Aa=o3ZuZ013d0g@mail.gmail.com>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 19, 2019 at 03:48:32PM -0700, Daniel Colascione wrote:
> On Tue, Mar 19, 2019 at 3:14 PM Christian Brauner <christian@brauner.io> wrote:
> > So I dislike the idea of allocating new inodes from the procfs super
> > block. I would like to avoid pinning the whole pidfd concept exclusively
> > to proc. The idea is that the pidfd API will be useable through procfs
> > via open("/proc/<pid>") because that is what users expect and really
> > wanted to have for a long time. So it makes sense to have this working.
> > But it should really be useable without it. That's why translate_pid()
> > and pidfd_clone() are on the table.  What I'm saying is, once the pidfd
> > api is "complete" you should be able to set CONFIG_PROCFS=N - even
> > though that's crazy - and still be able to use pidfds. This is also a
> > point akpm asked about when I did the pidfd_send_signal work.
> 
> I agree that you shouldn't need CONFIG_PROCFS=Y to use pidfds. One
> crazy idea that I was discussing with Joel the other day is to just
> make CONFIG_PROCFS=Y mandatory and provide a new get_procfs_root()
> system call that returned, out of thin air and independent of the
> mount table, a procfs root directory file descriptor for the caller's
> PID namspace and suitable for use with openat(2).

Even if this works I'm pretty sure that Al and a lot of others will not
be happy about this. A syscall to get an fd to /proc? That's not going
to happen and I don't see the need for a separate syscall just for that.
(I do see the point of making CONFIG_PROCFS=y the default btw.)

Inode allocation from the procfs mount for the file descriptors Joel
wants is not correct. Their not really procfs file descriptors so this
is a nack. We can't just hook into proc that way.

> 
> C'mon: /proc is used by everyone today and almost every program breaks
> if it's not around. The string "/proc" is already de facto kernel ABI.
> Let's just drop the pretense of /proc being optional and bake it into
> the kernel proper, then give programs a way to get to /proc that isn't
> tied to any particular mount configuration. This way, we don't need a
> translate_pid(), since callers can just use procfs to do the same
> thing. (That is, if I understand correctly what translate_pid does.)

I'm not sure what you think translate_pid() is doing since you're not
saying what you think it does.
Examples from the old patchset:
translate_pid(pid, ns, -1)      - get pid in our pid namespace
translate_pid(pid, -1, ns)      - get pid in other pid namespace
translate_pid(1, ns, -1)        - get pid of init task for namespace
translate_pid(pid, -1, ns) > 0  - is pid is reachable from ns?
translate_pid(1, ns1, ns2) > 0  - is ns1 inside ns2?
translate_pid(1, ns1, ns2) == 0 - is ns1 outside ns2?
translate_pid(1, ns1, ns2) == 1 - is ns1 equal ns2?

Allowing this syscall to yield pidfds as proper regular file fds and
also taking pidfds as argument is an excellent way to kill a few
problems at once:
- cheap pid namespace introspection
- creates a bridge between the "old" pid-based api and the "new" pidfd api
- allows us to get proper non-directory file descriptors for any pids we
  like

The additional advantage is that people are already happy to add this
syscall so simply extending it and routing it through the pidfd tree or
Eric's tree is reasonable. (It should probably grow a flag argument. I
need to start prototyping this.)

> 
> We still need a pidfd_clone() for atomicity reasons, but that's a
> separate story. My goal is to be able to write a library that

Yes, on my todo list and I have a ported patch based on prior working
rotting somehwere on my git server.

> transparently creates and manages a helper child process even in a
> "hostile" process environment in which some other uncoordinated thread
> is constantly doing a waitpid(-1) (e.g., the JVM).
> 
> > So instead of going throught proc we should probably do what David has
> > been doing in the mount API and come to rely on anone_inode. So
> > something like:
> >
> > fd = anon_inode_getfd("pidfd", &pidfd_fops, file_priv_data, flags);
> >
> > and stash information such as pid namespace etc. in a pidfd struct or
> > something that we then can stash file->private_data of the new file.
> > This also lets us avoid all this open coding done here.
> > Another advantage is that anon_inodes is its own kernel-internal
> > filesystem.
> 
> Sure. That works too.

Great.

