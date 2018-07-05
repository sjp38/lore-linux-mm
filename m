Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f198.google.com (mail-ua0-f198.google.com [209.85.217.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5CC6D6B0007
	for <linux-mm@kvack.org>; Thu,  5 Jul 2018 08:24:39 -0400 (EDT)
Received: by mail-ua0-f198.google.com with SMTP id z1-v6so2325033ual.15
        for <linux-mm@kvack.org>; Thu, 05 Jul 2018 05:24:39 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i61-v6sor1349326uad.77.2018.07.05.05.24.38
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 05 Jul 2018 05:24:38 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAHCio2hf-kfmVgz=KCvE9L4nPZxEVcFrxv2R1Y11etG=KvyBwg@mail.gmail.com>
References: <1530376739-20459-1-git-send-email-ufo19890607@gmail.com>
 <CAHp75VdaEJgYFUX_MkthFPhimVtJStcinm1P4S-iGfJHvSeiyA@mail.gmail.com>
 <CAHCio2jv-xtnNbJ8beokueh-VQ6zZgF1hAFBJKHCNyuOuz2KxA@mail.gmail.com>
 <20180704081710.GH22503@dhcp22.suse.cz> <CAHCio2hf-kfmVgz=KCvE9L4nPZxEVcFrxv2R1Y11etG=KvyBwg@mail.gmail.com>
From: Andy Shevchenko <andy.shevchenko@gmail.com>
Date: Thu, 5 Jul 2018 15:24:37 +0300
Message-ID: <CAHp75Vecv43Q6_LPaLd4YR3OowVKgpR7YJe2Od2Hj_KU7=kEGw@mail.gmail.com>
Subject: Re: [PATCH v11 1/2] Refactor part of the oom report in dump_header
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?UTF-8?B?56a56Iif6ZSu?= <ufo19890607@gmail.com>
Cc: mhocko@kernel.org, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, aarcange@redhat.com, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, guro@fb.com, yang.s@alibaba-inc.com, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Wind Yu <yuzhoujian@didichuxing.com>

On Thu, Jul 5, 2018 at 2:23 PM, =E7=A6=B9=E8=88=9F=E9=94=AE <ufo19890607@gm=
ail.com> wrote:
> Hi Michal and Andy

> The enum oom_constraint  will be added in the struct oom_control.  So
> I still think I should define it in oom.h.

You missed the point. I'm talking about an array of string literals.
Please, check what the warning I got from the compiler.

> Michal Hocko <mhocko@kernel.org> =E4=BA=8E2018=E5=B9=B47=E6=9C=884=E6=97=
=A5=E5=91=A8=E4=B8=89 =E4=B8=8B=E5=8D=884:17=E5=86=99=E9=81=93=EF=BC=9A
>>
>> On Wed 04-07-18 10:25:30, =E7=A6=B9=E8=88=9F=E9=94=AE wrote:
>> > Hi Andy
>> > The const char array need to be used by the new func
>> > mem_cgroup_print_oom_context and some funcs in oom_kill.c in the
>> > second patch.
>>
>> Just declare it in oom.h and define in oom.c
>> --
>> Michal Hocko
>> SUSE Labs



--=20
With Best Regards,
Andy Shevchenko
