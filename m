Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2BCA46B0292
	for <linux-mm@kvack.org>; Tue,  8 Aug 2017 04:16:10 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id z3so26213231pfk.4
        for <linux-mm@kvack.org>; Tue, 08 Aug 2017 01:16:10 -0700 (PDT)
Received: from mail-pg0-x232.google.com (mail-pg0-x232.google.com. [2607:f8b0:400e:c05::232])
        by mx.google.com with ESMTPS id d11si534844pfk.253.2017.08.08.01.16.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Aug 2017 01:16:09 -0700 (PDT)
Received: by mail-pg0-x232.google.com with SMTP id v189so11982083pgd.2
        for <linux-mm@kvack.org>; Tue, 08 Aug 2017 01:16:09 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170808080821.GA31730@bbox>
References: <20170802000818.4760-7-namit@vmware.com> <20170808011923.GE25554@yexl-desktop>
 <20170808022830.GA28570@bbox> <93CA4B47-95C2-43A2-8E92-B142CAB1DAF7@gmail.com>
 <970B5DC5-BFC2-461E-AC46-F71B3691D301@gmail.com> <20170808080821.GA31730@bbox>
From: Nadav Amit <nadav.amit@gmail.com>
Date: Tue, 8 Aug 2017 01:16:08 -0700
Message-ID: <CAKLkAJ48yH1hT2UQvxGf1i5Zuceasyu_4og3sqADuxOCD81c0Q@mail.gmail.com>
Subject: Re: [lkp-robot] [mm] 7674270022: will-it-scale.per_process_ops -19.3% regression
Content-Type: multipart/alternative; boundary="f403045e3dfa58c50c0556399359"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: linux-arch@vger.kernel.org, Ingo Molnar <mingo@redhat.com>, Jeff Dike <jdike@addtoit.com>, Andrew Morton <akpm@linux-foundation.org>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, "David S. Miller" <davem@davemloft.net>, lkp@01.org, Russell King <linux@armlinux.org.uk>, Tony Luck <tony.luck@intel.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, kernel test robot <xiaolong.ye@intel.com>

--f403045e3dfa58c50c0556399359
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Aug 8, 2017 01:08, "Minchan Kim" <minchan@kernel.org> wrote:

On Mon, Aug 07, 2017 at 10:51:00PM -0700, Nadav Amit wrote:
> Nadav Amit <nadav.amit@gmail.com> wrote:
>
> > Minchan Kim <minchan@kernel.org> wrote:
> >
> >> Hi,
> >>
> >> On Tue, Aug 08, 2017 at 09:19:23AM +0800, kernel test robot wrote:
> >>> Greeting,
> >>>
> >>> FYI, we noticed a -19.3% regression of will-it-scale.per_process_ops
due to commit:
> >>>
> >>>
> >>> commit: 76742700225cad9df49f05399381ac3f1ec3dc60 ("mm: fix
MADV_[FREE|DONTNEED] TLB flush miss problem")
> >>> url: https://github.com/0day-ci/linux/commits/Nadav-Amit/mm-
migrate-prevent-racy-access-to-tlb_flush_pending/20170802-205715
> >>>
> >>>
> >>> in testcase: will-it-scale
> >>> on test machine: 88 threads Intel(R) Xeon(R) CPU E5-2699 v4 @ 2.20GHz
with 64G memory
> >>> with following parameters:
> >>>
> >>>   nr_task: 16
> >>>   mode: process
> >>>   test: brk1
> >>>   cpufreq_governor: performance
> >>>
> >>> test-description: Will It Scale takes a testcase and runs it from 1
through to n parallel copies to see if the testcase will scale. It builds
both a process and threads based test in order to see any differences
between the two.
> >>> test-url: https://github.com/antonblanchard/will-it-scale
> >>
> >> Thanks for the report.
> >> Could you explain what kinds of workload you are testing?
> >>
> >> Does it calls frequently madvise(MADV_DONTNEED) in parallel on multipl=
e
> >> threads?
> >
> > According to the description it is "testcase:brk increase/decrease of
one
> > page=E2=80=9D. According to the mode it spawns multiple processes, not =
threads.
> >
> > Since a single page is unmapped each time, and the iTLB-loads increase
> > dramatically, I would suspect that for some reason a full TLB flush is
> > caused during do_munmap().
> >
> > If I find some free time, I=E2=80=99ll try to profile the workload - bu=
t feel
free
> > to beat me to it.
>
> The root-cause appears to be that tlb_finish_mmu() does not call
> dec_tlb_flush_pending() - as it should. Any chance you can take care of
it?

Oops, but with second looking, it seems it's not my fault. ;-)
https://marc.info/?l=3Dlinux-mm&m=3D150156699114088&w=3D2


Err... Sorry for that...

--f403045e3dfa58c50c0556399359
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"auto"><br><div class=3D"gmail_extra" dir=3D"auto"><br><div clas=
s=3D"gmail_quote">On Aug 8, 2017 01:08, &quot;Minchan Kim&quot; &lt;<a href=
=3D"mailto:minchan@kernel.org">minchan@kernel.org</a>&gt; wrote:<br type=3D=
"attribution"><blockquote class=3D"quote" style=3D"margin:0 0 0 .8ex;border=
-left:1px #ccc solid;padding-left:1ex"><div class=3D"elided-text">On Mon, A=
ug 07, 2017 at 10:51:00PM -0700, Nadav Amit wrote:<br>
&gt; Nadav Amit &lt;<a href=3D"mailto:nadav.amit@gmail.com">nadav.amit@gmai=
l.com</a>&gt; wrote:<br>
&gt;<br>
&gt; &gt; Minchan Kim &lt;<a href=3D"mailto:minchan@kernel.org">minchan@ker=
nel.org</a>&gt; wrote:<br>
&gt; &gt;<br>
&gt; &gt;&gt; Hi,<br>
&gt; &gt;&gt;<br>
&gt; &gt;&gt; On Tue, Aug 08, 2017 at 09:19:23AM +0800, kernel test robot w=
rote:<br>
&gt; &gt;&gt;&gt; Greeting,<br>
&gt; &gt;&gt;&gt;<br>
&gt; &gt;&gt;&gt; FYI, we noticed a -19.3% regression of will-it-scale.per_=
process_ops due to commit:<br>
&gt; &gt;&gt;&gt;<br>
&gt; &gt;&gt;&gt;<br>
&gt; &gt;&gt;&gt; commit: 76742700225cad9df49f05399381ac<wbr>3f1ec3dc60 (&q=
uot;mm: fix MADV_[FREE|DONTNEED] TLB flush miss problem&quot;)<br>
&gt; &gt;&gt;&gt; url: <a href=3D"https://github.com/0day-ci/linux/commits/=
Nadav-Amit/mm-migrate-prevent-racy-access-to-tlb_flush_pending/20170802-205=
715" rel=3D"noreferrer" target=3D"_blank">https://github.com/0day-ci/<wbr>l=
inux/commits/Nadav-Amit/mm-<wbr>migrate-prevent-racy-access-<wbr>to-tlb_flu=
sh_pending/20170802-<wbr>205715</a><br>
&gt; &gt;&gt;&gt;<br>
&gt; &gt;&gt;&gt;<br>
&gt; &gt;&gt;&gt; in testcase: will-it-scale<br>
&gt; &gt;&gt;&gt; on test machine: 88 threads Intel(R) Xeon(R) CPU E5-2699 =
v4 @ 2.20GHz with 64G memory<br>
&gt; &gt;&gt;&gt; with following parameters:<br>
&gt; &gt;&gt;&gt;<br>
&gt; &gt;&gt;&gt;=C2=A0 =C2=A0nr_task: 16<br>
&gt; &gt;&gt;&gt;=C2=A0 =C2=A0mode: process<br>
&gt; &gt;&gt;&gt;=C2=A0 =C2=A0test: brk1<br>
&gt; &gt;&gt;&gt;=C2=A0 =C2=A0cpufreq_governor: performance<br>
&gt; &gt;&gt;&gt;<br>
&gt; &gt;&gt;&gt; test-description: Will It Scale takes a testcase and runs=
 it from 1 through to n parallel copies to see if the testcase will scale. =
It builds both a process and threads based test in order to see any differe=
nces between the two.<br>
&gt; &gt;&gt;&gt; test-url: <a href=3D"https://github.com/antonblanchard/wi=
ll-it-scale" rel=3D"noreferrer" target=3D"_blank">https://github.com/<wbr>a=
ntonblanchard/will-it-scale</a><br>
&gt; &gt;&gt;<br>
&gt; &gt;&gt; Thanks for the report.<br>
&gt; &gt;&gt; Could you explain what kinds of workload you are testing?<br>
&gt; &gt;&gt;<br>
&gt; &gt;&gt; Does it calls frequently madvise(MADV_DONTNEED) in parallel o=
n multiple<br>
&gt; &gt;&gt; threads?<br>
&gt; &gt;<br>
&gt; &gt; According to the description it is &quot;testcase:brk increase/de=
crease of one<br>
&gt; &gt; page=E2=80=9D. According to the mode it spawns multiple processes=
, not threads.<br>
&gt; &gt;<br>
&gt; &gt; Since a single page is unmapped each time, and the iTLB-loads inc=
rease<br>
&gt; &gt; dramatically, I would suspect that for some reason a full TLB flu=
sh is<br>
&gt; &gt; caused during do_munmap().<br>
&gt; &gt;<br>
&gt; &gt; If I find some free time, I=E2=80=99ll try to profile the workloa=
d - but feel free<br>
&gt; &gt; to beat me to it.<br>
&gt;<br>
&gt; The root-cause appears to be that tlb_finish_mmu() does not call<br>
&gt; dec_tlb_flush_pending() - as it should. Any chance you can take care o=
f it?<br>
<br>
</div>Oops, but with second looking, it seems it&#39;s not my fault. ;-)<br=
>
<a href=3D"https://marc.info/?l=3Dlinux-mm&amp;m=3D150156699114088&amp;w=3D=
2" rel=3D"noreferrer" target=3D"_blank">https://marc.info/?l=3Dlinux-mm&amp=
;<wbr>m=3D150156699114088&amp;w=3D2</a></blockquote></div></div><div dir=3D=
"auto"><br></div><div dir=3D"auto"><span style=3D"font-family:sans-serif">E=
rr... Sorry for that...</span><br></div><div class=3D"gmail_extra" dir=3D"a=
uto"><div class=3D"gmail_quote"><blockquote class=3D"quote" style=3D"margin=
:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex"><br></blockquote><=
/div></div></div>

--f403045e3dfa58c50c0556399359--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
