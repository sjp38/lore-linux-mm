Return-Path: <SRS0=IQlH=SO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 88C33C10F0E
	for <linux-mm@archiver.kernel.org>; Fri, 12 Apr 2019 15:30:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3C9C22171F
	for <linux-mm@archiver.kernel.org>; Fri, 12 Apr 2019 15:30:44 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="tuVY75I6"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3C9C22171F
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DA71C6B0278; Fri, 12 Apr 2019 11:30:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D55926B027A; Fri, 12 Apr 2019 11:30:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C6B8F6B027B; Fri, 12 Apr 2019 11:30:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f199.google.com (mail-vk1-f199.google.com [209.85.221.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9FC796B0278
	for <linux-mm@kvack.org>; Fri, 12 Apr 2019 11:30:43 -0400 (EDT)
Received: by mail-vk1-f199.google.com with SMTP id 62so4097694vkx.16
        for <linux-mm@kvack.org>; Fri, 12 Apr 2019 08:30:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=WCeVpCJn+/VBqGO7SUvicv745LSiVr8/+6GQ6wCM828=;
        b=A8/grHDDM4dLjRKk50ZlTHwMEXXn1mXLnUCfTSbNTOuVpDJyD4R5gy46M+Xe2JvYJj
         N3tyBcdjE68btJaEgqNzpd2bMpfvKa/YfwSzlJ+2BfYoHb8tEQTMC0XFWp3pwWSAnXsT
         vA7SXYrfgz31YjY3NAEP644XM+S/DdzM7LSaP8LAx7Ukx9v0TQVdcPvLse6cSDRDzNs4
         Q4goW9qEOam96TMDSJCQROKwKDbSqWoeUP5yk6qkmtSuvFG1j8qOn81Cv/imoY4N0gKI
         9uXGijqJ2ncVUcntY8AEooLt+XyosrBOgBlLlnSZi1eGcUydw+lebkQLCdzUYeo0aLiF
         nu5w==
X-Gm-Message-State: APjAAAXf7h3tQ+vHhrIdcp4yVJKhtWp5uqa4QwZweJ9WdcL/0LF4OmKs
	PgwPH+rOqymr78s572oJogMKa9aSWbU1rLhjsjnzQLEUQxTWGn9bOJ5hUfH0IHF7Fn7MW83+v9T
	wWt/rnAUxF0YufiXKVx7L7SFDAaIalMIYg6RBZcaupEniJsYB7efPNWEyBsQqzK0IIA==
X-Received: by 2002:a67:e90c:: with SMTP id c12mr26169381vso.102.1555083043324;
        Fri, 12 Apr 2019 08:30:43 -0700 (PDT)
X-Received: by 2002:a67:e90c:: with SMTP id c12mr26169339vso.102.1555083042710;
        Fri, 12 Apr 2019 08:30:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555083042; cv=none;
        d=google.com; s=arc-20160816;
        b=zgnYAi3EZgW0v14FQtgpZeEpdizTHbuHe7yQhdKG0didhzUY1XcY6LghncB+n8bjTb
         vG9v7oGKAsHEyLl0ILRXLV0KCUXthCERcet87/H0GeEk3hiYY0oQ1LPXeddLYYfq0Ini
         EbwqHPcd43ykrvzp+Usin9Fr9NPUjOfwuK/iZDmaV2KWyRGY/0FqxXO7ztMmK7TsH84v
         idduxgJ6lSppKFqNADE1dKRg9oVl7COcbtLr8bSjrPFJbMr+i9s97AHBLvPYbOp/Yoym
         Llk5lKD88f4WvDfd+auLbfyT7NHLSfLXsP6WEBxLDPqVVt23Esk+60k9cvV0U8yFPiNJ
         aWbg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=WCeVpCJn+/VBqGO7SUvicv745LSiVr8/+6GQ6wCM828=;
        b=mzZz/+hEGxP+3S3pObBzQBjG8LV6O57SDeEu1EZiYpHRNLIUTkZoVavYWF5mwTfxZv
         CvG6oIDdmfsE7rQluZhqNhVZapgQEgvghgviIlozZARDx5vwJWXCf0T6nQnODqhBUO+l
         w67AOoTcK4BYSY8aVPvr4gv8JVmNsrq+BjJpQumveQHAav8vX7cFZE8XOpR9RCvtIUz/
         1jnga1iYoTN1aNHbRwe0S/WklgsRipPK0nTPdZRs6GnhtbcYcoB+6q3xD+giVjSEfgQq
         os9Rkzs/iAhlk1e1Rw6w/LvkreSvYFJzOw0lMjztEg2ItxF9CJ0tqPKAu9FO5i5YGUgI
         Uh4A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=tuVY75I6;
       spf=pass (google.com: domain of dancol@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dancol@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y26sor25304568vsm.43.2019.04.12.08.30.42
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 12 Apr 2019 08:30:42 -0700 (PDT)
Received-SPF: pass (google.com: domain of dancol@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=tuVY75I6;
       spf=pass (google.com: domain of dancol@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dancol@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=WCeVpCJn+/VBqGO7SUvicv745LSiVr8/+6GQ6wCM828=;
        b=tuVY75I6tPrTGvJwWKarA/iYaQuwlcLQphJVG6VFjczrbRvlWFKr5CGKYTgboJF5+w
         LonhQj++DgJzMYXl/hrWXwkUDYM8ZVK69w1B1kHkx1q495XiDKpPZapStMILRzz2iWkQ
         54R7AvDr8YJ1uRFdEzWYTFlsb6gfNrynNS2HdabUXQR2BQpccHxZ8wFHwY5p0+Lk3xCF
         pbNYktnRXpZbLNkEa+WAdTsvsWnq68E1Vn146Sn9zvgb6JlF7ESh8EPRcVnZxSZjPdO6
         cNYdVsOYAqKiELuT+QU2qHFODxmHPMKMnAj+0S2Tq13iCgTgOg5FcXfNkb7P38ZhBUd1
         ooXg==
X-Google-Smtp-Source: APXvYqzVWARcHk7V3SZK97ROzJzUIBAYjoig4ImnN5OLcMFwyeglwtcavgVLfUT+PZoHPi50u3Vwn6FXhv07EAvwLNU=
X-Received: by 2002:a67:6847:: with SMTP id d68mr31850761vsc.90.1555083042000;
 Fri, 12 Apr 2019 08:30:42 -0700 (PDT)
MIME-Version: 1.0
References: <20190411014353.113252-1-surenb@google.com> <20190411014353.113252-3-surenb@google.com>
 <20190411153313.GE22763@bombadil.infradead.org> <20190412065314.GC13373@dhcp22.suse.cz>
 <CAKOZuetQH1rVtPdMNgw0sdnzWidd6v9eCWscRiOb7Y+3-JQ14Q@mail.gmail.com>
In-Reply-To: <CAKOZuetQH1rVtPdMNgw0sdnzWidd6v9eCWscRiOb7Y+3-JQ14Q@mail.gmail.com>
From: Daniel Colascione <dancol@google.com>
Date: Fri, 12 Apr 2019 08:30:30 -0700
Message-ID: <CAKOZueu-ZRzzER3Cb6bNBtbmmhBJRzqjGvwvt8KTyVrmP9wQ7g@mail.gmail.com>
Subject: Re: [RFC 2/2] signal: extend pidfd_send_signal() to allow expedited
 process killing
To: Michal Hocko <mhocko@kernel.org>
Cc: Matthew Wilcox <willy@infradead.org>, Suren Baghdasaryan <surenb@google.com>, 
	Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, 
	yuzhoujian@didichuxing.com, Souptick Joarder <jrdr.linux@gmail.com>, 
	Roman Gushchin <guro@fb.com>, Johannes Weiner <hannes@cmpxchg.org>, 
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, 
	"Eric W. Biederman" <ebiederm@xmission.com>, Shakeel Butt <shakeelb@google.com>, 
	Christian Brauner <christian@brauner.io>, Minchan Kim <minchan@kernel.org>, 
	Tim Murray <timmurray@google.com>, Joel Fernandes <joel@joelfernandes.org>, 
	Jann Horn <jannh@google.com>, linux-mm <linux-mm@kvack.org>, lsf-pc@lists.linux-foundation.org, 
	linux-kernel <linux-kernel@vger.kernel.org>, 
	Android Kernel Team <kernel-team@android.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Apr 12, 2019 at 7:14 AM Daniel Colascione <dancol@google.com> wrote:
>
> On Thu, Apr 11, 2019 at 11:53 PM Michal Hocko <mhocko@kernel.org> wrote:
> >
> > On Thu 11-04-19 08:33:13, Matthew Wilcox wrote:
> > > On Wed, Apr 10, 2019 at 06:43:53PM -0700, Suren Baghdasaryan wrote:
> > > > Add new SS_EXPEDITE flag to be used when sending SIGKILL via
> > > > pidfd_send_signal() syscall to allow expedited memory reclaim of the
> > > > victim process. The usage of this flag is currently limited to SIGKILL
> > > > signal and only to privileged users.
> > >
> > > What is the downside of doing expedited memory reclaim?  ie why not do it
> > > every time a process is going to die?
> >
> > Well, you are tearing down an address space which might be still in use
> > because the task not fully dead yeat. So there are two downsides AFAICS.
> > Core dumping which will not see the reaped memory so the resulting
>
> Test for SIGNAL_GROUP_COREDUMP before doing any of this then. If you
> try to start a core dump after reaping begins, too bad: you could have
> raced with process death anyway.
>
> > coredump might be incomplete. And unexpected #PF/gup on the reaped
> > memory will result in SIGBUS.
>
> It's a dying process. Why even bother returning from the fault
> handler? Just treat that situation as a thread exit. There's no need
> to make this observable to userspace at all.

Just for clarity, checking the code, I think we already do this.
zap_other_threads sets SIGKILL pending on every thread in the group,
and we'll handle SIGKILL in the process of taking any page fault or
doing any system call, so I don't think it's actually possible for a
thread in a dying process to observe the SIGBUS that reaping in theory
can generate.

