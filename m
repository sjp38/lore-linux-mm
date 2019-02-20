Return-Path: <SRS0=8949=Q3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4C3A9C10F01
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 04:30:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 02E5E21773
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 04:30:22 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=pex-com.20150623.gappssmtp.com header.i=@pex-com.20150623.gappssmtp.com header.b="BahdBTRj"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 02E5E21773
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=pex.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 849608E0003; Tue, 19 Feb 2019 23:30:22 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7F8728E0002; Tue, 19 Feb 2019 23:30:22 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6E7E28E0003; Tue, 19 Feb 2019 23:30:22 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 183988E0002
	for <linux-mm@kvack.org>; Tue, 19 Feb 2019 23:30:22 -0500 (EST)
Received: by mail-wr1-f69.google.com with SMTP id j16so8612163wrp.4
        for <linux-mm@kvack.org>; Tue, 19 Feb 2019 20:30:22 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=uznf6/JvabY3y7okt151mHPYpD/ff6hhiqmOBfFtboE=;
        b=fvYO+t5IonAWhjaOEupseyUHS8JWJgzNpzaARCCgFNbGO7N+SgiUEjKtZK6U/h2cmW
         agapj3kkHLAewDQikau2waKL7zHVwA1DN8yMdeUiC5V2U1pEV/vUEK37laFm7YUdsxRi
         Bi2ij6vWemnf25Gxf7DQxtCTva8eh9kiTt48tNxiHV7ik4IR6Qbac0DxM7LPi0+eCAKz
         4y+tsdI0su7aFgqc2GaTPOZLAM9uQAwbr2VYRBkBK5TJ1clpBnRvoRO60eZ6otK4GoyE
         ljklfILZNBNJon1LRNWgdeU5T7x8jIkm2vyOjvbfAKQtSxwy/QKV0WgXJiISEE+wWIXp
         CIyw==
X-Gm-Message-State: AHQUAuYJWoR6fptbCF3j1oAh3Abd0AJAg10LgP2uN+7AzKUFXtjaF51Q
	elnhNLwEDqcAWyOlX356epMSWpbT1swrpaC1dnq/GE+38+0lMUlmsh1xEzc+LLtRCfguvjHFLCk
	tNB1XsalXhySxO6gc9Qkm3xTK0E9qk4CLwuWtIUrVP7AVM/GMEqGtpEqTLPUw4w6VvAjg7i560F
	kdygTYBmpn4J+AaEdOLj9LEPEGrjIxEoCc6Tox5czkOzFGfA0jwt9rFUr0bxc1Df/2Q9wpe6n6y
	Ts+KyfgNe84lHHvvCEkEmzgCLURRqAzyvOH8bObCFyDXevmnWlq3SJk8Mn3RC3RxqcJ3ziLfCLG
	kRlE81gakVHHraHosDLW8q77awsGibo1BBv6wYQY5Nh3EDlJSmdQqo7IETYGCqoA715uyVQa3zO
	J
X-Received: by 2002:a05:600c:219a:: with SMTP id e26mr5189062wme.93.1550637021448;
        Tue, 19 Feb 2019 20:30:21 -0800 (PST)
X-Received: by 2002:a05:600c:219a:: with SMTP id e26mr5189012wme.93.1550637020131;
        Tue, 19 Feb 2019 20:30:20 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550637020; cv=none;
        d=google.com; s=arc-20160816;
        b=HvmLDW5D2ajw7a/Rha78sqXzcRrcG2cBPd2gYL/YwlPjPUG8ByBXWEsKO8pbMIx8eD
         ySNRw2/D3XI29cie8/u+rGMnAfVjlKQqsMt2LzvG1wQ9s8cX78pfVaDFrQOU2bAoK4v4
         QWDRRxiomuybLiNB6/+SRzNU7UeuwwvNu6MLms74yWJR1Qy7F/mDMuXUSH95L8BpxAFK
         WgAr47PfOtWNmoypb6Hydpn1/t4mDuMQMOU0Yp5Mul5l07UMUTTMJy+iYr76wxjwaJ7H
         l+LXI//tnLvLgfQF2ioHfS789Yn38lpoSTHL2VH2NsjHmRH58tLZftj8ORzwZq8wFEMg
         Ob4A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=uznf6/JvabY3y7okt151mHPYpD/ff6hhiqmOBfFtboE=;
        b=rqIzSpzT8CGH5LCNRtt1jYQWH54SWpepuRfXCFOGsPqRTPPlXAcmdvfMmwzujltMRy
         Ni5gAi+NZzrx4nkiyzwUNY/qH4dadkvpgcTw6h/VQM0e+GvDfwKC5P9AaUiGZKDLxCD7
         VFBRR6xp5qwXyGOe75mqaC+TNZyaCsTE9gopiBxT+jWpH+kX9Sz4W5SynLx85v7rYaWa
         z5rS91jAYjSe5j9LREvDoSreSRlJyJIU/HBDhVUFgtILUTXn7kIfDPlds+q6pKqoUKtv
         PVtYwk52cHJSfJ2FKJ34Yi0zEECtJPFAkYZWEsSLFGzmDCD37vyWrwOPyOnWc8FOYotE
         JVuQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@pex-com.20150623.gappssmtp.com header.s=20150623 header.b=BahdBTRj;
       spf=softfail (google.com: domain of transitioning stepan@pex.com does not designate 209.85.220.65 as permitted sender) smtp.mailfrom=stepan@pex.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=pex.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c190sor2734394wma.21.2019.02.19.20.30.19
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 19 Feb 2019 20:30:20 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning stepan@pex.com does not designate 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@pex-com.20150623.gappssmtp.com header.s=20150623 header.b=BahdBTRj;
       spf=softfail (google.com: domain of transitioning stepan@pex.com does not designate 209.85.220.65 as permitted sender) smtp.mailfrom=stepan@pex.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=pex.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=pex-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=uznf6/JvabY3y7okt151mHPYpD/ff6hhiqmOBfFtboE=;
        b=BahdBTRjUo8UMt8PooOmsomdt7QN5bJtqriLfvxcHZfcyLnxKMA8gfCrBkuUUtcy6p
         NhDY8JThTeQg9KKCrIZJjMObklPkytX3QUkTpC/41QAV7A2v/7nBUerbOIe3h1l7hDbB
         HU3D/4XBK9xUlOcZ2OvgaYFQZMXIcbUbEaChlTJti+eIOqNO+zX68hpTHY9QEMPGr5i+
         j1Fv9AAtsigx3y+7TSQcFpiV9OB1LQ3kDY5E+KxPtByQe46XHhBlr61SMXxtSdqbV8v1
         cedcLDCD4jLClQ3K6G7e0VaxGtevNQwKwm/A7VvuaZOW1+srZZBUIrYgOWuOp7EKiKXZ
         /Y3Q==
X-Google-Smtp-Source: AHgI3IaWuoMA/mt2jSqgSZn3K+2Xz6Pc4mpqAo6GjGeRZgbFt7ABdSB77K0Ox+Qb+1QoYWcnVzKwxyUamPYn9n5DNIg=
X-Received: by 2002:a1c:4c1a:: with SMTP id z26mr5109187wmf.139.1550637019512;
 Tue, 19 Feb 2019 20:30:19 -0800 (PST)
MIME-Version: 1.0
References: <20190220032245.2413-1-stepan@pex.com> <bc5d4f0f-8cbb-581a-5af3-2f178d6396fb@infradead.org>
In-Reply-To: <bc5d4f0f-8cbb-581a-5af3-2f178d6396fb@infradead.org>
From: "Bujnak, Stepan" <stepan@pex.com>
Date: Wed, 20 Feb 2019 05:30:08 +0100
Message-ID: <CAFZe2nThWxhwGAbDEPkT5nQdFR_kaRvDhhk1_1c-EvPdR7_xfw@mail.gmail.com>
Subject: Re: [PATCH] mm/oom: added option 'oom_dump_task_cmdline'
To: Randy Dunlap <rdunlap@infradead.org>
Cc: linux-mm@kvack.org, Jonathan Corbet <corbet@lwn.net>, mcgrof@kernel.org, 
	hannes@cmpxchg.org
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Feb 20, 2019 at 5:10 AM Randy Dunlap <rdunlap@infradead.org> wrote:
>
> Hi,
>
> Spell it out correctly (2 places):
This is not a typo. It actually refers to the oom_dump_tasks option,
in a sense that when that option is enabled,
this option (oom_dump_task_cmdline) additionally displays task
cmdline instead of task name.
>
>
> On 2/19/19 7:22 PM, Stepan Bujnak wrote:
> > When oom_dump_tasks is enabled, this option will try to display task
>
>   When oom_dump_task_cmdline is enabled,
>
> > cmdline instead of the command name in the system-wide task dump.
> >
> > This is useful in some cases e.g. on postgres server. If OOM killer is
> > invoked it will show a bunch of tasks called 'postgres'. With this
> > option enabled it will show additional information like the database
> > user, database name and what it is currently doing.
> >
> > Other example is python. Instead of just 'python' it will also show the
> > script name currently being executed.
> >
> > Signed-off-by: Stepan Bujnak <stepan@pex.com>
> > ---
> >  Documentation/sysctl/vm.txt | 10 ++++++++++
> >  include/linux/oom.h         |  1 +
> >  kernel/sysctl.c             |  7 +++++++
> >  mm/oom_kill.c               | 20 ++++++++++++++++++--
> >  4 files changed, 36 insertions(+), 2 deletions(-)
> >
> > diff --git a/Documentation/sysctl/vm.txt b/Documentation/sysctl/vm.txt
> > index 187ce4f599a2..74278c8c30d2 100644
> > --- a/Documentation/sysctl/vm.txt
> > +++ b/Documentation/sysctl/vm.txt
> > @@ -50,6 +50,7 @@ Currently, these files are in /proc/sys/vm:
> >  - nr_trim_pages         (only if CONFIG_MMU=n)
> >  - numa_zonelist_order
> >  - oom_dump_tasks
> > +- oom_dump_task_cmdline
> >  - oom_kill_allocating_task
> >  - overcommit_kbytes
> >  - overcommit_memory
> > @@ -639,6 +640,15 @@ The default value is 1 (enabled).
> >
> >  ==============================================================
> >
> > +oom_dump_task_cmdline
> > +
> > +When oom_dump_tasks is enabled, this option will try to display task cmdline
>
>    When oom_dump_task_cmdline is enabled,
>
> > +instead of the command name in the system-wide task dump.
> > +
> > +The default value is 0 (disabled).
> > +
> > +==============================================================
> > +
> >  oom_kill_allocating_task
> >
> >  This enables or disables killing the OOM-triggering task in
> > diff --git a/include/linux/oom.h b/include/linux/oom.h
> > index d07992009265..461b15b3b695 100644
> > --- a/include/linux/oom.h
> > +++ b/include/linux/oom.h
> > @@ -125,6 +125,7 @@ extern struct task_struct *find_lock_task_mm(struct task_struct *p);
> >
> >  /* sysctls */
> >  extern int sysctl_oom_dump_tasks;
> > +extern int sysctl_oom_dump_task_cmdline;
> >  extern int sysctl_oom_kill_allocating_task;
> >  extern int sysctl_panic_on_oom;
> >  #endif /* _INCLUDE_LINUX_OOM_H */
> > diff --git a/kernel/sysctl.c b/kernel/sysctl.c
> > index ba4d9e85feb8..4edc5f8e6cf9 100644
> > --- a/kernel/sysctl.c
> > +++ b/kernel/sysctl.c
> > @@ -1288,6 +1288,13 @@ static struct ctl_table vm_table[] = {
> >               .mode           = 0644,
> >               .proc_handler   = proc_dointvec,
> >       },
> > +     {
> > +             .procname       = "oom_dump_task_cmdline",
> > +             .data           = &sysctl_oom_dump_task_cmdline,
> > +             .maxlen         = sizeof(sysctl_oom_dump_task_cmdline),
> > +             .mode           = 0644,
> > +             .proc_handler   = proc_dointvec,
> > +     },
> >       {
> >               .procname       = "overcommit_ratio",
> >               .data           = &sysctl_overcommit_ratio,
>
>
> thanks.
> --
> ~Randy

