Return-Path: <SRS0=h9qD=RX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_PASS,URIBL_BLOCKED,USER_AGENT_NEOMUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 571DEC43381
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 19:14:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1D47520850
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 19:14:18 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=brauner.io header.i=@brauner.io header.b="S90Arcuj"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1D47520850
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=brauner.io
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9F81F6B0003; Wed, 20 Mar 2019 15:14:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9A8BD6B0006; Wed, 20 Mar 2019 15:14:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8488C6B0007; Wed, 20 Mar 2019 15:14:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 47F8D6B0003
	for <linux-mm@kvack.org>; Wed, 20 Mar 2019 15:14:18 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id 33so3550664pgv.17
        for <linux-mm@kvack.org>; Wed, 20 Mar 2019 12:14:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=BAW01zqy6KxlVMaU5EuHvmflo6RBzBcSay2jwpmFxtM=;
        b=EMeRvCNOr6Jup79KbfYR9towmVmDnK5/6TVuIFo3Yj1kk6olCBJkfB3yiqYnskiZaM
         y/nLgNMEl0Pn3Frcl5usXs9CMgUcTaSGrN2HPBkKC+9Iv+HYMaoNWKyKoHIIR5n7lT3x
         S96999kOHBEGWYLvuc68BbJvWOQMFM5rm2plgiDTBcoc3XmmJwvlBQY9tu0J0sh0x4oW
         KQuzMl3jxixGLrml80aD3Qg8ZCPuqHN+zItGped+5g7AaLq6R+sOp8HvvdscWOgW/vAI
         uWZlj8O9AtibAMhHGznP7U6bo8n479DKRBh7cknqRFdcw5W4UOpnWPuNE/AvNEXuGrw1
         07PQ==
X-Gm-Message-State: APjAAAXa5CnyrRD1DzlqWdR8hFJ7vo8bFhWgyjv+eFLH0jWbrhP5YvsI
	USXdiLhy8x7alW5FBVHwO+H1KdWxkigcXsQoYBo4OLaZomAhKS6CWbUaIBJO6DYY374zdQ3jWJ1
	mYHk9KVdr+iwulbzP9inu2KLyqRfC6HHfmKQ0uYONSTZHMgzpKbj0eVBoHnrQK5l9AA==
X-Received: by 2002:a63:7f0f:: with SMTP id a15mr8980842pgd.270.1553109257873;
        Wed, 20 Mar 2019 12:14:17 -0700 (PDT)
X-Received: by 2002:a63:7f0f:: with SMTP id a15mr8980780pgd.270.1553109257079;
        Wed, 20 Mar 2019 12:14:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553109257; cv=none;
        d=google.com; s=arc-20160816;
        b=XuoW7dBj7BzYb1KWmE2hPn2hzowQTFHy2CRnh2bRX6ZUzJy00a0XhpVU14m75TM00P
         8vh4OqsVu2ld0m8jAyNdlBqq/oonPKGwVMsc1fZZUmW3PBV1YICRghLJPIzb2PQfmX/6
         HxjQbwxKETHBOG+GhfDyVorRnwXMmz2qHFEwnqeegoXS/OVM5BOPjxq0SRDY+ICu7AWI
         aQwdyEICGG72osyKbJXhfILEbNJ5u0oYn4oTFoSFP+G1J2e0MN1FZuktYHshiz2Ox+rF
         H0d0vgTFClAUNW9cxN7vSCVjfPKhZEuh14BTvQUnQ4IL3MN+s1BfUpeoqlk06DSezit3
         HsFg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=BAW01zqy6KxlVMaU5EuHvmflo6RBzBcSay2jwpmFxtM=;
        b=DzwbGi5PN3+pIJWFkAf9JaYEYKFQchy+oG5EIrfGv+QDHnhr3I5EysYEvYVJKDq+wY
         /FZkEnhTfyJEAn/XJja3MbdovRnWEixpGlw9HkwgULeDkkoVlfqF+23XiUD+Ph7V6K4P
         uXUnophdAmgpoULKXu8QHF73xw1p5i14CN1oSwqwqpW0WUBrupkYeWM7UwFoWn/L6V7t
         bnw3l+Om+0nelRW3VGNsET1VTilFeQAm5kyBlXLmGvsWFRa19HN2CNp+Ju//iXLQp8nr
         PjLcxm1yYAgC8xcxdUCAQeuOBIlp4QbBkzg1Q91sRaWq85LYX/pfqFDIO8km/ZA96Tzd
         WhbA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@brauner.io header.s=google header.b=S90Arcuj;
       spf=pass (google.com: domain of christian@brauner.io designates 209.85.220.65 as permitted sender) smtp.mailfrom=christian@brauner.io
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w8sor3314674pgs.25.2019.03.20.12.14.16
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 20 Mar 2019 12:14:17 -0700 (PDT)
Received-SPF: pass (google.com: domain of christian@brauner.io designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@brauner.io header.s=google header.b=S90Arcuj;
       spf=pass (google.com: domain of christian@brauner.io designates 209.85.220.65 as permitted sender) smtp.mailfrom=christian@brauner.io
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=brauner.io; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=BAW01zqy6KxlVMaU5EuHvmflo6RBzBcSay2jwpmFxtM=;
        b=S90ArcujnR16oCFASCAbzc3HMSYpIwOPCx6A18mUDzw3qdn1BrQGMBKxn9nTiPbL0p
         URb900dK+UL3rEr7NralddzqkDFVdKKIzsmkdkILPwMx8IuDdvGOhXyTGchBEbYOtJt+
         k0mWH6EagWlUrglzpB9aH1Dt1Z0X+6yAPg30bfK+JdDCUyEXBiKgAu8071nRWRYieKYo
         3xkflEgOoWgK4lavxsYpQgMnnWunMKt+hkb9x3/Jjahi0wrC9Kup2IdAvy/yHm89UyYW
         tpyyoMvz7ccHf1DuzBvZbYYO/jdF7ZDjSHC9dqSSbdtjtV45bjTFd3pS7H7jRAWt4a5S
         OQSA==
X-Google-Smtp-Source: APXvYqyBzEWhP63aMikE/5koL0Bk7AbFDYRAW8kPrRrLuH0iqP+m6I9MXZC/Ae4fdSIHkGrJY5FT/w==
X-Received: by 2002:a63:181a:: with SMTP id y26mr9038768pgl.268.1553109256447;
        Wed, 20 Mar 2019 12:14:16 -0700 (PDT)
Received: from brauner.io ([12.25.160.29])
        by smtp.gmail.com with ESMTPSA id h3sm5563561pfb.31.2019.03.20.12.14.14
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 20 Mar 2019 12:14:15 -0700 (PDT)
Date: Wed, 20 Mar 2019 20:14:14 +0100
From: Christian Brauner <christian@brauner.io>
To: Andy Lutomirski <luto@kernel.org>
Cc: Daniel Colascione <dancol@google.com>,
	Joel Fernandes <joel@joelfernandes.org>,
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
	"Serge E. Hallyn" <serge@hallyn.com>,
	Kees Cook <keescook@chromium.org>
Subject: Re: pidfd design
Message-ID: <20190320191412.5ykyast3rgotz3nu@brauner.io>
References: <20190319231020.tdcttojlbmx57gke@brauner.io>
 <20190320015249.GC129907@google.com>
 <CAKOZuetJzg_EiyuK7Pa13X3LKuBbreg7zJ5g4uQv_uV4wpmZjg@mail.gmail.com>
 <20190320035953.mnhax3vd47ya4zzm@brauner.io>
 <CAKOZuet3-VhmC3oHtEbPPvdiar_k_QXTf0TkgmH9LiwmW-_oNA@mail.gmail.com>
 <4A06C5BB-9171-4E70-BE31-9574B4083A9F@joelfernandes.org>
 <20190320182649.spryp5uaeiaxijum@brauner.io>
 <CAKOZuevHbQtrq+Nb-jw1L7O72BmAzcXmbUnfnseeXZjX4PE4tg@mail.gmail.com>
 <20190320185156.7bq775vvtsxqlzfn@brauner.io>
 <CALCETrXO=V=+qEdLDVPf8eCgLZiB9bOTrUfe0V-U-tUZoeoRDA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <CALCETrXO=V=+qEdLDVPf8eCgLZiB9bOTrUfe0V-U-tUZoeoRDA@mail.gmail.com>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 20, 2019 at 11:58:57AM -0700, Andy Lutomirski wrote:
> On Wed, Mar 20, 2019 at 11:52 AM Christian Brauner <christian@brauner.io> wrote:
> >
> > You're misunderstanding. Again, I said in my previous mails it should
> > accept pidfds optionally as arguments, yes. But I don't want it to
> > return the status fds that you previously wanted pidfd_wait() to return.
> > I really want to see Joel's pidfd_wait() patchset and have more people
> > review the actual code.
> 
> Just to make sure that no one is forgetting a material security consideration:

Andy, thanks for commenting!

> 
> $ ls /proc/self
> attr             exe        mountinfo      projid_map    status
> autogroup        fd         mounts         root          syscall
> auxv             fdinfo     mountstats     sched         task
> cgroup           gid_map    net            schedstat     timers
> clear_refs       io         ns             sessionid     timerslack_ns
> cmdline          latency    numa_maps      setgroups     uid_map
> comm             limits     oom_adj        smaps         wchan
> coredump_filter  loginuid   oom_score      smaps_rollup
> cpuset           map_files  oom_score_adj  stack
> cwd              maps       pagemap        stat
> environ          mem        personality    statm
> 
> A bunch of this stuff makes sense to make accessible through a syscall
> interface that we expect to be used even in sandboxes.  But a bunch of
> it does not.  For example, *_map, mounts, mountstats, and net are all
> namespace-wide things that certain policies expect to be unavailable.
> stack, for example, is a potential attack surface.  Etc.
> 
> As it stands, if you create a fresh userns and mountns and try to
> mount /proc, there are some really awful and hideous rules that are
> checked for security reasons.  All these new APIs either need to
> return something more restrictive than a proc dirfd or they need to
> follow the same rules.  And I'm afraid that the latter may be a
> nonstarter if you expect these APIs to be used in libraries.
> 
> Yes, this is unfortunate, but it is indeed the current situation.  I
> suppose that we could return magic restricted dirfds, or we could
> return things that aren't dirfds and all and have some API that gives
> you the dirfd associated with a procfd but only if you can see
> /proc/PID.

What would be your opinion to having a
/proc/<pid>/handle
file instead of having a dirfd. Essentially, what I initially proposed
at LPC. The change on what we currently have in master would be:
https://gist.github.com/brauner/59eec91550c5624c9999eaebd95a70df

