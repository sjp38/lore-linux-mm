Return-Path: <SRS0=CIMh=QT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,HTML_MESSAGE,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D60FEC169C4
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 01:08:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 86065217FA
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 01:08:17 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="s7kIdhPF"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 86065217FA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 195538E01A4; Mon, 11 Feb 2019 20:08:17 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 11EA38E019C; Mon, 11 Feb 2019 20:08:17 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 00C698E01A4; Mon, 11 Feb 2019 20:08:16 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id C909E8E019C
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 20:08:16 -0500 (EST)
Received: by mail-ot1-f69.google.com with SMTP id m52so984404otc.13
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 17:08:16 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=W2Vr9St/G0kZBR6PwQPAykva1NJzgZcore6gUmMplGc=;
        b=e2SHgw/KN+Np51P5NP0DBqEh540JmS4ReZVSWsiB7aeSiu+7GK4z9NCz/hqoEAgdGC
         akgqLUJGuHxmtgW6Dl3DhMUeLpWOKprA8saRbUMpSeZPMsQr9UzBGKvfSXIycHKw7UA8
         0VbYVYtxb48U1YxbYqTi0lpQP0etCywYS+VhULSlZT+vIXczkpqKNgeGXG2vjoMpkQuM
         BVZ6ykbYyDJ4jX8aaDmtFMYC+G9MG/hbzGIPXZsHwQYxxiDLnKjQMRg/8r+Q9MK7WajF
         98g304LN6JBp0vZX4BYcZNHAQcthdX7bO3j7uUpGZRQPR+LYaK8egtvmx3d5rOlNfVtK
         LtSQ==
X-Gm-Message-State: AHQUAuY4HSduYIaZwOqTPDfY9BQmT4Ix1IGi0HgCbU5BfZuLV719rc1J
	7+fywmMRR6WrD+kLB/lGpna1YL3c5Kijg3WtLeVKRDQpTvOTobxHLKdput1rpnkcRkKBnJMP2tg
	BEVR03zH7pCOovz7U7GLu6vu6aYtRgwtErEI+a2RWxnzzHZiozV5p/R+tVk6HUYPsRPI+rKLxZO
	uc7iYagKSSg6lk7gdIZvIs1FyLmOdlk8ckfIvapEoqHWIQeoG7uENawIQFhk3y4ZBjs4xChuEg1
	vCvDQI7M7q3uu+ZWr8hAcvmO94Ct1MIrc41SHUzZIU+PfeHa+0EvZ5AZ3MAeuf3JemF1cVkIEXy
	w2wqfwNp3bXkB693vU5AWgVkAit9PRAOdrC9huW49kV8AzN6JSTEluxxz2ZMsZm6r8ofx/XOY2t
	K
X-Received: by 2002:a9d:d88:: with SMTP id 8mr1177122ots.164.1549933696521;
        Mon, 11 Feb 2019 17:08:16 -0800 (PST)
X-Received: by 2002:a9d:d88:: with SMTP id 8mr1177074ots.164.1549933695898;
        Mon, 11 Feb 2019 17:08:15 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549933695; cv=none;
        d=google.com; s=arc-20160816;
        b=LJZMJjM7inan1HwmdecFRm++U5qcWkUxR0YUOtaHG4jXYN4t/1jyEmc40ZMJJDPvHz
         TTaMe8JLGHuQpnlB1HNwOSa2TH1u5H9eUldlCHkGpAWP6o+7oqd4vWPmIERRfr2mGO6O
         +gw5XckRX9ofez4/4DYeiS0YbaQwakV1fsOIqUZil/gku4g2weZzG/pUk/bIUXZ+sOq+
         MpPDSW3SNpUHrLyeLKZ4SsUNwFp5g0HAuWc9HZ7e4CLZyibuQ3hBsKBQm+RGDGqtuMuw
         SMR8Z1QWBHiR4rV75I9FOp7PR1jcCm0OUcwGUZBwdZjkuNZMzTwVnSKRCbNf7Ly91kp8
         gjsQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=W2Vr9St/G0kZBR6PwQPAykva1NJzgZcore6gUmMplGc=;
        b=L9Rq2fKAomDDO8cT7a3g795qcJtXYWa4OplGkHi8PGK5zCXsVrAzIVq0MkaK4B4ViY
         +LKWyLUBhIUaEzpuBgQDzBbGZUcfC288x6tD1Mm509PgXCqomUIP0bnRBk/aYvuNkKKE
         N9sS9ZvpTWmLOiE9hYsmqkvsynEkTCvZunShSCvLGaC9n9ZextvKPqx6ngVAb0Ya81wS
         Ui8i22agVSD2HVoY8Ap69XZU3Vk7Fqavis0jokYDUhmT5XewH9RRK1oFlw5eOWSwn8xP
         TfpEY3kAGBv4lnWcGtKmRMAlHuuQcn6HUHmfWIJxHDoA3wLNB35XXEailcMiyshoDQv5
         pz0w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=s7kIdhPF;
       spf=pass (google.com: domain of igor.stoppa@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=igor.stoppa@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o14sor6502357otp.78.2019.02.11.17.08.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 11 Feb 2019 17:08:15 -0800 (PST)
Received-SPF: pass (google.com: domain of igor.stoppa@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=s7kIdhPF;
       spf=pass (google.com: domain of igor.stoppa@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=igor.stoppa@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=W2Vr9St/G0kZBR6PwQPAykva1NJzgZcore6gUmMplGc=;
        b=s7kIdhPFUWT4IRx+2EIou3rcEn98+wAjhb8zWr1wGgCgBuQ2nBIz0CcMKfE+4YSuim
         qpa3+POGQj8PA/W3ywa0HzUj3jmqzLF/QP0LJkKRNyQkE2uba1Xnlk6VcOPV7JJo/UsI
         Q4Rxt6Br0lzCzpW9D8VB9K2KiSRilfmKNWMSoHXb8TAqsj1TxdtOpCD8js773ELxNFa1
         ffLHaIWh6TcSe/TuIwlcc4pqylpik7KCKPYA4Bbk0lJygw3oVrn0B0EKP/Ydh7fN+5p0
         U02RXsEjp2dxC+xmIp2CO+brBDDrUean2pXQ6BVX1yZxYvB0txLifeTmSz8/z5NibWh3
         xUBA==
X-Google-Smtp-Source: AHgI3Ia+JGAS+5z2jsI7OGqoo0g9Pj9psQsayiTiAVUJtoT0ZyukmekiXTBdvR6RDon9ZGa2M1x2ALshVMvlZ8k9nGk=
X-Received: by 2002:a05:6830:2015:: with SMTP id e21mr1015809otp.69.1549933695522;
 Mon, 11 Feb 2019 17:08:15 -0800 (PST)
MIME-Version: 1.0
References: <cover.1549927666.git.igor.stoppa@huawei.com> <CAGXu5j+n3ky2dOe4F+VyneQsM4VJbGPUw+DO55NkxxPhKzKHag@mail.gmail.com>
 <25bf3c63-c54c-f7ea-bec1-996a2c05d997@gmail.com> <CAGXu5jLqmYRUVLb7-jPsN4onO5UNH+D6qOF=9TOiVjJa-=DnZQ@mail.gmail.com>
In-Reply-To: <CAGXu5jLqmYRUVLb7-jPsN4onO5UNH+D6qOF=9TOiVjJa-=DnZQ@mail.gmail.com>
From: "igor.stoppa@gmail.com" <igor.stoppa@gmail.com>
Date: Tue, 12 Feb 2019 05:08:03 +0400
Message-ID: <CAH2bzCRZ5xYOT0R8piqZx4mSGj1_8fNG=Ce4UU8i6F7mYD9m9Q@mail.gmail.com>
Subject: Re: [RFC PATCH v4 00/12] hardening: statically allocated protected memory
To: Kees Cook <keescook@chromium.org>
Cc: Igor Stoppa <igor.stoppa@huawei.com>, Ahmed Soliman <ahmedsoliman@mena.vt.edu>, 
	linux-integrity <linux-integrity@vger.kernel.org>, 
	Kernel Hardening <kernel-hardening@lists.openwall.com>, Linux-MM <linux-mm@kvack.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Content-Type: multipart/alternative; boundary="00000000000058dc140581a80fc2"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

--00000000000058dc140581a80fc2
Content-Type: text/plain; charset="UTF-8"

On Tue, 12 Feb 2019, 4.47 Kees Cook <keescook@chromium.org wrote:

> On Mon, Feb 11, 2019 at 4:37 PM Igor Stoppa <igor.stoppa@gmail.com> wrote:
> >
> >
> >
> > On 12/02/2019 02:09, Kees Cook wrote:
> > > On Mon, Feb 11, 2019 at 3:28 PM Igor Stoppa <igor.stoppa@gmail.com>
> wrote:
> > > It looked like only the memset() needed architecture support. Is there
> > > a reason for not being able to implement memset() in terms of an
> > > inefficient put_user() loop instead? That would eliminate the need for
> > > per-arch support, yes?
> >
> > So far, yes, however from previous discussion about power arch, I
> > understood this implementation would not be so easy to adapt.
> > Lacking other examples where the extra mapping could be used, I did not
> > want to add code without a use case.
> >
> > Probably both arm and x86 32 bit could do, but I would like to first get
> > to the bitter end with memory protection (the other 2 thirds).
> >
> > Mostly, I hated having just one arch and I also really wanted to have
> arm64.
>
> Right, I meant, if you implemented the _memset() case with put_user()
> in this version, you could drop the arch-specific _memset() and shrink
> the patch series. Then you could also enable this across all the
> architectures in one patch. (Would you even need the Kconfig patches,
> i.e. won't this "Just Work" on everything with an MMU?)
>

I had similar thoughts, but this answer [1] deflated my hopes (if I
understood it correctly).
It seems that each arch needs to be massaged in separately.

--
igor


[1] https://www.openwall.com/lists/kernel-hardening/2018/12/12/15

>

--00000000000058dc140581a80fc2
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"auto"><div><br><br><div class=3D"gmail_quote"><div dir=3D"ltr">=
On Tue, 12 Feb 2019, 4.47 Kees Cook &lt;<a href=3D"mailto:keescook@chromium=
.org">keescook@chromium.org</a> wrote:<br></div><blockquote class=3D"gmail_=
quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1=
ex">On Mon, Feb 11, 2019 at 4:37 PM Igor Stoppa &lt;<a href=3D"mailto:igor.=
stoppa@gmail.com" target=3D"_blank" rel=3D"noreferrer">igor.stoppa@gmail.co=
m</a>&gt; wrote:<br>
&gt;<br>
&gt;<br>
&gt;<br>
&gt; On 12/02/2019 02:09, Kees Cook wrote:<br>
&gt; &gt; On Mon, Feb 11, 2019 at 3:28 PM Igor Stoppa &lt;<a href=3D"mailto=
:igor.stoppa@gmail.com" target=3D"_blank" rel=3D"noreferrer">igor.stoppa@gm=
ail.com</a>&gt; wrote:<br>
&gt; &gt; It looked like only the memset() needed architecture support. Is =
there<br>
&gt; &gt; a reason for not being able to implement memset() in terms of an<=
br>
&gt; &gt; inefficient put_user() loop instead? That would eliminate the nee=
d for<br>
&gt; &gt; per-arch support, yes?<br>
&gt;<br>
&gt; So far, yes, however from previous discussion about power arch, I<br>
&gt; understood this implementation would not be so easy to adapt.<br>
&gt; Lacking other examples where the extra mapping could be used, I did no=
t<br>
&gt; want to add code without a use case.<br>
&gt;<br>
&gt; Probably both arm and x86 32 bit could do, but I would like to first g=
et<br>
&gt; to the bitter end with memory protection (the other 2 thirds).<br>
&gt;<br>
&gt; Mostly, I hated having just one arch and I also really wanted to have =
arm64.<br>
<br>
Right, I meant, if you implemented the _memset() case with put_user()<br>
in this version, you could drop the arch-specific _memset() and shrink<br>
the patch series. Then you could also enable this across all the<br>
architectures in one patch. (Would you even need the Kconfig patches,<br>
i.e. won&#39;t this &quot;Just Work&quot; on everything with an MMU?)<br></=
blockquote></div></div><div dir=3D"auto"><br></div><div dir=3D"auto">I had =
similar thoughts, but this answer [1] deflated my hopes (if I understood it=
 correctly).</div><div dir=3D"auto">It seems that each arch needs to be mas=
saged in separately.=C2=A0</div><div dir=3D"auto"><br></div><div dir=3D"aut=
o">--</div><div dir=3D"auto">igor</div><div dir=3D"auto"><br></div><div dir=
=3D"auto"><br></div><div dir=3D"auto">[1]=C2=A0<a href=3D"https://www.openw=
all.com/lists/kernel-hardening/2018/12/12/15">https://www.openwall.com/list=
s/kernel-hardening/2018/12/12/15</a></div><div dir=3D"auto"><div class=3D"g=
mail_quote"><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;bo=
rder-left:1px #ccc solid;padding-left:1ex">
</blockquote></div></div></div>

--00000000000058dc140581a80fc2--

