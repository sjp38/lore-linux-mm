Return-Path: <SRS0=zC3H=RW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 62648C10F03
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 22:48:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 14585217F5
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 22:48:48 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="dXOAHtaL"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 14585217F5
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9BFB86B0005; Tue, 19 Mar 2019 18:48:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 946976B0006; Tue, 19 Mar 2019 18:48:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7E7A86B0007; Tue, 19 Mar 2019 18:48:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f200.google.com (mail-oi1-f200.google.com [209.85.167.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4157B6B0005
	for <linux-mm@kvack.org>; Tue, 19 Mar 2019 18:48:47 -0400 (EDT)
Received: by mail-oi1-f200.google.com with SMTP id p65so187265oib.15
        for <linux-mm@kvack.org>; Tue, 19 Mar 2019 15:48:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=kHoY8TN2HUglNxwi9kbbGsh1LU7fNFZrbK3QOWSNrNQ=;
        b=r2t11tGNKQvH793LfSpMpKNH2pB99ixX6B1lPOipsjKtXLlC7vgAxNFoFHvlMOF6X8
         lwoyiIu5Z/ev1VNDPBFrwkUb1mn7fxm81SWzJgqyVJ0bM1BrwbrBxcNS4y5whkaVxfX2
         gwKsh11TgqZNMf91PaFVrKSGJISYoy0LYXjy9kWvwC1dt/WPqMUGE78q74/pC2FrY3pB
         fVmz2Qc4XgFJlc7PvWOyy1E53iwKmKyUSlip2c4YGWRg/CqGJVv/IzTs2wiq9xQ0tLFS
         5HZCLeu2ddtw68nBciRu75xCvZSkL1fUuFet0yiZDdBkbom1H8p5HTBZqTPEudyml2JP
         Oxhw==
X-Gm-Message-State: APjAAAUGPXV6CAZOW99gWue8wh8UyB+u4F0qht5CayNFP3cVEnkmWhnR
	aF257jKq6+FlkYXuDy0jTGs36dlE1jUlPsT6jJYd7njbGsG494yVhqbeLvR9nBRLZ/b4JXHGVTU
	/tCZKkGMRo94RvDflHu7GR5/H9QV2a0VTSySHuSFGfREJ59CEL2mGR9mhFnhrYLEMGQ==
X-Received: by 2002:a9d:39e2:: with SMTP id y89mr3503823otb.131.1553035726831;
        Tue, 19 Mar 2019 15:48:46 -0700 (PDT)
X-Received: by 2002:a9d:39e2:: with SMTP id y89mr3503779otb.131.1553035725652;
        Tue, 19 Mar 2019 15:48:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553035725; cv=none;
        d=google.com; s=arc-20160816;
        b=QifpbtGbvBZk3nyxw0zODfd39NAkb/Ob6dWYzzg7VkkUlNBfOmHoQQV64CRG4yNt6x
         QgjoHn6FZ0bKq2Wf3YU8k24rU6y5bykJmuERTyzHCPszMm+Jm6VqA6lUeg3ld6r864uL
         Mh5AWibBBkVxJpCRrUxOIzUCFS9Jil5Lgs6QkcWQN4vh3SZltt7c45BrkyrEXSO6EWum
         5VKQHRIgoz+cKTSa7dFwv00U4kRFr+tzLQMITHF2geg4d7s1lDdUWJaZCaN85xLrcEUL
         oxl0J+sPdR+l+gDLnfBQl27/BOFeicZXnHcy1+xQYMLr6HQLQhJVwDTc/QiR8uf2LyrT
         pRng==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=kHoY8TN2HUglNxwi9kbbGsh1LU7fNFZrbK3QOWSNrNQ=;
        b=zP18RVGpYZ+Bwc2oT+Foe7HYCCzg+Wf6zdSSu8ra89TUm7cJvcGAW+KdpGPeEJW8cC
         znThSAyKXVSBaDoHD1lceMkUXcp6JIfceFlTEddaAj1wjdyRT74HOOP2Ob+djRwFnEGG
         c1DyMY8tF08c9QvpAiGdAUXnCdniG7YPJhXZCL/jKrhWvHakkRHyfgvqLazduZX3KIlZ
         jWrfkQfT94LWqVTmIsqF2sbCNBvWoONdi4ZKWSgsu0hTN/FFNety/rCppVtJUAzrmORc
         h0mhRKnUCfmjais0gR5HatIdCnj8RUzx1pfLUjUI8bnPUqQlf4NJxV5EYaXr0bQyrl5A
         BC5g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=dXOAHtaL;
       spf=pass (google.com: domain of dancol@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dancol@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j23sor175771otl.150.2019.03.19.15.48.45
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 19 Mar 2019 15:48:45 -0700 (PDT)
Received-SPF: pass (google.com: domain of dancol@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=dXOAHtaL;
       spf=pass (google.com: domain of dancol@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dancol@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=kHoY8TN2HUglNxwi9kbbGsh1LU7fNFZrbK3QOWSNrNQ=;
        b=dXOAHtaLyAAKZZYbIxk4SbvSXyCU/R/ODaSkkiZfM3dwxfiOqIZfzEAL48Kg8HXvJP
         CWNRkNCPM44f4bqZWJRNAz7uJPp5Tx2BbpKVFqaosLNgvn6WNNsfbP15scVYvzeXTihU
         s2lbLxLPq+atVU0oh89E1PGL2uKwxBvyWwSMsI4Nzc3xzvhKBB7NKa1tS22Zgdh/kClu
         +EKsubDaF3ydG09XXd4RksT4fDkndjixnM3gY9PKP2MkKeTTpEiMmCf9QbCcHWrDtCR4
         FjEY5/zE6Db3asU8M2luProQu157iJTe4zdBJuK/MuQjHG1fUytuiD/dy8knlCx8PS6c
         Ltwg==
X-Google-Smtp-Source: APXvYqyu9j9bprr/itai8g8Y3skZ3y4cUmwhrF2WD4F43rIh/bBc8jqP8i3q6oi78Dl1Ls5X/2LBdDhXwdTfTrBwwRU=
X-Received: by 2002:a9d:e8f:: with SMTP id 15mr780158otj.148.1553035724810;
 Tue, 19 Mar 2019 15:48:44 -0700 (PDT)
MIME-Version: 1.0
References: <20190315184903.GB248160@google.com> <CAJuCfpGp_9fE9MPGVCWjnTaeBE0K_Q22LS1pBqhp7zW2M=dbGw@mail.gmail.com>
 <CAKOZueuauUXRyrvhzBD0op6W4TAnydSx92bvrPN2VRWERX8iQg@mail.gmail.com>
 <20190316185726.jc53aqq5ph65ojpk@brauner.io> <CAJuCfpF-uYpUZ1RO99i2qEw5Ou4nSimSkiQvnNQ_rv8ogHKRfw@mail.gmail.com>
 <20190317015306.GA167393@google.com> <20190317114238.ab6tvvovpkpozld5@brauner.io>
 <CAKOZuetZPhqQqSgZpyY0cLgy0jroLJRx-B93rkQzcOByL8ih_Q@mail.gmail.com>
 <20190318002949.mqknisgt7cmjmt7n@brauner.io> <20190318235052.GA65315@google.com>
 <20190319221415.baov7x6zoz7hvsno@brauner.io>
In-Reply-To: <20190319221415.baov7x6zoz7hvsno@brauner.io>
From: Daniel Colascione <dancol@google.com>
Date: Tue, 19 Mar 2019 15:48:32 -0700
Message-ID: <CAKOZuessqcjrZ4rfGLgrnOhrLnsVYiVJzOj4Aa=o3ZuZ013d0g@mail.gmail.com>
Subject: Re: [RFC] simple_lmk: Introduce Simple Low Memory Killer for Android
To: Christian Brauner <christian@brauner.io>
Cc: Joel Fernandes <joel@joelfernandes.org>, Suren Baghdasaryan <surenb@google.com>, 
	Steven Rostedt <rostedt@goodmis.org>, Sultan Alsawaf <sultan@kerneltoast.com>, 
	Tim Murray <timmurray@google.com>, Michal Hocko <mhocko@kernel.org>, 
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>, =?UTF-8?B?QXJ2ZSBIasO4bm5ldsOlZw==?= <arve@android.com>, 
	Todd Kjos <tkjos@android.com>, Martijn Coenen <maco@android.com>, Ingo Molnar <mingo@redhat.com>, 
	Peter Zijlstra <peterz@infradead.org>, LKML <linux-kernel@vger.kernel.org>, 
	"open list:ANDROID DRIVERS" <devel@driverdev.osuosl.org>, linux-mm <linux-mm@kvack.org>, 
	kernel-team <kernel-team@android.com>, Oleg Nesterov <oleg@redhat.com>, 
	Andy Lutomirski <luto@amacapital.net>, "Serge E. Hallyn" <serge@hallyn.com>, 
	Kees Cook <keescook@chromium.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 19, 2019 at 3:14 PM Christian Brauner <christian@brauner.io> wrote:
> So I dislike the idea of allocating new inodes from the procfs super
> block. I would like to avoid pinning the whole pidfd concept exclusively
> to proc. The idea is that the pidfd API will be useable through procfs
> via open("/proc/<pid>") because that is what users expect and really
> wanted to have for a long time. So it makes sense to have this working.
> But it should really be useable without it. That's why translate_pid()
> and pidfd_clone() are on the table.  What I'm saying is, once the pidfd
> api is "complete" you should be able to set CONFIG_PROCFS=N - even
> though that's crazy - and still be able to use pidfds. This is also a
> point akpm asked about when I did the pidfd_send_signal work.

I agree that you shouldn't need CONFIG_PROCFS=Y to use pidfds. One
crazy idea that I was discussing with Joel the other day is to just
make CONFIG_PROCFS=Y mandatory and provide a new get_procfs_root()
system call that returned, out of thin air and independent of the
mount table, a procfs root directory file descriptor for the caller's
PID namspace and suitable for use with openat(2).

C'mon: /proc is used by everyone today and almost every program breaks
if it's not around. The string "/proc" is already de facto kernel ABI.
Let's just drop the pretense of /proc being optional and bake it into
the kernel proper, then give programs a way to get to /proc that isn't
tied to any particular mount configuration. This way, we don't need a
translate_pid(), since callers can just use procfs to do the same
thing. (That is, if I understand correctly what translate_pid does.)

We still need a pidfd_clone() for atomicity reasons, but that's a
separate story. My goal is to be able to write a library that
transparently creates and manages a helper child process even in a
"hostile" process environment in which some other uncoordinated thread
is constantly doing a waitpid(-1) (e.g., the JVM).

> So instead of going throught proc we should probably do what David has
> been doing in the mount API and come to rely on anone_inode. So
> something like:
>
> fd = anon_inode_getfd("pidfd", &pidfd_fops, file_priv_data, flags);
>
> and stash information such as pid namespace etc. in a pidfd struct or
> something that we then can stash file->private_data of the new file.
> This also lets us avoid all this open coding done here.
> Another advantage is that anon_inodes is its own kernel-internal
> filesystem.

Sure. That works too.

