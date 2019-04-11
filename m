Return-Path: <SRS0=QIji=SN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 573E5C10F13
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 17:53:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 00DB22082E
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 17:52:59 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="cfBtLJFe"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 00DB22082E
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 766216B026D; Thu, 11 Apr 2019 13:52:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 713A06B026E; Thu, 11 Apr 2019 13:52:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 602736B026F; Thu, 11 Apr 2019 13:52:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f72.google.com (mail-wm1-f72.google.com [209.85.128.72])
	by kanga.kvack.org (Postfix) with ESMTP id 12F4A6B026D
	for <linux-mm@kvack.org>; Thu, 11 Apr 2019 13:52:59 -0400 (EDT)
Received: by mail-wm1-f72.google.com with SMTP id 187so5308819wmc.1
        for <linux-mm@kvack.org>; Thu, 11 Apr 2019 10:52:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=UWmf2gFVGYdGp3+zu1SOeQRU5dF4/Q9osFeNuzPV66M=;
        b=V7L850QfqtytqRvjsG/wGHyk0+35dfwZiQd4auEnVRPUiqWR+wmfcSZDHHBhHKRfJ8
         9W8XK1Qfa3/QV8zdBkFGOVrR3mvsVyTvdLOmII/fyETj4ep+R3XQEr0t9m3Axc3VIFd2
         hXNXW2g++C/SlzCcSm26YtSoxCq4HruZGt/2mA3joRgbLGA9uHzwYtSfI1hbkGtXQyju
         opW6iJo9K8z197wCodeeGmgFNYyw+CR+Scw1Be75yBa2ri4C+3cJB2sfPyPUR2zYGhgp
         jHAaf8ZmNhuiHw75spz8xUXpucmAenick0F8+ZW+pjsY2ax6l93v1o3KqxOA8mbWMosi
         q9mQ==
X-Gm-Message-State: APjAAAVi3ngSCTpqX+acZRf9zvCdYwz348qLkFjq8a4BvmnqOy7nJ0i/
	YU7QozPOHTVjZnfVc0Hd0eD7goSBLuwLZHa6BJjUK1lWBlefhkISPH8/O9RglGVMeI8oaVew3dJ
	ZJ8cM3UhNh+V9U0+p/eyWH2En/H8Nt0yVtJYCGAj/Rw4lebBUVaR3+1R1/H6nwZAL3w==
X-Received: by 2002:a1c:a010:: with SMTP id j16mr7498876wme.40.1555005178604;
        Thu, 11 Apr 2019 10:52:58 -0700 (PDT)
X-Received: by 2002:a1c:a010:: with SMTP id j16mr7498825wme.40.1555005177165;
        Thu, 11 Apr 2019 10:52:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555005177; cv=none;
        d=google.com; s=arc-20160816;
        b=c6lFCnmtJKv5cMaueKoIsXb/jYVXh7GZwbC0K/IdGE+ffehoCi6zFOjnuxY/3atBZf
         7ZAG42aM+J4Si+ILc8BrUC9JjcnouEIUh2ZgyQ5gDp0+x8r164IpO/aAbGOkw/0w0UKq
         huJy4zYFO0dcsQX1a4B60WmKCPOXCLAF9bl09vK8/RNEAqQhVCR6g2ixqswIxAw3xGON
         S8DwKdhTU4f2jH5wmrGIqwnvNtqo9PjMcvZLyEGOEz3IGi45WWJfq7J1O3mtlI3NYjHU
         lKinv88g/WRoOJH5VzfpUhESqt+Z4zNI0L7huaoy/TvXdd3tesBqkAeGLJxEAOspwqr9
         xC3Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=UWmf2gFVGYdGp3+zu1SOeQRU5dF4/Q9osFeNuzPV66M=;
        b=bhhrLa+FI/OJ9eXYGJvjn2MDKbgqkJ0nTDRtHyvFPtipZdxAIM26h/iSWu0eDz+I6G
         rrcAtkYJjFYb57wK46v6tY5aOcZMak6AGkHtSH659rveuIcOqEHK7c8JcxrTFyaKOsAE
         WC+99OINjmnhLAkvaPhQW4lFbHN9ahUgqf6UbjTVMWwkoTmN006ytjoKDJ1qehMInTrb
         GrxVOPE8RRvbs6aWzlkSs663ky6mRk9ZLSg7hhgupjA1uTwyBkIYdNGt0aGPf4D4yrDn
         cRhvpZTTKRwloZL4xmMzAT50Uw2l4MgRVKW9Fyxam85VuWU7+2UngLivL1ZvYcfhtkbu
         CuWw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=cfBtLJFe;
       spf=pass (google.com: domain of surenb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=surenb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g5sor29602470wrp.41.2019.04.11.10.52.57
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 11 Apr 2019 10:52:57 -0700 (PDT)
Received-SPF: pass (google.com: domain of surenb@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=cfBtLJFe;
       spf=pass (google.com: domain of surenb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=surenb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=UWmf2gFVGYdGp3+zu1SOeQRU5dF4/Q9osFeNuzPV66M=;
        b=cfBtLJFewyMKRnYYnw21vINnPqrk2z7GXrfM4YvSVrWBgQq+nJOjapX/bWa5GUvuYY
         H3toxmQkRamCTdWSc8N3hDwzQdehoe+ScCzHOv6ZBgAJX3biWy24vKWv0lNW4hrPaXaO
         qBo1S2X8vw7dHA2BxIBEuMUibMJqCRACcBwW8wcxJ2Yqwv+asIld9QHvEQnMVQOJPgWy
         bp+m/WK6Dg+OZiuHifUQQfGgY6JUUuTSwDSXRs3EJl8COHu1SeN09A6JrgzaeNx/3XHH
         XRcffG/t68HskedwzTcwrH5utbMjIhnZI1NtOUdPNt4GKX40dNXqMl0hOKzAz/WV4qKE
         NwdQ==
X-Google-Smtp-Source: APXvYqwhl9r+dJ0Z/fammLyczcHvRtwhpBRx/JMX+uk7Nbkdaz4yEC6SKsx9MC9/KkL3DGJtwTYbXhZG31qaO53ZZtA=
X-Received: by 2002:adf:dc8e:: with SMTP id r14mr8296918wrj.118.1555005176426;
 Thu, 11 Apr 2019 10:52:56 -0700 (PDT)
MIME-Version: 1.0
References: <20190411014353.113252-1-surenb@google.com> <20190411014353.113252-3-surenb@google.com>
 <20190411153313.GE22763@bombadil.infradead.org> <CAJuCfpGQ8c-OCws-zxZyqKGy1CfZpjxDKMH__qAm5FFXBcnWOw@mail.gmail.com>
 <CAKOZuetFU4tXE27bxA86zzDfNSCbw83p8fPxfkQ_d_Em0C04Sg@mail.gmail.com> <20190411173649.GF22763@bombadil.infradead.org>
In-Reply-To: <20190411173649.GF22763@bombadil.infradead.org>
From: Suren Baghdasaryan <surenb@google.com>
Date: Thu, 11 Apr 2019 10:52:45 -0700
Message-ID: <CAJuCfpG1P42qnDmGZLGkYy+mkS7QjfYUjGGpEBa9UGgLt5=q4Q@mail.gmail.com>
Subject: Re: [RFC 2/2] signal: extend pidfd_send_signal() to allow expedited
 process killing
To: Matthew Wilcox <willy@infradead.org>
Cc: Daniel Colascione <dancol@google.com>, Andrew Morton <akpm@linux-foundation.org>, 
	Michal Hocko <mhocko@suse.com>, David Rientjes <rientjes@google.com>, yuzhoujian@didichuxing.com, 
	Souptick Joarder <jrdr.linux@gmail.com>, Roman Gushchin <guro@fb.com>, Johannes Weiner <hannes@cmpxchg.org>, 
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, 
	"Eric W. Biederman" <ebiederm@xmission.com>, Shakeel Butt <shakeelb@google.com>, 
	Christian Brauner <christian@brauner.io>, Minchan Kim <minchan@kernel.org>, 
	Tim Murray <timmurray@google.com>, Joel Fernandes <joel@joelfernandes.org>, 
	Jann Horn <jannh@google.com>, linux-mm <linux-mm@kvack.org>, lsf-pc@lists.linux-foundation.org, 
	LKML <linux-kernel@vger.kernel.org>, kernel-team <kernel-team@android.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 11, 2019 at 10:36 AM Matthew Wilcox <willy@infradead.org> wrote:
>
> On Thu, Apr 11, 2019 at 10:33:32AM -0700, Daniel Colascione wrote:
> > On Thu, Apr 11, 2019 at 10:09 AM Suren Baghdasaryan <surenb@google.com> wrote:
> > > On Thu, Apr 11, 2019 at 8:33 AM Matthew Wilcox <willy@infradead.org> wrote:
> > > >
> > > > On Wed, Apr 10, 2019 at 06:43:53PM -0700, Suren Baghdasaryan wrote:
> > > > > Add new SS_EXPEDITE flag to be used when sending SIGKILL via
> > > > > pidfd_send_signal() syscall to allow expedited memory reclaim of the
> > > > > victim process. The usage of this flag is currently limited to SIGKILL
> > > > > signal and only to privileged users.
> > > >
> > > > What is the downside of doing expedited memory reclaim?  ie why not do it
> > > > every time a process is going to die?
> > >
> > > I think with an implementation that does not use/abuse oom-reaper
> > > thread this could be done for any kill. As I mentioned oom-reaper is a
> > > limited resource which has access to memory reserves and should not be
> > > abused in the way I do in this reference implementation.
> > > While there might be downsides that I don't know of, I'm not sure it's
> > > required to hurry every kill's memory reclaim. I think there are cases
> > > when resource deallocation is critical, for example when we kill to
> > > relieve resource shortage and there are kills when reclaim speed is
> > > not essential. It would be great if we can identify urgent cases
> > > without userspace hints, so I'm open to suggestions that do not
> > > involve additional flags.
> >
> > I was imagining a PI-ish approach where we'd reap in case an RT
> > process was waiting on the death of some other process. I'd still
> > prefer the API I proposed in the other message because it gets the
> > kernel out of the business of deciding what the right signal is. I'm a
> > huge believer in "mechanism, not policy".
>
> It's not a question of the kernel deciding what the right signal is.
> The kernel knows whether a signal is fatal to a particular process or not.
> The question is whether the killing process should do the work of reaping
> the dying process's resources sometimes, always or never.  Currently,
> that is never (the process reaps its own resources); Suren is suggesting
> sometimes, and I'm asking "Why not always?"

If there are no downsides of doing this always (like using some
resources that can be utilized in a better way) then by all means,
let's do it unconditionally. My current implementation is not one of
such cases :)

I think with implementation when killing process is doing the reaping
of the victim's mm this can be done unconditionally because we don't
use resources which might otherwise be used in a better way. Overall I
like Daniel's idea of the process that requested killing and is
waiting for the victim to die helping in reaping its memory. It kind
of naturally elevates the priority of the reaping if the priority of
the waiting process is higher than victim's priority (a kind of
priority inheritance).

