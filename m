Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf1-f72.google.com (mail-lf1-f72.google.com [209.85.167.72])
	by kanga.kvack.org (Postfix) with ESMTP id 850B26B026F
	for <linux-mm@kvack.org>; Thu,  1 Nov 2018 06:09:52 -0400 (EDT)
Received: by mail-lf1-f72.google.com with SMTP id d5-v6so2591771lfa.1
        for <linux-mm@kvack.org>; Thu, 01 Nov 2018 03:09:52 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h196-v6sor8333888lfe.38.2018.11.01.03.09.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 01 Nov 2018 03:09:51 -0700 (PDT)
MIME-Version: 1.0
References: <1538226387-16600-1-git-send-email-ufo19890607@gmail.com> <20181031135049.GO32673@dhcp22.suse.cz>
In-Reply-To: <20181031135049.GO32673@dhcp22.suse.cz>
From: =?UTF-8?B?56a56Iif6ZSu?= <ufo19890607@gmail.com>
Date: Thu, 1 Nov 2018 18:09:39 +0800
Message-ID: <CAHCio2jpqfdgrqOqyXQ=HUc-9kzDmtaYXH+9juVQS6hBHhSdPA@mail.gmail.com>
Subject: Re: [PATCH v15 1/2] Reorganize the oom report in dump_header
Content-Type: multipart/alternative; boundary="0000000000008c3e120579979ecf"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: akpm@linux-foundation.org, rientjes@google.com, kirill.shutemov@linux.intel.com, aarcange@redhat.com, penguin-kernel@i-love.sakura.ne.jp, guro@fb.com, yang.s@alibaba-inc.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wind Yu <yuzhoujian@didichuxing.com>

--0000000000008c3e120579979ecf
Content-Type: text/plain; charset="UTF-8"

Hi Michal
The null pointer is possible when calling the dump_header, this bug was
detected by LKP. Below is the context 3 months ago.


On Mon 30-07-18 19:05:50, David Rientjes wrote:
> On Mon, 30 Jul 2018, Michal Hocko wrote:
>
> > On Mon 30-07-18 17:03:20, kernel test robot wrote:
> > [...]
> > > [    9.034310] BUG: KASAN: null-ptr-deref in dump_header+0x10c/0x448
> >
> > Could you faddr2line on the offset please?
> >
>
> It's possible that p is NULL when calling dump_header().  In this case we
> do not want to print any line concerning a victim because no oom kill has
> occurred.

> You are right. I have missed those.

> This code shouldn't be part of dump_header(), which is called from
> multiple contexts even when an oom kill has not occurred, and is
> ratelimited.  The single line output should be the canonical way that
> userspace parses the log for oom victims, we can't ratelimit it.
>
> The following would be a fix patch, but it will be broken if the cgroup
> aware oom killer is removed from -mm so that the oom_group stuff can be
> merged.

> cgroup aware oom killer is going to be replaced by a new implementation
> IIUC so the fix should be based on the yuzhoujian patch. Ideally to be
> resubmitted.

> I would just suggest adding it into a function
> dump_oom_summary(struct oom_control *oc, struct task_struct *p)

> yuzhoujian could you take care of that please?

I followed David's tip and call the new func dump_oom_summary in the
oom_kill_process.

> It's possible that p is NULL when calling dump_header().  In this case we
> do not want to print any line concerning a victim because no oom kill has
>occurred.

> This code shouldn't be part of dump_header(), which is called from
> multiple contexts even when an oom kill has not occurred, and is
> ratelimited.  The single line output should be the canonical way that
> userspace parses the log for oom victims, we can't ratelimit it.

> The following would be a fix patch, but it will be broken if the cgroup
> aware oom killer is removed from -mm so that the oom_group stuff can be
> merged.

--0000000000008c3e120579979ecf
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr">Hi Michal<div>The null pointer is possible when calling th=
e dump_header, this bug was detected by LKP. Below is the context 3 months =
ago.</div><div><br></div><div><br></div><div><span class=3D"gmail-im" style=
=3D"color:rgb(80,0,80)">On Mon 30-07-18 19:05:50, David Rientjes wrote:<br>=
&gt; On Mon, 30 Jul 2018, Michal Hocko wrote:<br>&gt;=C2=A0<br>&gt; &gt; On=
 Mon 30-07-18 17:03:20, kernel test robot wrote:<br>&gt; &gt; [...]<br>&gt;=
 &gt; &gt; [=C2=A0 =C2=A0 9.034310] BUG: KASAN: null-ptr-deref in dump_head=
er+0x10c/0x448<br>&gt; &gt;=C2=A0<br>&gt; &gt; Could you faddr2line on the =
offset please?<br>&gt; &gt;=C2=A0<br>&gt;=C2=A0<br>&gt; It&#39;s possible t=
hat p is NULL when calling dump_header().=C2=A0 In this case we=C2=A0<br>&g=
t; do not want to print any line concerning a victim because no oom kill ha=
s=C2=A0<br>&gt; occurred.<br><br></span>&gt; You are right. I have missed t=
hose.<span class=3D"gmail-im" style=3D"color:rgb(80,0,80)"><br><br>&gt; Thi=
s code shouldn&#39;t be part of dump_header(), which is called from=C2=A0<b=
r>&gt; multiple contexts even when an oom kill has not occurred, and is=C2=
=A0<br>&gt; ratelimited.=C2=A0 The single line output should be the canonic=
al way that=C2=A0<br>&gt; userspace parses the log for oom victims, we can&=
#39;t ratelimit it.<br>&gt;=C2=A0<br>&gt; The following would be a fix patc=
h, but it will be broken if the cgroup=C2=A0<br>&gt; aware oom killer is re=
moved from -mm so that the oom_group stuff can be=C2=A0<br>&gt; merged.<br>=
<br></span>&gt; cgroup aware oom killer is going to be replaced by a new im=
plementation<br>&gt; IIUC so the fix should be based on the yuzhoujian patc=
h. Ideally to be<br>&gt; resubmitted.<br><br>&gt; I would just suggest addi=
ng it into a function<br>&gt; dump_oom_summary(struct oom_control *oc, stru=
ct task_struct *p)<br><br>&gt; yuzhoujian could you take care of that pleas=
e?=C2=A0=C2=A0<br></div><div><br></div><div>I followed David&#39;s tip and =
call the new func dump_oom_summary in the oom_kill_process.</div><div><br><=
/div><div>&gt; It&#39;s possible that p is NULL when calling dump_header().=
=C2=A0 In this case we=C2=A0<br>&gt; do not want to print any line concerni=
ng a victim because no oom kill has=C2=A0<br>&gt;occurred.<br><br>&gt; This=
 code shouldn&#39;t be part of dump_header(), which is called from=C2=A0<br=
>&gt; multiple contexts even when an oom kill has not occurred, and is=C2=
=A0<br>&gt; ratelimited.=C2=A0 The single line output should be the canonic=
al way that=C2=A0<br>&gt; userspace parses the log for oom victims, we can&=
#39;t ratelimit it.<br><br>&gt; The following would be a fix patch, but it =
will be broken if the cgroup=C2=A0<br>&gt; aware oom killer is removed from=
 -mm so that the oom_group stuff can be=C2=A0<br>&gt; merged.=C2=A0</div><d=
iv>=C2=A0<br></div></div>

--0000000000008c3e120579979ecf--
