Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f199.google.com (mail-ua0-f199.google.com [209.85.217.199])
	by kanga.kvack.org (Postfix) with ESMTP id 967AC6B0008
	for <linux-mm@kvack.org>; Tue,  3 Jul 2018 13:25:37 -0400 (EDT)
Received: by mail-ua0-f199.google.com with SMTP id o16-v6so790158ual.14
        for <linux-mm@kvack.org>; Tue, 03 Jul 2018 10:25:37 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v7-v6sor610151uak.81.2018.07.03.10.25.36
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 03 Jul 2018 10:25:36 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1530376739-20459-1-git-send-email-ufo19890607@gmail.com>
References: <1530376739-20459-1-git-send-email-ufo19890607@gmail.com>
From: Andy Shevchenko <andy.shevchenko@gmail.com>
Date: Tue, 3 Jul 2018 20:25:33 +0300
Message-ID: <CAHp75VdaEJgYFUX_MkthFPhimVtJStcinm1P4S-iGfJHvSeiyA@mail.gmail.com>
Subject: Re: [PATCH v11 1/2] Refactor part of the oom report in dump_header
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: ufo19890607@gmail.com
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, David Rientjes <rientjes@google.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, aarcange@redhat.com, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, guro@fb.com, yang.s@alibaba-inc.com, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, yuzhoujian@didichuxing.com

On Sat, Jun 30, 2018 at 7:38 PM,  <ufo19890607@gmail.com> wrote:
> From: yuzhoujian <yuzhoujian@didichuxing.com>
>
> The current system wide oom report prints information about the victim
> and the allocation context and restrictions. It, however, doesn't
> provide any information about memory cgroup the victim belongs to. This
> information can be interesting for container users because they can find
> the victim's container much more easily.
>
> I follow the advices of David Rientjes and Michal Hocko, and refactor
> part of the oom report. After this patch, users can get the memcg's
> path from the oom report and check the certain container more quickly.
>
> The oom print info after this patch:
> oom-kill:constraint=3D<constraint>,nodemask=3D<nodemask>,oom_memcg=3D<mem=
cg>,task_memcg=3D<memcg>,task=3D<comm>,pid=3D<pid>,uid=3D<uid>


> +static const char * const oom_constraint_text[] =3D {
> +       [CONSTRAINT_NONE] =3D "CONSTRAINT_NONE",
> +       [CONSTRAINT_CPUSET] =3D "CONSTRAINT_CPUSET",
> +       [CONSTRAINT_MEMORY_POLICY] =3D "CONSTRAINT_MEMORY_POLICY",
> +       [CONSTRAINT_MEMCG] =3D "CONSTRAINT_MEMCG",
> +};

I'm not sure why we have this in the header.

This produces a lot of noise when W=3D1.

In file included from
/home/andy/prj/linux-topic-mfld/include/linux/memcontrol.h:31:0,
                from /home/andy/prj/linux-topic-mfld/include/net/sock.h:58,
                from /home/andy/prj/linux-topic-mfld/include/linux/tcp.h:23=
,
                from /home/andy/prj/linux-topic-mfld/include/linux/ipv6.h:8=
7,
                from /home/andy/prj/linux-topic-mfld/include/net/ipv6.h:16,
                from
/home/andy/prj/linux-topic-mfld/net/ipv4/netfilter/nf_log_ipv4.c:17:
/home/andy/prj/linux-topic-mfld/include/linux/oom.h:32:27: warning:
=E2=80=98oom_constraint_text=E2=80=99 defined but not used [-W
unused-const-variable=3D]
static const char * const oom_constraint_text[] =3D {
                          ^~~~~~~~~~~~~~~~~~~
 CC [M]  net/ipv4/netfilter/iptable_nat.o


If you need (but looking at the code you actually don't if I didn't
miss anything) it in several places, just export.
Otherwise put it back to memcontrol.c.

--=20
With Best Regards,
Andy Shevchenko
