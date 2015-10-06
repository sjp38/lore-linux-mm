Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f175.google.com (mail-ig0-f175.google.com [209.85.213.175])
	by kanga.kvack.org (Postfix) with ESMTP id 74DBB82F68
	for <linux-mm@kvack.org>; Tue,  6 Oct 2015 11:25:59 -0400 (EDT)
Received: by igbkq10 with SMTP id kq10so87201570igb.0
        for <linux-mm@kvack.org>; Tue, 06 Oct 2015 08:25:59 -0700 (PDT)
Received: from mail-ig0-x233.google.com (mail-ig0-x233.google.com. [2607:f8b0:4001:c05::233])
        by mx.google.com with ESMTPS id i6si13659540igi.84.2015.10.06.08.25.58
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Oct 2015 08:25:58 -0700 (PDT)
Received: by igxx6 with SMTP id x6so83010119igx.1
        for <linux-mm@kvack.org>; Tue, 06 Oct 2015 08:25:58 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <201510031502.BJD59536.HFJMtQOOLFFVSO@I-love.SAKURA.ne.jp>
References: <alpine.DEB.2.10.1509241359100.32488@chino.kir.corp.google.com>
	<20150925093556.GF16497@dhcp22.suse.cz>
	<201509260114.ADI35946.OtHOVFOMJQFLFS@I-love.SAKURA.ne.jp>
	<201509290118.BCJ43256.tSFFFMOLHVOJOQ@I-love.SAKURA.ne.jp>
	<20151002123639.GA13914@dhcp22.suse.cz>
	<201510031502.BJD59536.HFJMtQOOLFFVSO@I-love.SAKURA.ne.jp>
Date: Tue, 6 Oct 2015 16:25:57 +0100
Message-ID: <CA+55aFy5QBd-T2WXr5s4oAxcC1UoSjkFnd8v5f26LYzrtyFqAg@mail.gmail.com>
Subject: Re: Can't we use timeout based OOM warning/killing?
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: multipart/alternative; boundary=089e01228c4e266fe10521713ff4
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: Christoph Lameter <cl@linux.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@kernel.org>, Kyle Walker <kwalker@redhat.com>, Oleg Nesterov <oleg@redhat.com>, Vladimir Davydov <vdavydov@parallels.com>, Stanislav Kozina <skozina@redhat.com>, linux-mm <linux-mm@kvack.org>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>

--089e01228c4e266fe10521713ff4
Content-Type: text/plain; charset=UTF-8

On Oct 3, 2015 7:02 AM, "Tetsuo Handa" <penguin-kernel@i-love.sakura.ne.jp>
wrote:
>
> Kernel developers are not interested in testing OOM cases. I proposed a
> SystemTap-based mandatory memory allocation failure injection for testing
> OOM cases, but there was no response.

I don't know if it's so much "not interested" as just "it's fairly hard to
be realistic and on the same page". We used to have some simple oom testing
that just did tons of allocations in user space, but then all the actual
allocations that go on tend to be just the normal anonymous pages.

Or then it's the same thing with shared memory (which is harder) or some
other case.  It's seldom a complex and varied load with lots of different
allocations.

I think it might be interesting to have some VM image case with fairly
limited memory (so you can easily run it on different machines, whether you
have a workstation with 16GB or some big iron with 1TB of ram). And a
reasonable load that does at least a few different cases (ie do not just
some server load, but maybe Xorg and chrome or something).

Because another thing that tends to affect this is that oom without swap is
very different from oom with lots of swap, so different people will see
very different issues. If you have some particular case you want to check,
and could make a VM image for it, maybe that would get more mm people
looking at it and agreeing about the issues.

Would something like that perhaps work? I dunno, but it *might* get more
people on the same page (although maybe then people just start complaining
about the choice of load instead..)

    Linus (on mobile at LinuxCon, so
            the mailing list will bounce this) Torvalds

--089e01228c4e266fe10521713ff4
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<p dir=3D"ltr"><br>
On Oct 3, 2015 7:02 AM, &quot;Tetsuo Handa&quot; &lt;<a href=3D"mailto:peng=
uin-kernel@i-love.sakura.ne.jp">penguin-kernel@i-love.sakura.ne.jp</a>&gt; =
wrote:<br>
&gt;<br>
&gt; Kernel developers are not interested in testing OOM cases. I proposed =
a<br>
&gt; SystemTap-based mandatory memory allocation failure injection for test=
ing<br>
&gt; OOM cases, but there was no response. </p>
<p dir=3D"ltr">I don&#39;t know if it&#39;s so much &quot;not interested&qu=
ot; as just &quot;it&#39;s fairly hard to be realistic and on the same page=
&quot;. We used to have some simple oom testing that just did tons of alloc=
ations in user space, but then all the actual allocations that go on tend t=
o be just the normal anonymous pages.</p>
<p dir=3D"ltr">Or then it&#39;s the same thing with shared memory (which is=
 harder) or some other case.=C2=A0 It&#39;s seldom a complex and varied loa=
d with lots of different allocations.</p>
<p dir=3D"ltr">I think it might be interesting to have some VM image case w=
ith fairly limited memory (so you can easily run it on different machines, =
whether you have a workstation with 16GB or some big iron with 1TB of ram).=
 And a reasonable load that does at least a few different cases (ie do not =
just some server load, but maybe Xorg and chrome or something).</p>
<p dir=3D"ltr">Because another thing that tends to affect this is that oom =
without swap is very different from oom with lots of swap, so different peo=
ple will see very different issues. If you have some particular case you wa=
nt to check, and could make a VM image for it, maybe that would get more mm=
 people looking at it and agreeing about the issues.</p>
<p dir=3D"ltr">Would something like that perhaps work? I dunno, but it *mig=
ht* get more people on the same page (although maybe then people just start=
 complaining about the choice of load instead..)</p>
<p dir=3D"ltr">=C2=A0=C2=A0=C2=A0 Linus (on mobile at LinuxCon, so<br>
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 the mail=
ing list will bounce this) Torvalds</p>

--089e01228c4e266fe10521713ff4--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
