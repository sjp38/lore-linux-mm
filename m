Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f200.google.com (mail-lj1-f200.google.com [209.85.208.200])
	by kanga.kvack.org (Postfix) with ESMTP id E7BC06B0005
	for <linux-mm@kvack.org>; Thu,  5 Jul 2018 07:23:35 -0400 (EDT)
Received: by mail-lj1-f200.google.com with SMTP id g21-v6so705358ljj.15
        for <linux-mm@kvack.org>; Thu, 05 Jul 2018 04:23:35 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r3-v6sor1323238ljc.75.2018.07.05.04.23.33
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 05 Jul 2018 04:23:33 -0700 (PDT)
MIME-Version: 1.0
References: <1530376739-20459-1-git-send-email-ufo19890607@gmail.com>
 <CAHp75VdaEJgYFUX_MkthFPhimVtJStcinm1P4S-iGfJHvSeiyA@mail.gmail.com>
 <CAHCio2jv-xtnNbJ8beokueh-VQ6zZgF1hAFBJKHCNyuOuz2KxA@mail.gmail.com> <20180704081710.GH22503@dhcp22.suse.cz>
In-Reply-To: <20180704081710.GH22503@dhcp22.suse.cz>
From: =?UTF-8?B?56a56Iif6ZSu?= <ufo19890607@gmail.com>
Date: Thu, 5 Jul 2018 19:23:22 +0800
Message-ID: <CAHCio2hf-kfmVgz=KCvE9L4nPZxEVcFrxv2R1Y11etG=KvyBwg@mail.gmail.com>
Subject: Re: [PATCH v11 1/2] Refactor part of the oom report in dump_header
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: Andy Shevchenko <andy.shevchenko@gmail.com>, akpm@linux-foundation.org, rientjes@google.com, kirill.shutemov@linux.intel.com, aarcange@redhat.com, penguin-kernel@i-love.sakura.ne.jp, guro@fb.com, yang.s@alibaba-inc.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wind Yu <yuzhoujian@didichuxing.com>

Hi Michal and Andy
The enum oom_constraint  will be added in the struct oom_control.  So
I still think I should define it in oom.h.
Michal Hocko <mhocko@kernel.org> =E4=BA=8E2018=E5=B9=B47=E6=9C=884=E6=97=A5=
=E5=91=A8=E4=B8=89 =E4=B8=8B=E5=8D=884:17=E5=86=99=E9=81=93=EF=BC=9A
>
> On Wed 04-07-18 10:25:30, =E7=A6=B9=E8=88=9F=E9=94=AE wrote:
> > Hi Andy
> > The const char array need to be used by the new func
> > mem_cgroup_print_oom_context and some funcs in oom_kill.c in the
> > second patch.
>
> Just declare it in oom.h and define in oom.c
> --
> Michal Hocko
> SUSE Labs
