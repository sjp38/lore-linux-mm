Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5703B6B0003
	for <linux-mm@kvack.org>; Sun,  3 Jun 2018 22:41:25 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id m9-v6so836689lfb.15
        for <linux-mm@kvack.org>; Sun, 03 Jun 2018 19:41:25 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p11-v6sor5232884lfp.7.2018.06.03.19.41.23
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 03 Jun 2018 19:41:23 -0700 (PDT)
MIME-Version: 1.0
References: <1527940734-35161-1-git-send-email-ufo19890607@gmail.com>
 <1527940734-35161-2-git-send-email-ufo19890607@gmail.com> <20180603124941.GA29497@rapoport-lnx>
 <CAHCio2ifo3SNH9E3GX2=q1a=MNiNnoCu+2a++yX5_xMBheya5g@mail.gmail.com>
In-Reply-To: <CAHCio2ifo3SNH9E3GX2=q1a=MNiNnoCu+2a++yX5_xMBheya5g@mail.gmail.com>
From: =?UTF-8?B?56a56Iif6ZSu?= <ufo19890607@gmail.com>
Date: Mon, 4 Jun 2018 10:41:10 +0800
Message-ID: <CAHCio2in8NXZRanE9MS0VsSZxKaSvTy96TF59hODoNCxuQTz5A@mail.gmail.com>
Subject: Re: [PATCH v7 2/2] Refactor part of the oom report in dump_header
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: rppt@linux.vnet.ibm.com
Cc: akpm@linux-foundation.org, mhocko@suse.com, rientjes@google.com, kirill.shutemov@linux.intel.com, aarcange@redhat.com, penguin-kernel@i-love.sakura.ne.jp, guro@fb.com, yang.s@alibaba-inc.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wind Yu <yuzhoujian@didichuxing.com>

Hi Tetsuo
> Since origin_memcg_name is printed for both memcg OOM and !memcg OOM, it =
is strange that origin_memcg_name is updated only when memcg !=3D NULL. Hav=
e you really tested !memcg OOM case?

if memcg =3D=3D NULL , origin_memcg_name will also be NULL, so the length
of it is 0. origin_memcg_name will be "(null)". I've tested !memcg OOM
case with CONFIG_MEMCG and !CONFIG_MEMCG, and found nothing wrong.

Thanks
Wind
=E7=A6=B9=E8=88=9F=E9=94=AE <ufo19890607@gmail.com> =E4=BA=8E2018=E5=B9=B46=
=E6=9C=884=E6=97=A5=E5=91=A8=E4=B8=80 =E4=B8=8A=E5=8D=889:58=E5=86=99=E9=81=
=93=EF=BC=9A
>
> Hi Mike
> > Please keep the brief description of the function actually brief and mo=
ve the detailed explanation after the parameters description.
> Thanks for your advice.
>
> > The allocation constraint is detected by the dump_header() callers, why=
 not just use it here?
> David suggest that constraint need to be printed in the oom report, so
> I add the enum variable in this function.
>
> Thanks
> Wind
