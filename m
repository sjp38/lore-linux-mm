Return-Path: <SRS0=h9qD=RX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B006AC43381
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 18:59:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 691DC20850
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 18:59:12 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="mRIf6w3Q"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 691DC20850
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 019D06B0003; Wed, 20 Mar 2019 14:59:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F0B786B0006; Wed, 20 Mar 2019 14:59:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E23CC6B0007; Wed, 20 Mar 2019 14:59:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9FEB66B0003
	for <linux-mm@kvack.org>; Wed, 20 Mar 2019 14:59:11 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id m17so3537233pgk.3
        for <linux-mm@kvack.org>; Wed, 20 Mar 2019 11:59:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=ZsMIk5N/e1lX2C2dObjWfHVYZX/KpN3z9XU57acVrEM=;
        b=RtmV0Q/nTR16/2NmlLb8ciY4HHWgW2O85Ev2+XEM6QIACZqW0r+aqiHZi8rFWzhfQT
         XcmrNJBgfiY7K9i3GKbQVlHgeHW2Dj2ml4IWPVzFYGl2LNRCY0Gtyjl2pGK9/RweGgsO
         zfFQSFNgqQuXws0B27+VoRcsQo1Kvh1M3GoVO+l0wXtXu8AdzJ2gbiJ51JCxjgOMJhZR
         OpPhH1PQDaUQha6ScDSdB0gDF/IgZ/xdWQnWKM7//j1EI41kEns3sWi0KhDyWnSrfvBp
         flfZr9ZsSHrbRyT7zfulZe6UCO5E4H/LeYU448uqvOwCE+8+sQb/ynq1BQRjivvgMqi+
         ENFw==
X-Gm-Message-State: APjAAAWPj9B2Zksi8bvY7ZWfI92DzPFW+mTzL47oFPvDhEH6N9R7pOYx
	RQD11ictvaQ1qTB6W05rZKxAToEO/gLgp+lkImM59FBCUlXrCWQjVOkotqfiCMweAS90R1ailJc
	R4ztcbtYFGSZJzqXN7BKQkfOo5DNo0eIndQW4u9k79IdFsPSk8Bd+KVr0qv8mcg4bzQ==
X-Received: by 2002:a65:6091:: with SMTP id t17mr7644854pgu.328.1553108351313;
        Wed, 20 Mar 2019 11:59:11 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzgMyjp11NJyx9T+x4mQYVvl6NBTMEAFlq2he+0ywldsRcpqD/M87K97QDuWd64u7Fg2Rep
X-Received: by 2002:a65:6091:: with SMTP id t17mr7644799pgu.328.1553108350459;
        Wed, 20 Mar 2019 11:59:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553108350; cv=none;
        d=google.com; s=arc-20160816;
        b=vztbfKAKlYm10XgjYRwoN9XcFbeG0NFDsdsdQJ1cMSatgHMVTqBoh/06iVIXtUHwSj
         se1J/jY/LTEUG3VBr4Q/tcnsOXnOPemcQVrXPuAodekIrvAr0xF5Qg03bJEQPAIESNXZ
         D4mgSBYmTje+gnyFDjdL6LhqXMNysTikRlV+nwEzTuNULK5E5otGJ6iOLgecqQrBQgC7
         DUORTn3yXhCmwfFLHvSySYkzGP1Xk1Nf95YQxIkA13sYNj853z0vi59L5hAWhcjzmKMp
         aQDFNDEyUrfOcPIHkxpXDcSoqjNPt8eNbXKc5feT/0/JH+P9XYbgYPAtqrLXPBHNchPP
         ejRw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=ZsMIk5N/e1lX2C2dObjWfHVYZX/KpN3z9XU57acVrEM=;
        b=0usYmHsnd9wzGaF6wISZBQfQo8jEcPLdAsjY8HpVflwRO8VG+95pQutYSe4ln5mKnH
         aUtQDTDpLOj9dtUl+N3xY53MEd7KYH5b3DiBK2uHEwR4+5JrXfSJeVBRf3xp5EcobGfN
         EIEZF7bI3yK5xOLrVWesXEC7CHOojrQXqUeLYH9ZgqPlW2hQ+hMiBxNk6oWcY8Z+UBrq
         tsuixaE0KkyWdBiKiNtCSlPeFeBnNGNFZ7izSu7PFN16KNDl5VqkLPv2hKCDavWt8vaH
         zSo2u1lrMo2v5jCarPW6A+0AyWDg4mFljlE2uSOFitgPA/WzCVCacGqgGRtkC1J/0Y/u
         Hc+w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=mRIf6w3Q;
       spf=pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=luto@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id y144si1428321pfc.225.2019.03.20.11.59.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Mar 2019 11:59:10 -0700 (PDT)
Received-SPF: pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=mRIf6w3Q;
       spf=pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=luto@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-wm1-f41.google.com (mail-wm1-f41.google.com [209.85.128.41])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id B9C922190B
	for <linux-mm@kvack.org>; Wed, 20 Mar 2019 18:59:09 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1553108350;
	bh=jp8AbSaqwT21JnyYDjKNO3C8evoJ6yy8quSVRfFSrac=;
	h=References:In-Reply-To:From:Date:Subject:To:Cc:From;
	b=mRIf6w3QFh3e9I8TEAE+h2PxblsGDwAvz/vvD8Akc66cH92WI1V37lsdfwOx4+xnd
	 JLwYPXQAmxsZPJPnkaIC9PuN/GyDZDVoR3K3um+rtpcmpAB1nH7GpqTGRQs+2gFosD
	 MPn8HQc+0pW04uhAeiyRhhiaezb/4rABISJifUvM=
Received: by mail-wm1-f41.google.com with SMTP id n19so338876wmi.1
        for <linux-mm@kvack.org>; Wed, 20 Mar 2019 11:59:09 -0700 (PDT)
X-Received: by 2002:a1c:9a41:: with SMTP id c62mr9266896wme.108.1553108348098;
 Wed, 20 Mar 2019 11:59:08 -0700 (PDT)
MIME-Version: 1.0
References: <20190319221415.baov7x6zoz7hvsno@brauner.io> <CAKOZuessqcjrZ4rfGLgrnOhrLnsVYiVJzOj4Aa=o3ZuZ013d0g@mail.gmail.com>
 <20190319231020.tdcttojlbmx57gke@brauner.io> <20190320015249.GC129907@google.com>
 <CAKOZuetJzg_EiyuK7Pa13X3LKuBbreg7zJ5g4uQv_uV4wpmZjg@mail.gmail.com>
 <20190320035953.mnhax3vd47ya4zzm@brauner.io> <CAKOZuet3-VhmC3oHtEbPPvdiar_k_QXTf0TkgmH9LiwmW-_oNA@mail.gmail.com>
 <4A06C5BB-9171-4E70-BE31-9574B4083A9F@joelfernandes.org> <20190320182649.spryp5uaeiaxijum@brauner.io>
 <CAKOZuevHbQtrq+Nb-jw1L7O72BmAzcXmbUnfnseeXZjX4PE4tg@mail.gmail.com> <20190320185156.7bq775vvtsxqlzfn@brauner.io>
In-Reply-To: <20190320185156.7bq775vvtsxqlzfn@brauner.io>
From: Andy Lutomirski <luto@kernel.org>
Date: Wed, 20 Mar 2019 11:58:57 -0700
X-Gmail-Original-Message-ID: <CALCETrXO=V=+qEdLDVPf8eCgLZiB9bOTrUfe0V-U-tUZoeoRDA@mail.gmail.com>
Message-ID: <CALCETrXO=V=+qEdLDVPf8eCgLZiB9bOTrUfe0V-U-tUZoeoRDA@mail.gmail.com>
Subject: Re: pidfd design
To: Christian Brauner <christian@brauner.io>
Cc: Daniel Colascione <dancol@google.com>, Joel Fernandes <joel@joelfernandes.org>, 
	Suren Baghdasaryan <surenb@google.com>, Steven Rostedt <rostedt@goodmis.org>, 
	Sultan Alsawaf <sultan@kerneltoast.com>, Tim Murray <timmurray@google.com>, 
	Michal Hocko <mhocko@kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, 
	=?UTF-8?B?QXJ2ZSBIasO4bm5ldsOlZw==?= <arve@android.com>, 
	Todd Kjos <tkjos@android.com>, Martijn Coenen <maco@android.com>, Ingo Molnar <mingo@redhat.com>, 
	Peter Zijlstra <peterz@infradead.org>, LKML <linux-kernel@vger.kernel.org>, 
	"open list:ANDROID DRIVERS" <devel@driverdev.osuosl.org>, linux-mm <linux-mm@kvack.org>, 
	kernel-team <kernel-team@android.com>, Oleg Nesterov <oleg@redhat.com>, 
	"Serge E. Hallyn" <serge@hallyn.com>, Kees Cook <keescook@chromium.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 20, 2019 at 11:52 AM Christian Brauner <christian@brauner.io> wrote:
>
> You're misunderstanding. Again, I said in my previous mails it should
> accept pidfds optionally as arguments, yes. But I don't want it to
> return the status fds that you previously wanted pidfd_wait() to return.
> I really want to see Joel's pidfd_wait() patchset and have more people
> review the actual code.

Just to make sure that no one is forgetting a material security consideration:

$ ls /proc/self
attr             exe        mountinfo      projid_map    status
autogroup        fd         mounts         root          syscall
auxv             fdinfo     mountstats     sched         task
cgroup           gid_map    net            schedstat     timers
clear_refs       io         ns             sessionid     timerslack_ns
cmdline          latency    numa_maps      setgroups     uid_map
comm             limits     oom_adj        smaps         wchan
coredump_filter  loginuid   oom_score      smaps_rollup
cpuset           map_files  oom_score_adj  stack
cwd              maps       pagemap        stat
environ          mem        personality    statm

A bunch of this stuff makes sense to make accessible through a syscall
interface that we expect to be used even in sandboxes.  But a bunch of
it does not.  For example, *_map, mounts, mountstats, and net are all
namespace-wide things that certain policies expect to be unavailable.
stack, for example, is a potential attack surface.  Etc.

As it stands, if you create a fresh userns and mountns and try to
mount /proc, there are some really awful and hideous rules that are
checked for security reasons.  All these new APIs either need to
return something more restrictive than a proc dirfd or they need to
follow the same rules.  And I'm afraid that the latter may be a
nonstarter if you expect these APIs to be used in libraries.

Yes, this is unfortunate, but it is indeed the current situation.  I
suppose that we could return magic restricted dirfds, or we could
return things that aren't dirfds and all and have some API that gives
you the dirfd associated with a procfd but only if you can see
/proc/PID.

--Andy

