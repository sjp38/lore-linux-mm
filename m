Return-Path: <SRS0=l6tt=TQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1C2EDC04AB4
	for <linux-mm@archiver.kernel.org>; Thu, 16 May 2019 16:06:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C611920833
	for <linux-mm@archiver.kernel.org>; Thu, 16 May 2019 16:06:52 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="H6xNrQHk"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C611920833
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 572DC6B0005; Thu, 16 May 2019 12:06:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5229E6B0006; Thu, 16 May 2019 12:06:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3EA796B0007; Thu, 16 May 2019 12:06:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f197.google.com (mail-oi1-f197.google.com [209.85.167.197])
	by kanga.kvack.org (Postfix) with ESMTP id 124686B0005
	for <linux-mm@kvack.org>; Thu, 16 May 2019 12:06:52 -0400 (EDT)
Received: by mail-oi1-f197.google.com with SMTP id d198so1625744oih.6
        for <linux-mm@kvack.org>; Thu, 16 May 2019 09:06:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=I4VKFuY3dBhk8M0E31KTPJJ8MMHDVcscAUiCzod5h4g=;
        b=cNR9r42vzTdeDynXYQ4mjt7VBLwlJ8OKCJhSnMro3MBhSmw6DnwJjyzH7RYPIdRCB2
         McEFSoZGY9M8B9edK7zbEuDuPu6icYSBfuL0xizM8URbs5SC2XOa12LrFhqfmdLD3L7R
         PDWES/x/bIND1Y4oqD8fJGHZaWTJ5pq+CS/AAmS8VQLtkw4Ph/GiOILpGCtqvkiuCwYb
         0r7VoxsvczjyagshJE4yTZzRSs+jnKyaWGNLApUZH2KksODORXlRK7pQhSGnu/hUXkTK
         LhzW6za81JlonQvMd7ANKsHOH9ryUVlrPvRhVMUThjhQlJUICUbOLNh2UzMGaI/tApaM
         6vNA==
X-Gm-Message-State: APjAAAW0yWXUzYm0sm2TrtJqJQzLuS8J7gPAD+gokNXH2XZpVBUyUmDR
	VaCdjof2YhYU6y8av5B9qzrymjv3Um2rwDrBQCScQeAvJbXAFoKez1Y+OFQxEk1ER2ZxI/2Lq88
	FJSP5BtIGHSRU1EWve3EjKkgWaaYrUiRaSAB2TmHAwFiJzpSV9h1mADOqFaBlyOPoTw==
X-Received: by 2002:a9d:57c8:: with SMTP id q8mr120200oti.144.1558022811718;
        Thu, 16 May 2019 09:06:51 -0700 (PDT)
X-Received: by 2002:a9d:57c8:: with SMTP id q8mr120138oti.144.1558022810847;
        Thu, 16 May 2019 09:06:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558022810; cv=none;
        d=google.com; s=arc-20160816;
        b=drqJ6YQtUtnHE6uOiZdlqq2f9OfvD1CCQNufp5rMG9gUzaO+IIRWYaqBCF+JieUojt
         mq+wNI3/97eiDogHW+tsI1Qtwi/IIz1ftR7OI2wCCO4fcL3ssvwk3a386bbdf0Qz2rlR
         C+yZNAjPQBgqcn97TMIorzZsM61hRGXjB5OsRIExJ3MSQnAE7duA1viZty8JM6svA5IW
         KgbhxgU/b10VoZInu2nzFa07occUI1eF6h+TKXh+6gEKamBxwqKrDz0qRRiyKKYxwbm8
         ACFsJVDoYhOH9ihYfgzRg0q2R9k/yZi0Cq7HlxwQ1cOBkn7/Elbh3g5jtos8zVkAb50X
         itdQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=I4VKFuY3dBhk8M0E31KTPJJ8MMHDVcscAUiCzod5h4g=;
        b=ZXLLIcj/bHhOLJ+4Th2zBYIHG+jlWUDY/4EAmCaSgQIGHs4Z30vPM3wXAQPU9GXs4l
         Jk4NFTrFWqbD+Qfs8CfukKIvWIvqoa6mjApLnhdlMCQWoLvfgeMAM2XNFoXP1Ewve2K1
         5CAc4/iQb/Z6XF99QgEY9VJYxpSIJMvg7ytpOKBmR2vq0vLGaSubwLjNkx6AG4tZ4neU
         37dip7JCUnB8YyWhE3hZ3SvOJV4cKGth3bTgssoYw2ZQpkrL6cGZCY4Uy+KC6HgvXNsR
         IOcX4Q325V7zhnQ7gvCsgFAxG//WNlEXhCXaaFNqriQeDm9PStyiunghU+CClW+7ROa8
         2lmg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=H6xNrQHk;
       spf=pass (google.com: domain of jannh@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jannh@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f64sor1892949otb.183.2019.05.16.09.06.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 16 May 2019 09:06:50 -0700 (PDT)
Received-SPF: pass (google.com: domain of jannh@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=H6xNrQHk;
       spf=pass (google.com: domain of jannh@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jannh@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=I4VKFuY3dBhk8M0E31KTPJJ8MMHDVcscAUiCzod5h4g=;
        b=H6xNrQHksO0mY+GD8TjSIB/dl7gXte6ptfd1KwGU7WS9fv6i/tgp5PRwV1QwuOcLn8
         EQgegFWR1awHjfSGP4+gjgXMyl3Gl62XXSb7Mm7Nf1RXzKuaEetJoPJs6GSuS0KBL9vl
         Wub95qd5nDDIuDpLobcQrJAeLZp5nVs+LMne3mcxV43wLSgIfXzXurgIQYOiBUs8VKq4
         KUB/9oEuCvZV97lXvc2ABvfckVlCEpI9+rGFlz3y2hfmc98QPPAyHhjTuVHOdOUM3Bkm
         UOJay+FnLHdEk6rocRtjzEXrvs47hR0q26+/2U1SS5+d0iEBJ8VXwWGOZJ51SarUWMvq
         4fdw==
X-Google-Smtp-Source: APXvYqzler3soQWaPkgJTqHADqwjhXm5FObYmA+iecGHRrkmAWqb4Fk8pHSH7Qj3lDCx4Ml5SA54wKgEPHxudDIXDq4=
X-Received: by 2002:a9d:7347:: with SMTP id l7mr6353382otk.183.1558022810319;
 Thu, 16 May 2019 09:06:50 -0700 (PDT)
MIME-Version: 1.0
References: <20190516094234.9116-1-oleksandr@redhat.com> <20190516094234.9116-5-oleksandr@redhat.com>
 <CAG48ez2yXw_PJXO-mS=Qw5rkLpG6zDPd0saMhhGk09-du2bpaA@mail.gmail.com> <20190516142013.sf2vitmksvbkb33f@butterfly.localdomain>
In-Reply-To: <20190516142013.sf2vitmksvbkb33f@butterfly.localdomain>
From: Jann Horn <jannh@google.com>
Date: Thu, 16 May 2019 18:06:24 +0200
Message-ID: <CAG48ez0teQk+rVnRmr=xcM8PJ_8UZC3hSi7PABx-qunz+5=DGg@mail.gmail.com>
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

On Thu, May 16, 2019 at 4:20 PM Oleksandr Natalenko
<oleksandr@redhat.com> wrote:
> On Thu, May 16, 2019 at 12:00:24PM +0200, Jann Horn wrote:
> > On Thu, May 16, 2019 at 11:43 AM Oleksandr Natalenko
> > <oleksandr@redhat.com> wrote:
> > > Use previously introduced remote madvise knob to mark task's
> > > anonymous memory as mergeable.
> > >
> > > To force merging task's VMAs, "merge" hint is used:
> > >
> > >    # echo merge > /proc/<pid>/madvise
> > >
> > > Force unmerging is done similarly:
> > >
> > >    # echo unmerge > /proc/<pid>/madvise
> > >
> > > To achieve this, previously introduced ksm_madvise_*() helpers
> > > are used.
> >
> > Why does this not require PTRACE_MODE_ATTACH_FSCREDS to the target
> > process? Enabling KSM on another process is hazardous because it
> > significantly increases the attack surface for side channels.
> >
> > (Note that if you change this to require PTRACE_MODE_ATTACH_FSCREDS,
> > you'll want to use mm_access() in the ->open handler and drop the mm
> > in ->release. mm_access() from a ->write handler is not permitted.)
>
> Sounds reasonable. So, something similar to what mem_open() & friends do
> now:
>
> static int madvise_open(...)
> ...
>         struct task_struct *task = get_proc_task(inode);
> ...
>         if (task) {
>                 mm = mm_access(task, PTRACE_MODE_ATTACH_FSCREDS);
>                 put_task_struct(task);
>                 if (!IS_ERR_OR_NULL(mm)) {
>                         mmgrab(mm);
>                         mmput(mm);
> ...
>
> Then:
>
> static ssize_t madvise_write(...)
> ...
>         if (!mmget_not_zero(mm))
>                 goto out;
>
>         down_write(&mm->mmap_sem);
>         if (!mmget_still_valid(mm))
>                 goto skip_mm;
> ...
> skip_mm:
>         up_write(&mm->mmap_sem);
>
>         mmput(mm);
> out:
>         return ...;
>
> And, finally:
>
> static int madvise_release(...)
> ...
>                 mmdrop(mm);
> ...
>
> Right?

Yeah, that looks reasonable.

