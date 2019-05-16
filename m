Return-Path: <SRS0=l6tt=TQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 455C7C04E87
	for <linux-mm@archiver.kernel.org>; Thu, 16 May 2019 10:00:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 081852087E
	for <linux-mm@archiver.kernel.org>; Thu, 16 May 2019 10:00:53 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="rusCImqc"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 081852087E
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8A85E6B0005; Thu, 16 May 2019 06:00:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 85A146B0006; Thu, 16 May 2019 06:00:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 748FD6B0007; Thu, 16 May 2019 06:00:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f200.google.com (mail-oi1-f200.google.com [209.85.167.200])
	by kanga.kvack.org (Postfix) with ESMTP id 47D486B0005
	for <linux-mm@kvack.org>; Thu, 16 May 2019 06:00:53 -0400 (EDT)
Received: by mail-oi1-f200.google.com with SMTP id s64so1172453oia.15
        for <linux-mm@kvack.org>; Thu, 16 May 2019 03:00:53 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=dC3aSgv+o3HSYvM8J8FMKymuhEQ4FThUEnqG0ntB4g0=;
        b=NJuFQrFzA3YC4zzCHO2Zwxl6Sh9+7CaGsyaQdBjov/yH3YcCRdmGYUqtHkrslQd2ws
         c5Zztl4qGe2jc4h/w5aTKWzqSaRNb7OOxjQxckuWsV2dWyq1GWHsK1BytXRGI35AQ6CH
         fvdGZIqatIJS48s9pN0dv7qzj344BOd0UWi7WEEnsu3QO7sf8YvmuX1rojGX90tb8gF1
         l6ptg/gkOlXBT+YbGUwq+vW6Jt24GtzvWdBC1kyvcKwT6dc9/R4LGaJ7Bs4iqWA8VnsY
         d1uXbaGbdSdTqPhZRcnLE3cSJttIOfeGf8LDS6EpROPsjb4ROfvOlk42ubLl+JvKYuL5
         Qo2Q==
X-Gm-Message-State: APjAAAU3NK1ej1Av/9hmbAnyTl3NmWHsMbzJZZ/mdKdyn4f5WlCGGyYq
	k47QbAeSLizIS8QVdQXtbe6KXbfyrJiBAnm38kwjQqGs3tzVqlhGGGShjbRPe7/JlNQD9cvLekp
	qlkhBzrSEqpUZBiIblyedhJHN9RedcMR2B95uU4KzSdrleaA0dqlLk1OftOnCQliEkg==
X-Received: by 2002:a9d:7a53:: with SMTP id z19mr30589317otm.260.1558000852835;
        Thu, 16 May 2019 03:00:52 -0700 (PDT)
X-Received: by 2002:a9d:7a53:: with SMTP id z19mr30589250otm.260.1558000851806;
        Thu, 16 May 2019 03:00:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558000851; cv=none;
        d=google.com; s=arc-20160816;
        b=yZIT4/WwHhtmdRBuG+89P3rLYa3+n6w1vaVfM/5sMm34Njyf93fGgpt8YF71PSk/ix
         4iYiPBZpGV8NtcH5pPZEJtpHT8iKVA+Zmz3N+05+b0dxNy12AKAL3A08GVPpSwHphSTD
         Z4260LUL5xCqQF5ojTGG++CzF38/+PrBoC09m8vxjlcya6zjeONDphRFQFUF0BpwQsv/
         WwfH04vLUq5h5VznJvvarI2BanwnwO7k8SuflJ7pOcTBax1ogFVR+OYi5MPmfdSz6KMG
         wUIPfqSreQ+bvLqIKETkNfIE8uPf/Qo6+mfPmtPoPXG2uFaE2i/10c2aolSS5QHpkD2X
         tU7Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=dC3aSgv+o3HSYvM8J8FMKymuhEQ4FThUEnqG0ntB4g0=;
        b=XFx6sPD05yTbehYUOPoOXrO9tnFZhWUHYu4i1hQlKPs+oiQXilwlYXNDyaCPQ7MmTm
         4f4JR18ufIEf9+DQhBK1n/IA69z9MnZ2llxJRihkMoXiEx+sI/SXq+iXp7Uq2mRNJmgR
         bgShiH+bvOW2gehMoDGMFV31WCT91buSZreGMDwnDq6vgoK6c53mc+P78R2IHuW2Q+AI
         qmW50zDuHXAHmeuv1U3UORQxDuOSBXd+EWoPjwjgqa1P+Wijliz1q7mcLhnAU320k1Je
         QDQzMEnSGROddYkEImGXKsb3VzS3pwyP91LQaHav7niM53+7U+3jyWfJEvhoU3XCwil1
         sBZw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=rusCImqc;
       spf=pass (google.com: domain of jannh@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jannh@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e17sor2023079oib.70.2019.05.16.03.00.51
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 16 May 2019 03:00:51 -0700 (PDT)
Received-SPF: pass (google.com: domain of jannh@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=rusCImqc;
       spf=pass (google.com: domain of jannh@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jannh@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=dC3aSgv+o3HSYvM8J8FMKymuhEQ4FThUEnqG0ntB4g0=;
        b=rusCImqcsRelViq7BjTj8x6kkzQ7cL9BId6Q2hif54CzbiF2xexI8tw8D5bQ3Q6HLt
         l4Fc8osLWvc/mFIQ0lcIGpQelUQltkxqLGCz+/Oe6Un0I0xiembCGtk90t1JUC8cFExL
         hiM8oJYcfzEbVRzLR+jVGIv2X+WSy8ArgEm6sDYpKjifpSCcPcFIaQ42Qg4wirz6BBHO
         RKDlH9nba+5XQn6n19kOSVR/TU/lT++yDt/HW6vWFf86nDvW72knrug0SBpJeZIKzOOD
         W5xi2wekab69fIhm12WD6de9sXy3LG6XrRTh7bl6poYUh4ZyEl4VUbR4nVo667mnp3wj
         UpsA==
X-Google-Smtp-Source: APXvYqw8UaGLIZvpXm/eLsQS3GmsqOIGz12mauFeRh7e/B8z5XURykeEcCxzQqp0PTqaQVSeftW47QM4HusRyiTUL58=
X-Received: by 2002:aca:180d:: with SMTP id h13mr9485857oih.39.1558000850840;
 Thu, 16 May 2019 03:00:50 -0700 (PDT)
MIME-Version: 1.0
References: <20190516094234.9116-1-oleksandr@redhat.com> <20190516094234.9116-5-oleksandr@redhat.com>
In-Reply-To: <20190516094234.9116-5-oleksandr@redhat.com>
From: Jann Horn <jannh@google.com>
Date: Thu, 16 May 2019 12:00:24 +0200
Message-ID: <CAG48ez2yXw_PJXO-mS=Qw5rkLpG6zDPd0saMhhGk09-du2bpaA@mail.gmail.com>
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

On Thu, May 16, 2019 at 11:43 AM Oleksandr Natalenko
<oleksandr@redhat.com> wrote:
> Use previously introduced remote madvise knob to mark task's
> anonymous memory as mergeable.
>
> To force merging task's VMAs, "merge" hint is used:
>
>    # echo merge > /proc/<pid>/madvise
>
> Force unmerging is done similarly:
>
>    # echo unmerge > /proc/<pid>/madvise
>
> To achieve this, previously introduced ksm_madvise_*() helpers
> are used.

Why does this not require PTRACE_MODE_ATTACH_FSCREDS to the target
process? Enabling KSM on another process is hazardous because it
significantly increases the attack surface for side channels.

(Note that if you change this to require PTRACE_MODE_ATTACH_FSCREDS,
you'll want to use mm_access() in the ->open handler and drop the mm
in ->release. mm_access() from a ->write handler is not permitted.)

[...]
> @@ -2960,15 +2962,63 @@ static int proc_stack_depth(struct seq_file *m, struct pid_namespace *ns,
>  static ssize_t madvise_write(struct file *file, const char __user *buf,
>                 size_t count, loff_t *ppos)
>  {
> +       /* For now, only KSM hints are implemented */
> +#ifdef CONFIG_KSM
> +       char buffer[PROC_NUMBUF];
> +       int behaviour;
>         struct task_struct *task;
> +       struct mm_struct *mm;
> +       int err = 0;
> +       struct vm_area_struct *vma;
> +
> +       memset(buffer, 0, sizeof(buffer));
> +       if (count > sizeof(buffer) - 1)
> +               count = sizeof(buffer) - 1;
> +       if (copy_from_user(buffer, buf, count))
> +               return -EFAULT;
> +
> +       if (!memcmp("merge", buffer, min(sizeof("merge")-1, count)))

This means that you also match on something like "mergeblah". Just use strcmp().

> +               behaviour = MADV_MERGEABLE;
> +       else if (!memcmp("unmerge", buffer, min(sizeof("unmerge")-1, count)))
> +               behaviour = MADV_UNMERGEABLE;
> +       else
> +               return -EINVAL;
>
>         task = get_proc_task(file_inode(file));
>         if (!task)
>                 return -ESRCH;
>
> +       mm = get_task_mm(task);
> +       if (!mm) {
> +               err = -EINVAL;
> +               goto out_put_task_struct;
> +       }
> +
> +       down_write(&mm->mmap_sem);

Should a check for mmget_still_valid(mm) be inserted here? See commit
04f5866e41fb70690e28397487d8bd8eea7d712a.

> +       switch (behaviour) {
> +       case MADV_MERGEABLE:
> +       case MADV_UNMERGEABLE:

This switch isn't actually necessary at this point, right?

> +               vma = mm->mmap;
> +               while (vma) {
> +                       if (behaviour == MADV_MERGEABLE)
> +                               ksm_madvise_merge(vma->vm_mm, vma, &vma->vm_flags);
> +                       else
> +                               ksm_madvise_unmerge(vma, vma->vm_start, vma->vm_end, &vma->vm_flags);
> +                       vma = vma->vm_next;
> +               }
> +               break;
> +       }
> +       up_write(&mm->mmap_sem);
> +
> +       mmput(mm);
> +
> +out_put_task_struct:
>         put_task_struct(task);
>
> -       return count;
> +       return err ? err : count;
> +#else
> +       return -EINVAL;
> +#endif /* CONFIG_KSM */
>  }

