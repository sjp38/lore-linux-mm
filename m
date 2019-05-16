Return-Path: <SRS0=l6tt=TQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 71E8EC04AAF
	for <linux-mm@archiver.kernel.org>; Thu, 16 May 2019 16:10:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 259EE206BF
	for <linux-mm@archiver.kernel.org>; Thu, 16 May 2019 16:10:13 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="oQIJnd3c"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 259EE206BF
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B63D56B0005; Thu, 16 May 2019 12:10:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B13C46B0006; Thu, 16 May 2019 12:10:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9DB816B0007; Thu, 16 May 2019 12:10:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f200.google.com (mail-oi1-f200.google.com [209.85.167.200])
	by kanga.kvack.org (Postfix) with ESMTP id 751B86B0005
	for <linux-mm@kvack.org>; Thu, 16 May 2019 12:10:12 -0400 (EDT)
Received: by mail-oi1-f200.google.com with SMTP id a196so1611210oii.21
        for <linux-mm@kvack.org>; Thu, 16 May 2019 09:10:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=bMHMBrMd0YNkJT0fsHTTWNRBFmrV68S4uDG6Stq2kXM=;
        b=hbBJoh9kXMRu6I21d8xUR72xBI6UeGLo0GnYWUu538JQHEu4i3dH8R49ofaryqdoN0
         6/EbFKNTnVZuvcWlnq8dBGKkZte9JXZN4NwjGlOEGrfbnK32YpBjZFf3DNJfwFX+VwHy
         ywdgserlgKAOCV/8NCcAboxdyMdms30KCXs0HtbihLGTea95e89BY8OKTIh5xJlZtwHy
         b4uW/fakuLURSKpWdIYPacVLvhwpJCNs6i2NBlD9mpAfY70W9Rj6DkShgoPHJ22GrXbk
         +9IUxY6ztDBkiu+VmC/ZtyaRpoqkt9baDPcrJP+PuVWMlNLrAYvYVJX0jCo1+uVz6chW
         qisQ==
X-Gm-Message-State: APjAAAVQNzSVUtt/QX2RiYTcvE8NhyhbeYzR+q1eOq9D7UKLsiP/SWkv
	I/lV2jZVBmUw4b3le8NUz5XoO2W788R0gzXzVYYMYsg5ulDpfkqDHXfKw+9+nUNzBhYKyepkLmK
	u4ITZKBh3JXr0akVdRozEPy4oGE0dRL0pzRXbEBBc06efarjGH0+ZHTdel9ED8ZKYnQ==
X-Received: by 2002:a9d:826:: with SMTP id 35mr30682895oty.114.1558023012182;
        Thu, 16 May 2019 09:10:12 -0700 (PDT)
X-Received: by 2002:a9d:826:: with SMTP id 35mr30682847oty.114.1558023011455;
        Thu, 16 May 2019 09:10:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558023011; cv=none;
        d=google.com; s=arc-20160816;
        b=fG4BgTjWUm0V94RGO+yhaR5nYrmj5W9/k3cgc28nutRvRrh4SsXNmTi2M0BJtKoKAc
         NqxIO2WgU2M40HFw3K41wbNerYw+M2GZAMJYUzydRsV4WhoXPeCDz1jSZhPIMnX8OgVC
         DuIBP28qd6hZl/AyFH8umu01k2WfjJR+FBioUkTZkRauflIn8+7BLBQzfr3ICExtjod1
         XMFaiUAIc3k/FxXawqLU1jrlZKSbUgD6rTCH5GsZXPx/j3z2b8snWbW8G+7e105SK/CO
         cYHwRti+hvzBnT0nPkvF3B4/dAubz+i218WfzZepHiuBNIa5cKcGRHrJYHtWU9ieaM9E
         7mvw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=bMHMBrMd0YNkJT0fsHTTWNRBFmrV68S4uDG6Stq2kXM=;
        b=Ml7PA3CHENMRvm4mxA5W/a8MdYkIzQgDPMX2nQUyH91H1Ger/Rv0/SMoQU/7ON9G2h
         EKf59Xzj6pSrH3SQsTxwGXaqWeTah+IgJxdtc4GzFLtGofn2GaA1aibH2vHWk5bvifND
         lbazDxp10A2h0xUDiWi7tTg90ijEQkM7vIbUu0CnqfC7aTUB4ekYE6M0ZUMKhY9Gg6wd
         W1chQf0nPtRcPhu4CbfbEQt36EIeO6Rp2YcF9n4uapLPJ+jXtBI/ZmyeMDBpgO6Z6+IC
         aNGHzsz1JIyfYtrdDh8/R4WBMRaChVuOksjQ+ygruObOrgEDH0G6JQ3rtn0n+zxYW/EQ
         FcBA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=oQIJnd3c;
       spf=pass (google.com: domain of jannh@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jannh@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b17sor2964006otk.53.2019.05.16.09.10.11
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 16 May 2019 09:10:11 -0700 (PDT)
Received-SPF: pass (google.com: domain of jannh@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=oQIJnd3c;
       spf=pass (google.com: domain of jannh@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jannh@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=bMHMBrMd0YNkJT0fsHTTWNRBFmrV68S4uDG6Stq2kXM=;
        b=oQIJnd3cJFOTGWU+mhqQw5xZ/48tAUVBLW2xsdnHW75CFgSaesak+3DGKJkRVnnlf5
         f7vp8/QSuZL0RRyYca0jxJkcPCNSvi7RRnbKm5rO4uvFQinoZkfWxKegO3545xUKi6Tm
         yDlWfRiGkBs9X7KKIzePsKsJBYU4Mhp9dgLaLpepquR4TXbJgz+SyjP4Cb13IfAyCjJc
         yGAprbbVJ9x317dpUPRsbFj1RHmcJ2iqPoNfYLSKY45Sx4cye8fqfTTAzGmIRMznduug
         6Zyh7c9l0qYmroDn3xiUT/EZlGqq0eanNec/JAobiVm74MfwZM1Br1PUonCZzlOV+vwq
         1QHw==
X-Google-Smtp-Source: APXvYqxWTgXDP+q+BEeyCjiZ3kodMX94OZctQK+ZcHZRSQLNXJRMtNIbRJ4iu9fxZKt8FJF85O7xJzJohWCE0aKFlNM=
X-Received: by 2002:a9d:7347:: with SMTP id l7mr6367258otk.183.1558023010974;
 Thu, 16 May 2019 09:10:10 -0700 (PDT)
MIME-Version: 1.0
References: <20190516094234.9116-1-oleksandr@redhat.com> <20190516094234.9116-5-oleksandr@redhat.com>
 <CAG48ez2yXw_PJXO-mS=Qw5rkLpG6zDPd0saMhhGk09-du2bpaA@mail.gmail.com>
 <20190516142013.sf2vitmksvbkb33f@butterfly.localdomain> <20190516144323.pzkvs6hapf3czorz@butterfly.localdomain>
In-Reply-To: <20190516144323.pzkvs6hapf3czorz@butterfly.localdomain>
From: Jann Horn <jannh@google.com>
Date: Thu, 16 May 2019 18:09:44 +0200
Message-ID: <CAG48ez0-ytaDNVa7TiMaa4nR-nMEh_ZgND-sXjiw+RzZFmMqhw@mail.gmail.com>
Subject: Re: [PATCH RFC 4/5] mm/ksm, proc: introduce remote merge
To: Oleksandr Natalenko <oleksandr@redhat.com>
Cc: kernel list <linux-kernel@vger.kernel.org>, Kirill Tkhai <ktkhai@virtuozzo.com>, 
	Hugh Dickins <hughd@google.com>, Alexey Dobriyan <adobriyan@gmail.com>, Vlastimil Babka <vbabka@suse.cz>, 
	Michal Hocko <mhocko@suse.com>, Matthew Wilcox <willy@infradead.org>, 
	Pavel Tatashin <pasha.tatashin@soleen.com>, Greg KH <greg@kroah.com>, 
	Suren Baghdasaryan <surenb@google.com>, Minchan Kim <minchan@kernel.org>, 
	Timofey Titovets <nefelim4ag@gmail.com>, Aaron Tomlin <atomlin@redhat.com>, 
	Grzegorz Halat <ghalat@redhat.com>, Linux-MM <linux-mm@kvack.org>, 
	Linux API <linux-api@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, May 16, 2019 at 4:43 PM Oleksandr Natalenko
<oleksandr@redhat.com> wrote:
> On Thu, May 16, 2019 at 04:20:13PM +0200, Oleksandr Natalenko wrote:
> > > [...]
> > > > @@ -2960,15 +2962,63 @@ static int proc_stack_depth(struct seq_file *m, struct pid_namespace *ns,
> > > >  static ssize_t madvise_write(struct file *file, const char __user *buf,
> > > >                 size_t count, loff_t *ppos)
> > > >  {
> > > > +       /* For now, only KSM hints are implemented */
> > > > +#ifdef CONFIG_KSM
> > > > +       char buffer[PROC_NUMBUF];
> > > > +       int behaviour;
> > > >         struct task_struct *task;
> > > > +       struct mm_struct *mm;
> > > > +       int err = 0;
> > > > +       struct vm_area_struct *vma;
> > > > +
> > > > +       memset(buffer, 0, sizeof(buffer));
> > > > +       if (count > sizeof(buffer) - 1)
> > > > +               count = sizeof(buffer) - 1;
> > > > +       if (copy_from_user(buffer, buf, count))
> > > > +               return -EFAULT;
> > > > +
> > > > +       if (!memcmp("merge", buffer, min(sizeof("merge")-1, count)))
> > >
> > > This means that you also match on something like "mergeblah". Just use strcmp().
> >
> > I agree. Just to make it more interesting I must say that
> >
> >    /sys/kernel/mm/transparent_hugepage/enabled
> >
> > uses memcmp in the very same way, and thus echoing "alwaysssss" or
> > "madviseeee" works perfectly there, and it was like that from the very
> > beginning, it seems. Should we fix it, or it became (zomg) a public API?
>
> Actually, maybe, the reason for using memcmp is to handle "echo"
> properly: by default it puts a newline character at the end, so if we use
> just strcmp, echo should be called with -n, otherwise strcmp won't match
> the string.
>
> Huh?

Ah, yes, other code like e.g. proc_setgroups_write() uses strncmp()
and then has an extra check to make sure everything trailing is
whitespace.

