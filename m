Return-Path: <SRS0=DmM3=SF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,HTML_MESSAGE,MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 37958C4360F
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 03:54:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CEF50206C0
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 03:54:17 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="E4NbbZR7"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CEF50206C0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 65BFB6B0266; Tue,  2 Apr 2019 23:54:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 60C526B026B; Tue,  2 Apr 2019 23:54:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4D2DA6B026D; Tue,  2 Apr 2019 23:54:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f198.google.com (mail-vk1-f198.google.com [209.85.221.198])
	by kanga.kvack.org (Postfix) with ESMTP id 18FEA6B0266
	for <linux-mm@kvack.org>; Tue,  2 Apr 2019 23:54:17 -0400 (EDT)
Received: by mail-vk1-f198.google.com with SMTP id w71so7299063vkd.12
        for <linux-mm@kvack.org>; Tue, 02 Apr 2019 20:54:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=wXAR9anJ5hgkC2mSm/JcnhPZpfyzvgS3kAeecXT1u+s=;
        b=BEKwNfZTKZhPfh3rUd3KSd5IlzPlaBYxXxX/LMAK3rXeALePGfSBZslZmVTKYIdoMc
         lF765TLLmpcgEnmajfPTwzNb7S8fNn10ikMZa0CMjiYi69LfTbNNP1BHzvTlq45i7aV6
         1B1R6VzF2//ydmsX0DOU7RXlQJxE6C2TNq9XoZwY9S10K0Uk6umvY0RmozAqL/CLMnSE
         DS93cr70pt5Q6LbzXh5EK4cWsIklfcI9LpajHzQcLjfKrNajNllaMk1wFLvb4PeLbBrN
         QT2qzLfsCtNsHX0y6PZL2SD2LRw7alH0TIQoVkS94X+4Td+4O708OdemtGKDJ+Ov38HY
         J3WA==
X-Gm-Message-State: APjAAAUkI11LyUIx0lkFy54fwhHwAkZBs8I5e5fhCU+sI3/YJBpxIcdn
	2fa/GuR7d3mcddOCLpbEP1YHWCPHyVDZVmNt7bL0ng9LAz82K8NempW6Wvcp8c/UkQ6+zpXQ16C
	qajeWpO/p2PHO1R9/owaXtWPiqUqGr2TUDc2N6Q4CFvnEMZzLvVG/e4clk7MaJLQ/cw==
X-Received: by 2002:ab0:7358:: with SMTP id k24mr42698048uap.104.1554263656654;
        Tue, 02 Apr 2019 20:54:16 -0700 (PDT)
X-Received: by 2002:ab0:7358:: with SMTP id k24mr42698018uap.104.1554263655599;
        Tue, 02 Apr 2019 20:54:15 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554263655; cv=none;
        d=google.com; s=arc-20160816;
        b=lylxClNjW8ugXgCbVnBnHoTLUtEKA2UzaCUmKzRC0ouaAgv/08wALb0vfCaqEbyRxq
         fc24BsBE6yaeTqp2e+BGRNn89gdLieFHkN9Ov+6bVYeSJGtY553H4oE8JLpyVmlpE+cC
         7KQV9KZEm+Zv4ZauwkPxmd5se+162ZkyIIqQRm4g1HDN1YmqmRucbGhj0bgi7SFK9mLG
         693xjXB65SDxLe7EJjQak7GjXsGnLRV4ZPtdphx0CUHeBoVeFPnlw8OP9FY3DREt9Tmi
         Py4BCZZ+MaFUvci7aZfQwju0UnFL7eEGWJhvvmWfFLxwflwnnGvm0xaSFrDdHi2mMnjc
         Fp7Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=wXAR9anJ5hgkC2mSm/JcnhPZpfyzvgS3kAeecXT1u+s=;
        b=TC4zdoi1uSdOLdJQG7hvbu5t1EOL++IqsxUatjnC//jCGO4Euh6PVkD+tVQaciGmfL
         YXoWqir6jDwfQ2vDzXZpKqTsX0/qSSQ/ROHb68vGbM5Ycc4I0WlAMfWv4uHAT+7quuBb
         +tHWLT9wuHbEa9yMIxmR3IU7FqgigqsWno951qYssUfaLCVDZ7rICmhngxA289SGXRBm
         T8c85X0JwXu8geFbBVeLnOP2K8M1dTcYlYLDDHPSU8f8WVmMjTOdHUy1QBmBwHTv8ARI
         T3rg8Ndl2rsaEifQN/uECgU9sYc1XrQ1tT+WBg9KLcwvVJVrs8ulQobjZUb+JpKHPsmc
         UrRg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=E4NbbZR7;
       spf=pass (google.com: domain of matheusfillipeag@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=matheusfillipeag@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q71sor9450229vsd.99.2019.04.02.20.54.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 02 Apr 2019 20:54:15 -0700 (PDT)
Received-SPF: pass (google.com: domain of matheusfillipeag@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=E4NbbZR7;
       spf=pass (google.com: domain of matheusfillipeag@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=matheusfillipeag@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=wXAR9anJ5hgkC2mSm/JcnhPZpfyzvgS3kAeecXT1u+s=;
        b=E4NbbZR7dtniSjAI6viQOqDBqojoBH1Ss0ypjKSpB2LF+lb9GWfRfRco35kThzWtt5
         blhI3Bx84it12TwNE84Fhssb82N5dxoG4zT+MomtBKuWXng4ByDHAsTy2/uiwKujdEgo
         18gJCYGJB83h+PK2ymgQR3skJgq2Qm6Fva/2rJqndVcBTccPmuYG+cGGZvg4EqUw9QwA
         SCWk5m+nyAHEPD8wADx66wCg2EdTI10vrFUn5Tjztzp2WeWIEmWEhEodyqW0CAVbJKoO
         ZkGqWYfnsJK8/MYZoW9/iB3MC8ZdM4Z9XIFh9V2D6V0iv4vTRjtVn4loaNeo8oz9wbiE
         mJuA==
X-Google-Smtp-Source: APXvYqxuIIQkEAqrxOIFoLigDzx5XXF69R32ER3qNuGzlU1U9Zz9WcHn8st8wnf+Bq0Mwhrt+pS1yv25SsQpUtjMpvI=
X-Received: by 2002:a67:74cd:: with SMTP id p196mr44047907vsc.215.1554263654983;
 Tue, 02 Apr 2019 20:54:14 -0700 (PDT)
MIME-Version: 1.0
References: <20140505233358.GC19914@cmpxchg.org> <5368227D.7060302@intel.com>
 <20140612220200.GA25344@cmpxchg.org> <539A3CD7.6080100@intel.com>
 <20140613045557.GL2878@cmpxchg.org> <539F1B66.2020006@intel.com> <20190402162500.def729ec05e6e267bff8a5da@linux-foundation.org>
In-Reply-To: <20190402162500.def729ec05e6e267bff8a5da@linux-foundation.org>
From: Matheus Fillipe <matheusfillipeag@gmail.com>
Date: Wed, 3 Apr 2019 00:54:05 -0300
Message-ID: <CAFWuBvcAFhhPk4K-w7OLVBo8psWuDdUP4hJNLq3QeFUyg=_Mow@mail.gmail.com>
Subject: Re: [Bug 75101] New: [bisected] s2disk / hibernate blocks on "Saving
 506031 image data pages () ..."
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, 
	=?UTF-8?Q?Rodolfo_Garc=C3=ADa_Pe=C3=B1as?= <kix@kix.es>, 
	Oliver Winker <oliverml1@oli1170.net>, Jan Kara <jack@suse.cz>, 
	bugzilla-daemon@bugzilla.kernel.org, linux-mm@kvack.org, 
	Maxim Patlasov <mpatlasov@parallels.com>, Fengguang Wu <fengguang.wu@intel.com>, 
	Tejun Heo <tj@kernel.org>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, killian.de.volder@megasoft.be, 
	atillakaraca72@hotmail.com, jrf@mailbox.org
Content-Type: multipart/alternative; boundary="0000000000000aef28058598359b"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

--0000000000000aef28058598359b
Content-Type: text/plain; charset="UTF-8"

Wow! Here I am to revive this topic in 2019! I have exactly the same
problem, on ubuntu 18.04.2 with basically all kernels since 4.15.0-42 up to
5, which was all I tested, currently on 4.18.0-17-generic... I guess this
has nothing to do with the kernel anyway.

It was working fine before, even with proprietary nvidia drivers which
would generally cause a bug on the resume and not while saving the ram
snapshot. I've been trying to tell this to the ubuntu guys and you can see
my whole story with this problem right here:
https://bugs.launchpad.net/ubuntu/+source/linux/+bug/1819915

Shortly, I tried with or without nvidia modules enabled (or intel or using
nouveau), many different kernels, disabled i915, and this is all  get in
all those different combinations:
https://launchpadlibrarian.net/417327528/i915.jpg

The event is pretty random and seems to be more likely to happen after 2 or
4 gb of ram is ever used (I have 16 in total), and nothing changes if later
I reduce the ram usage later. But is random, I successfully hibernated with
11gb in use yesterday, just resumed and hibernated 5 seconds later without
doing nothing else  than running hibernate, and got freeze there.

This also happens randomly if there's just 3 or 2 gb in use, likely on the
second attempt of after more than 5 minutes after the computer is on. What
can be wrong here?


On Tue, Apr 2, 2019, 20:25 Andrew Morton <akpm@linux-foundation.org> wrote:

>
> I cc'ed a bunch of people from bugzilla.
>
> Folks, please please please remember to reply via emailed
> reply-to-all.  Don't use the bugzilla interface!
>
> On Mon, 16 Jun 2014 18:29:26 +0200 "Rafael J. Wysocki" <
> rafael.j.wysocki@intel.com> wrote:
>
> > On 6/13/2014 6:55 AM, Johannes Weiner wrote:
> > > On Fri, Jun 13, 2014 at 01:50:47AM +0200, Rafael J. Wysocki wrote:
> > >> On 6/13/2014 12:02 AM, Johannes Weiner wrote:
> > >>> On Tue, May 06, 2014 at 01:45:01AM +0200, Rafael J. Wysocki wrote:
> > >>>> On 5/6/2014 1:33 AM, Johannes Weiner wrote:
> > >>>>> Hi Oliver,
> > >>>>>
> > >>>>> On Mon, May 05, 2014 at 11:00:13PM +0200, Oliver Winker wrote:
> > >>>>>> Hello,
> > >>>>>>
> > >>>>>> 1) Attached a full function-trace log + other SysRq outputs, see
> [1]
> > >>>>>> attached.
> > >>>>>>
> > >>>>>> I saw bdi_...() calls in the s2disk paths, but didn't check in
> detail
> > >>>>>> Probably more efficient when one of you guys looks directly.
> > >>>>> Thanks, this looks interesting.  balance_dirty_pages() wakes up the
> > >>>>> bdi_wq workqueue as it should:
> > >>>>>
> > >>>>> [  249.148009]   s2disk-3327    2.... 48550413us :
> global_dirty_limits <-balance_dirty_pages_ratelimited
> > >>>>> [  249.148009]   s2disk-3327    2.... 48550414us :
> global_dirtyable_memory <-global_dirty_limits
> > >>>>> [  249.148009]   s2disk-3327    2.... 48550414us :
> writeback_in_progress <-balance_dirty_pages_ratelimited
> > >>>>> [  249.148009]   s2disk-3327    2.... 48550414us :
> bdi_start_background_writeback <-balance_dirty_pages_ratelimited
> > >>>>> [  249.148009]   s2disk-3327    2.... 48550414us :
> mod_delayed_work_on <-balance_dirty_pages_ratelimited
> > >>>>> but the worker wakeup doesn't actually do anything:
> > >>>>> [  249.148009] kworker/-3466    2d... 48550431us :
> finish_task_switch <-__schedule
> > >>>>> [  249.148009] kworker/-3466    2.... 48550431us :
> _raw_spin_lock_irq <-worker_thread
> > >>>>> [  249.148009] kworker/-3466    2d... 48550431us :
> need_to_create_worker <-worker_thread
> > >>>>> [  249.148009] kworker/-3466    2d... 48550432us :
> worker_enter_idle <-worker_thread
> > >>>>> [  249.148009] kworker/-3466    2d... 48550432us :
> too_many_workers <-worker_enter_idle
> > >>>>> [  249.148009] kworker/-3466    2.... 48550432us : schedule
> <-worker_thread
> > >>>>> [  249.148009] kworker/-3466    2.... 48550432us : __schedule
> <-worker_thread
> > >>>>>
> > >>>>> My suspicion is that this fails because the bdi_wq is frozen at
> this
> > >>>>> point and so the flush work never runs until resume, whereas
> before my
> > >>>>> patch the effective dirty limit was high enough so that image
> could be
> > >>>>> written in one go without being throttled; followed by an fsync()
> that
> > >>>>> then writes the pages in the context of the unfrozen s2disk.
> > >>>>>
> > >>>>> Does this make sense?  Rafael?  Tejun?
> > >>>> Well, it does seem to make sense to me.
> > >>>  From what I see, this is a deadlock in the userspace suspend model
> and
> > >>> just happened to work by chance in the past.
> > >> Well, it had been working for quite a while, so it was a rather large
> > >> opportunity
> > >> window it seems. :-)
> > > No doubt about that, and I feel bad that it broke.  But it's still a
> > > deadlock that can't reasonably be accommodated from dirty throttling.
> > >
> > > It can't just put the flushers to sleep and then issue a large amount
> > > of buffered IO, hoping it doesn't hit the dirty limits.  Don't shoot
> > > the messenger, this bug needs to be addressed, not get papered over.
> > >
> > >>> Can we patch suspend-utils as follows?
> > >> Perhaps we can.  Let's ask the new maintainer.
> > >>
> > >> Rodolfo, do you think you can apply the patch below to suspend-utils?
> > >>
> > >>> Alternatively, suspend-utils
> > >>> could clear the dirty limits before it starts writing and restore
> them
> > >>> post-resume.
> > >> That (and the patch too) doesn't seem to address the problem with
> existing
> > >> suspend-utils
> > >> binaries, however.
> > > It's userspace that freezes the system before issuing buffered IO, so
> > > my conclusion was that the bug is in there.  This is arguable.  I also
> > > wouldn't be opposed to a patch that sets the dirty limits to infinity
> > > from the ioctl that freezes the system or creates the image.
> >
> > OK, that sounds like a workable plan.
> >
> > How do I set those limits to infinity?
>
> Five years have passed and people are still hitting this.
>
> Killian described the workaround in comment 14 at
> https://bugzilla.kernel.org/show_bug.cgi?id=75101.
>
> People can use this workaround manually by hand or in scripts.  But we
> really should find a proper solution.  Maybe special-case the freezing
> of the flusher threads until all the writeout has completed.  Or
> something else.
>

--0000000000000aef28058598359b
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"auto"><div dir=3D"auto"><div dir=3D"auto">Wow! Here I am to rev=
ive this topic in 2019! I have exactly the same problem, on ubuntu 18.04.2 =
with basically all kernels since 4.15.0-42 up to 5, which was all I tested,=
 currently on 4.18.0-17-generic... I guess this has nothing to do with the =
kernel anyway.=C2=A0</div><div dir=3D"auto"><br></div><div dir=3D"auto">It =
was working fine before, even with proprietary nvidia drivers which would g=
enerally cause a bug on the resume and not while saving the ram snapshot. I=
&#39;ve been trying to tell this to the ubuntu guys and you can see my whol=
e story with this problem right here: <a href=3D"https://bugs.launchpad.net=
/ubuntu/+source/linux/+bug/1819915">https://bugs.launchpad.net/ubuntu/+sour=
ce/linux/+bug/1819915</a></div><div dir=3D"auto"><br></div><div dir=3D"auto=
">Shortly, I tried with or without nvidia modules enabled (or intel or usin=
g nouveau), many different kernels, disabled i915, and this is all=C2=A0 ge=
t in all those different combinations: <a href=3D"https://launchpadlibraria=
n.net/417327528/i915.jpg">https://launchpadlibrarian.net/417327528/i915.jpg=
</a></div><div dir=3D"auto"><br></div><div dir=3D"auto">The event is pretty=
 random and seems to be more likely to happen after 2 or 4 gb of ram is eve=
r used (I have 16 in total), and nothing changes if later I reduce the ram =
usage later. But is random, I successfully hibernated with 11gb in use yest=
erday, just resumed and hibernated 5 seconds later without doing nothing el=
se=C2=A0 than running hibernate, and got freeze there.</div><div dir=3D"aut=
o"><br></div><div dir=3D"auto">This also happens randomly if there&#39;s ju=
st 3 or 2 gb in use, likely on the second attempt of after more than 5 minu=
tes after the computer is on. What can be wrong here?</div></div><div dir=
=3D"auto"><br></div></div><br><div class=3D"gmail_quote"><div dir=3D"ltr" c=
lass=3D"gmail_attr">On Tue, Apr 2, 2019, 20:25 Andrew Morton &lt;<a href=3D=
"mailto:akpm@linux-foundation.org">akpm@linux-foundation.org</a>&gt; wrote:=
<br></div><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;bord=
er-left:1px #ccc solid;padding-left:1ex"><br>
I cc&#39;ed a bunch of people from bugzilla.<br>
<br>
Folks, please please please remember to reply via emailed<br>
reply-to-all.=C2=A0 Don&#39;t use the bugzilla interface!<br>
<br>
On Mon, 16 Jun 2014 18:29:26 +0200 &quot;Rafael J. Wysocki&quot; &lt;<a hre=
f=3D"mailto:rafael.j.wysocki@intel.com" target=3D"_blank" rel=3D"noreferrer=
">rafael.j.wysocki@intel.com</a>&gt; wrote:<br>
<br>
&gt; On 6/13/2014 6:55 AM, Johannes Weiner wrote:<br>
&gt; &gt; On Fri, Jun 13, 2014 at 01:50:47AM +0200, Rafael J. Wysocki wrote=
:<br>
&gt; &gt;&gt; On 6/13/2014 12:02 AM, Johannes Weiner wrote:<br>
&gt; &gt;&gt;&gt; On Tue, May 06, 2014 at 01:45:01AM +0200, Rafael J. Wysoc=
ki wrote:<br>
&gt; &gt;&gt;&gt;&gt; On 5/6/2014 1:33 AM, Johannes Weiner wrote:<br>
&gt; &gt;&gt;&gt;&gt;&gt; Hi Oliver,<br>
&gt; &gt;&gt;&gt;&gt;&gt;<br>
&gt; &gt;&gt;&gt;&gt;&gt; On Mon, May 05, 2014 at 11:00:13PM +0200, Oliver =
Winker wrote:<br>
&gt; &gt;&gt;&gt;&gt;&gt;&gt; Hello,<br>
&gt; &gt;&gt;&gt;&gt;&gt;&gt;<br>
&gt; &gt;&gt;&gt;&gt;&gt;&gt; 1) Attached a full function-trace log + other=
 SysRq outputs, see [1]<br>
&gt; &gt;&gt;&gt;&gt;&gt;&gt; attached.<br>
&gt; &gt;&gt;&gt;&gt;&gt;&gt;<br>
&gt; &gt;&gt;&gt;&gt;&gt;&gt; I saw bdi_...() calls in the s2disk paths, bu=
t didn&#39;t check in detail<br>
&gt; &gt;&gt;&gt;&gt;&gt;&gt; Probably more efficient when one of you guys =
looks directly.<br>
&gt; &gt;&gt;&gt;&gt;&gt; Thanks, this looks interesting.=C2=A0 balance_dir=
ty_pages() wakes up the<br>
&gt; &gt;&gt;&gt;&gt;&gt; bdi_wq workqueue as it should:<br>
&gt; &gt;&gt;&gt;&gt;&gt;<br>
&gt; &gt;&gt;&gt;&gt;&gt; [=C2=A0 249.148009]=C2=A0 =C2=A0s2disk-3327=C2=A0=
 =C2=A0 2.... 48550413us : global_dirty_limits &lt;-balance_dirty_pages_rat=
elimited<br>
&gt; &gt;&gt;&gt;&gt;&gt; [=C2=A0 249.148009]=C2=A0 =C2=A0s2disk-3327=C2=A0=
 =C2=A0 2.... 48550414us : global_dirtyable_memory &lt;-global_dirty_limits=
<br>
&gt; &gt;&gt;&gt;&gt;&gt; [=C2=A0 249.148009]=C2=A0 =C2=A0s2disk-3327=C2=A0=
 =C2=A0 2.... 48550414us : writeback_in_progress &lt;-balance_dirty_pages_r=
atelimited<br>
&gt; &gt;&gt;&gt;&gt;&gt; [=C2=A0 249.148009]=C2=A0 =C2=A0s2disk-3327=C2=A0=
 =C2=A0 2.... 48550414us : bdi_start_background_writeback &lt;-balance_dirt=
y_pages_ratelimited<br>
&gt; &gt;&gt;&gt;&gt;&gt; [=C2=A0 249.148009]=C2=A0 =C2=A0s2disk-3327=C2=A0=
 =C2=A0 2.... 48550414us : mod_delayed_work_on &lt;-balance_dirty_pages_rat=
elimited<br>
&gt; &gt;&gt;&gt;&gt;&gt; but the worker wakeup doesn&#39;t actually do any=
thing:<br>
&gt; &gt;&gt;&gt;&gt;&gt; [=C2=A0 249.148009] kworker/-3466=C2=A0 =C2=A0 2d=
... 48550431us : finish_task_switch &lt;-__schedule<br>
&gt; &gt;&gt;&gt;&gt;&gt; [=C2=A0 249.148009] kworker/-3466=C2=A0 =C2=A0 2.=
... 48550431us : _raw_spin_lock_irq &lt;-worker_thread<br>
&gt; &gt;&gt;&gt;&gt;&gt; [=C2=A0 249.148009] kworker/-3466=C2=A0 =C2=A0 2d=
... 48550431us : need_to_create_worker &lt;-worker_thread<br>
&gt; &gt;&gt;&gt;&gt;&gt; [=C2=A0 249.148009] kworker/-3466=C2=A0 =C2=A0 2d=
... 48550432us : worker_enter_idle &lt;-worker_thread<br>
&gt; &gt;&gt;&gt;&gt;&gt; [=C2=A0 249.148009] kworker/-3466=C2=A0 =C2=A0 2d=
... 48550432us : too_many_workers &lt;-worker_enter_idle<br>
&gt; &gt;&gt;&gt;&gt;&gt; [=C2=A0 249.148009] kworker/-3466=C2=A0 =C2=A0 2.=
... 48550432us : schedule &lt;-worker_thread<br>
&gt; &gt;&gt;&gt;&gt;&gt; [=C2=A0 249.148009] kworker/-3466=C2=A0 =C2=A0 2.=
... 48550432us : __schedule &lt;-worker_thread<br>
&gt; &gt;&gt;&gt;&gt;&gt;<br>
&gt; &gt;&gt;&gt;&gt;&gt; My suspicion is that this fails because the bdi_w=
q is frozen at this<br>
&gt; &gt;&gt;&gt;&gt;&gt; point and so the flush work never runs until resu=
me, whereas before my<br>
&gt; &gt;&gt;&gt;&gt;&gt; patch the effective dirty limit was high enough s=
o that image could be<br>
&gt; &gt;&gt;&gt;&gt;&gt; written in one go without being throttled; follow=
ed by an fsync() that<br>
&gt; &gt;&gt;&gt;&gt;&gt; then writes the pages in the context of the unfro=
zen s2disk.<br>
&gt; &gt;&gt;&gt;&gt;&gt;<br>
&gt; &gt;&gt;&gt;&gt;&gt; Does this make sense?=C2=A0 Rafael?=C2=A0 Tejun?<=
br>
&gt; &gt;&gt;&gt;&gt; Well, it does seem to make sense to me.<br>
&gt; &gt;&gt;&gt;=C2=A0 From what I see, this is a deadlock in the userspac=
e suspend model and<br>
&gt; &gt;&gt;&gt; just happened to work by chance in the past.<br>
&gt; &gt;&gt; Well, it had been working for quite a while, so it was a rath=
er large<br>
&gt; &gt;&gt; opportunity<br>
&gt; &gt;&gt; window it seems. :-)<br>
&gt; &gt; No doubt about that, and I feel bad that it broke.=C2=A0 But it&#=
39;s still a<br>
&gt; &gt; deadlock that can&#39;t reasonably be accommodated from dirty thr=
ottling.<br>
&gt; &gt;<br>
&gt; &gt; It can&#39;t just put the flushers to sleep and then issue a larg=
e amount<br>
&gt; &gt; of buffered IO, hoping it doesn&#39;t hit the dirty limits.=C2=A0=
 Don&#39;t shoot<br>
&gt; &gt; the messenger, this bug needs to be addressed, not get papered ov=
er.<br>
&gt; &gt;<br>
&gt; &gt;&gt;&gt; Can we patch suspend-utils as follows?<br>
&gt; &gt;&gt; Perhaps we can.=C2=A0 Let&#39;s ask the new maintainer.<br>
&gt; &gt;&gt;<br>
&gt; &gt;&gt; Rodolfo, do you think you can apply the patch below to suspen=
d-utils?<br>
&gt; &gt;&gt;<br>
&gt; &gt;&gt;&gt; Alternatively, suspend-utils<br>
&gt; &gt;&gt;&gt; could clear the dirty limits before it starts writing and=
 restore them<br>
&gt; &gt;&gt;&gt; post-resume.<br>
&gt; &gt;&gt; That (and the patch too) doesn&#39;t seem to address the prob=
lem with existing<br>
&gt; &gt;&gt; suspend-utils<br>
&gt; &gt;&gt; binaries, however.<br>
&gt; &gt; It&#39;s userspace that freezes the system before issuing buffere=
d IO, so<br>
&gt; &gt; my conclusion was that the bug is in there.=C2=A0 This is arguabl=
e.=C2=A0 I also<br>
&gt; &gt; wouldn&#39;t be opposed to a patch that sets the dirty limits to =
infinity<br>
&gt; &gt; from the ioctl that freezes the system or creates the image.<br>
&gt; <br>
&gt; OK, that sounds like a workable plan.<br>
&gt; <br>
&gt; How do I set those limits to infinity?<br>
<br>
Five years have passed and people are still hitting this.<br>
<br>
Killian described the workaround in comment 14 at<br>
<a href=3D"https://bugzilla.kernel.org/show_bug.cgi?id=3D75101" rel=3D"nore=
ferrer noreferrer" target=3D"_blank">https://bugzilla.kernel.org/show_bug.c=
gi?id=3D75101</a>.<br>
<br>
People can use this workaround manually by hand or in scripts.=C2=A0 But we=
<br>
really should find a proper solution.=C2=A0 Maybe special-case the freezing=
<br>
of the flusher threads until all the writeout has completed.=C2=A0 Or<br>
something else.<br>
</blockquote></div>

--0000000000000aef28058598359b--

