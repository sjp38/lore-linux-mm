Return-Path: <SRS0=IQlH=SO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,HTML_MESSAGE,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,USER_IN_DEF_DKIM_WL autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C4007C10F0E
	for <linux-mm@archiver.kernel.org>; Fri, 12 Apr 2019 14:03:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 61BD4206BA
	for <linux-mm@archiver.kernel.org>; Fri, 12 Apr 2019 14:03:01 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="i5qox0ph"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 61BD4206BA
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C14666B000C; Fri, 12 Apr 2019 10:03:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BC3E56B000D; Fri, 12 Apr 2019 10:03:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A8B4C6B0010; Fri, 12 Apr 2019 10:03:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 57FC66B000C
	for <linux-mm@kvack.org>; Fri, 12 Apr 2019 10:03:00 -0400 (EDT)
Received: by mail-wr1-f72.google.com with SMTP id h14so6882540wrr.22
        for <linux-mm@kvack.org>; Fri, 12 Apr 2019 07:03:00 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=4cuPvRmlr96e8WLfT+mSrrfBVmvIfgnvujUDxFuQAsU=;
        b=oRe5AsPKBaTkIDLO4arAvISvTi902pQ9KkILpRCIR51IkyiZ69SHwwpZrhYB6SlMAV
         kgzKd59V4FOCw0Gc5x4iC2qQWM/7J3Y1ScXHvGhrKHIezkTQG83pnytXCl7BUzQ8naX4
         UXmQEahVPlFtvSoqtUf4ipQFXgp+eJMT54EJtRSJjiJNZShm81TnRA3Y2jqQN+Hj10x/
         6OIlxaebbHIGxjX3ZLC7GBg7AwwZSB351tKh3MwH0U1Z2rVNPkWltj0dcp4ywqGlbmP9
         JaBOwBpWZeDJQtXYNr1ragDQyXn7rCi/yqD2ureJpCmqee1pzqF4h7smu7rZIUbvdweN
         roaw==
X-Gm-Message-State: APjAAAVIgh9gjgCNdbKZ0TzC68Cx40sl1XHqvm0JQv38xprsO3Jd735Z
	d621oCyEw8iongWAwaGHK3tKTTs05ftKGyMKXqtxQ5q/Pe1CLJfwV2P4jSyDyDQW8N6a4oR5KGL
	T+1URZ8v819NXrgdQ8Lj3jsAs6cdvnEBCdzfSiZfx0wcXwyfzRuWVzGm9RkEf6HxFdA==
X-Received: by 2002:adf:ee91:: with SMTP id b17mr33513008wro.234.1555077779743;
        Fri, 12 Apr 2019 07:02:59 -0700 (PDT)
X-Received: by 2002:adf:ee91:: with SMTP id b17mr33512507wro.234.1555077773681;
        Fri, 12 Apr 2019 07:02:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555077773; cv=none;
        d=google.com; s=arc-20160816;
        b=J4Ih6POeCEJF76rw+wH9evSHw7gn5XjmFm2ddp62SJfN1QMzFf5iLr0WwF6SMzl2+I
         IHK89I0DxT3iOmuqSg05YxSKdSqXnGZqU+siMq/BK1e/76/Pk2dEN24RFMoS5GjPfX9o
         SEq3V8CA10gh7EqbILzUGrBYaQ9gq0P4voJ/amqRRz5Syr3U1pnICOsmu/Ivu3WGQsVg
         MIGHcZJFxxgQqU+Z9UeXdxHBh4U4rsndo44PzzKn8COSdiablC9Wwv2ENh+UqyrmREEV
         fxbmnWgeghBebo/rOXwGxkSs6f3PghqvrFWq80SrJtCGsVWlDIhg9gwbW5pkf9T+8+vM
         b3bQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=4cuPvRmlr96e8WLfT+mSrrfBVmvIfgnvujUDxFuQAsU=;
        b=ipw7E6HbKZuTlO6dEysiC/r318aIl7BAQBdx4XzdvrziVHWJGbnlV+ZyLPY9l0hpk/
         +9mt8eEw9UQprN0KsAS3kI4CQL/8Fi/k3HjAt6/kbA5PR3aHHB8bxEPoFuy/5bizn/rY
         +zOUODVJbFbcjZosvt8iRaNSELSl/dubJYgDp1gUh/8cK3mPVe0sM/q9Fnr1ewdHbXJM
         WLi5M+ZPDr++ZrMQ8kS8UndFj7P3buAmA4Fl1OHnAc4PLOzy+icVtvMtoOiKw8ABhejy
         GTlc+t6Vb4XR1m2y0OPlZNv5u3qM1j8kAhZ2uu1txZ+QLZ2sxW4MLlMWazTo7VaA+UQV
         2WQA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=i5qox0ph;
       spf=pass (google.com: domain of surenb@google.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=surenb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id w2sor30360095wrm.19.2019.04.12.07.02.53
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 12 Apr 2019 07:02:53 -0700 (PDT)
Received-SPF: pass (google.com: domain of surenb@google.com designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=i5qox0ph;
       spf=pass (google.com: domain of surenb@google.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=surenb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=4cuPvRmlr96e8WLfT+mSrrfBVmvIfgnvujUDxFuQAsU=;
        b=i5qox0phJUILhq7TXCJdf8wM2Wde4geIEK+0hhpoTeNbhy6Xt4Umj+sCOpIQw4fgeC
         1L9q8Hw127nInrwIqLd5ZShOLyUiEzQOqbUMprdJ+Grp210MPm/GBn5pb0DYHLrl9t0F
         W0Lm9QKTvJ9gvUbtyq5exZs+AlHU173uprQ7+xcu6hqbhydX2HQM+nFUFuYyqO+/oqKp
         LkeqRR+Uam+dQiuksGZUyDEy45AsH66fmGLG1ugNBY0apA4TRe8DM3B849uj8VFu3Lnk
         TFcZVtDRebs0neVX0yjRtxE01Ye2ca+T/kBXVy8z5EH4HIDBscO/h4qu9FYQCm7ZHRLJ
         +Tjw==
X-Google-Smtp-Source: APXvYqxLicvwrrxFp+5c0BjYa+pxEFFEsoffNpZhy47RlzEwtURUon4CKkILTTCBQDaDf7u2Zh+Sfcm+RlqtMssyGPc=
X-Received: by 2002:adf:f98d:: with SMTP id f13mr36612758wrr.98.1555077772136;
 Fri, 12 Apr 2019 07:02:52 -0700 (PDT)
MIME-Version: 1.0
References: <20190411014353.113252-1-surenb@google.com> <20190411014353.113252-3-surenb@google.com>
 <20190411153313.GE22763@bombadil.infradead.org> <20190412065314.GC13373@dhcp22.suse.cz>
In-Reply-To: <20190412065314.GC13373@dhcp22.suse.cz>
From: Suren Baghdasaryan <surenb@google.com>
Date: Fri, 12 Apr 2019 07:02:41 -0700
Message-ID: <CAJuCfpEiQinN8h5=JeqFFjBdduNJ=x=s3R72Sqs501jyCYVTew@mail.gmail.com>
Subject: Re: [RFC 2/2] signal: extend pidfd_send_signal() to allow expedited
 process killing
To: Michal Hocko <mhocko@kernel.org>
Cc: Matthew Wilcox <willy@infradead.org>, akpm@linux-foundation.org, christian@brauner.io, 
	dancol@google.com, ebiederm@xmission.com, guro@fb.com, hannes@cmpxchg.org, 
	jannh@google.com, joel@joelfernandes.org, jrdr.linux@gmail.com, 
	kernel-team@android.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, 
	lsf-pc@lists.linux-foundation.org, minchan@kernel.org, 
	penguin-kernel@i-love.sakura.ne.jp, rientjes@google.com, shakeelb@google.com, 
	timmurray@google.com, yuzhoujian@didichuxing.com
Content-Type: multipart/alternative; boundary="0000000000003553b0058655c278"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

--0000000000003553b0058655c278
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, Apr 11, 2019 at 11:53 PM Michal Hocko <mhocko@kernel.org> wrote:

> On Thu 11-04-19 08:33:13, Matthew Wilcox wrote:
> > On Wed, Apr 10, 2019 at 06:43:53PM -0700, Suren Baghdasaryan wrote:
> > > Add new SS_EXPEDITE flag to be used when sending SIGKILL via
> > > pidfd_send_signal() syscall to allow expedited memory reclaim of the
> > > victim process. The usage of this flag is currently limited to SIGKIL=
L
> > > signal and only to privileged users.
> >
> > What is the downside of doing expedited memory reclaim?  ie why not do =
it
> > every time a process is going to die?
>
> Well, you are tearing down an address space which might be still in use
> because the task not fully dead yeat. So there are two downsides AFAICS.
> Core dumping which will not see the reaped memory so the resulting
> coredump might be incomplete. And unexpected #PF/gup on the reaped
> memory will result in SIGBUS. These are things that we have closed our
> eyes in the oom context because they likely do not matter. If we want to
> use the same technique for other usecases then we have to think how much
> that matter again.


After some internal discussions we realized that there is one additional
downside of doing reaping unconditionally. If this async reaping is done on
a more efficient and energy hungrier CPU irrespective of urgency of the
kill it should end up costing more power overall (I=E2=80=99m referring her=
e to
assimetric architectures like ARM big.LITTLE). Obviously quantifying that
cost is not easy as it depends on the usecase and a particular system but
it won=E2=80=99t be zero. So I think we will need some gating condition aft=
er all.


>
> --
> Michal Hocko
> SUSE Labs
>
> --
> You received this message because you are subscribed to the Google Groups
> "kernel-team" group.
> To unsubscribe from this group and stop receiving emails from it, send an
> email to kernel-team+unsubscribe@android.com.
>
>

--0000000000003553b0058655c278
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div><div><br></div><div><br><div class=3D"gmail_quote"></div></div></div><=
div><div dir=3D"ltr" class=3D"gmail_attr">On Thu, Apr 11, 2019 at 11:53 PM =
Michal Hocko &lt;<a href=3D"mailto:mhocko@kernel.org" target=3D"_blank">mho=
cko@kernel.org</a>&gt; wrote:<br></div><blockquote class=3D"gmail_quote" st=
yle=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex">On Th=
u 11-04-19 08:33:13, Matthew Wilcox wrote:<br>
&gt; On Wed, Apr 10, 2019 at 06:43:53PM -0700, Suren Baghdasaryan wrote:<br=
>
&gt; &gt; Add new SS_EXPEDITE flag to be used when sending SIGKILL via<br>
&gt; &gt; pidfd_send_signal() syscall to allow expedited memory reclaim of =
the<br>
&gt; &gt; victim process. The usage of this flag is currently limited to SI=
GKILL<br>
&gt; &gt; signal and only to privileged users.<br>
&gt; <br>
&gt; What is the downside of doing expedited memory reclaim?=C2=A0 ie why n=
ot do it<br>
&gt; every time a process is going to die?<br>
<br>
Well, you are tearing down an address space which might be still in use<br>
because the task not fully dead yeat. So there are two downsides AFAICS.<br=
>
Core dumping which will not see the reaped memory so the resulting<br>
coredump might be incomplete. And unexpected #PF/gup on the reaped<br>
memory will result in SIGBUS. These are things that we have closed our<br>
eyes in the oom context because they likely do not matter. If we want to<br=
>
use the same technique for other usecases then we have to think how much<br=
>
that matter again.</blockquote><div dir=3D"auto"><br></div></div><div><div =
dir=3D"auto">After some internal discussions we realized that there is one =
additional downside of doing reaping unconditionally. If this async reaping=
 is done on a more efficient and energy hungrier CPU irrespective of urgenc=
y of the kill it should end up costing more power overall (I=E2=80=99m refe=
rring here to assimetric architectures like ARM big.LITTLE). Obviously quan=
tifying that cost is not easy as it depends on the usecase and a particular=
 system but it won=E2=80=99t be zero. So I think we will need some gating c=
ondition after all.=C2=A0</div></div><div><div><div class=3D"gmail_quote"><=
div dir=3D"auto"><br></div><blockquote class=3D"gmail_quote" style=3D"margi=
n:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex"><br>
<br>
-- <br>
Michal Hocko<br>
SUSE Labs<br>
<br>
-- <br>
You received this message because you are subscribed to the Google Groups &=
quot;kernel-team&quot; group.<br>
To unsubscribe from this group and stop receiving emails from it, send an e=
mail to <a href=3D"mailto:kernel-team%2Bunsubscribe@android.com" target=3D"=
_blank">kernel-team+unsubscribe@android.com</a>.<br>
<br>
</blockquote></div></div>
</div>

--0000000000003553b0058655c278--

