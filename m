Return-Path: <SRS0=pbvW=UU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_IN_DEF_DKIM_WL autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6F501C43613
	for <linux-mm@archiver.kernel.org>; Fri, 21 Jun 2019 15:26:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 23AB92075E
	for <linux-mm@archiver.kernel.org>; Fri, 21 Jun 2019 15:26:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="YBEX22lM"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 23AB92075E
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A65A48E0003; Fri, 21 Jun 2019 11:26:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A17308E0001; Fri, 21 Jun 2019 11:26:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8DD878E0003; Fri, 21 Jun 2019 11:26:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vs1-f71.google.com (mail-vs1-f71.google.com [209.85.217.71])
	by kanga.kvack.org (Postfix) with ESMTP id 665B98E0001
	for <linux-mm@kvack.org>; Fri, 21 Jun 2019 11:26:29 -0400 (EDT)
Received: by mail-vs1-f71.google.com with SMTP id i6so2330059vsp.15
        for <linux-mm@kvack.org>; Fri, 21 Jun 2019 08:26:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc
         :content-transfer-encoding;
        bh=m9xPXeXawroVT7KKEHMkuhFnWVtfnUIIo75zbYHefO4=;
        b=IlCGWK9DnKR0hRWT4T5+K8zlwpPrLFoTEEdAcJr96cE1z7+SLrbOItXk4UCVxY9tYX
         IMs+WlLxJj0RoFCCjheiHxSTLzQMJyLCTTMYqbCXy7neskyyKsDK5FRtpAJg/vCZyjz/
         PcQG7y2t8haKawZOOt5bLmMSNt8foQI4eOg2eAhlRlQFzpRZAOTRirsb3W/6xQlyzuGk
         99ACw+TwFBlnYuQ3DWVZvrXF6zj3v4AyKoO9Ahb5aZyPVLzA/tmqDblX7qAy5HmTbyLS
         uTrfPrMh3VCdWft8VWLAVNVI7fr55KBX1znBjl1pZVVaqLqJZZXoZEvEVIzgcTDC/i+g
         uhrw==
X-Gm-Message-State: APjAAAUNGr3xjGsNpTe1ZqsJYbJwPsVEY8B96QKm4Bu/h+Iq10ureI+X
	hOUYtgeVrf4zUsa+DQd3b9ftKqBOAymL5OiYK07p7EIuttvapAG+MKo8SML8j+a+EB6WE2QbArl
	IuPgXv/SFbT0x7Gicz2etiyanPMVM0Mg0tTC530MOB4Fl2j+QF0pxOn9xjnQJoqbJYg==
X-Received: by 2002:a67:ecd0:: with SMTP id i16mr28160415vsp.110.1561130789188;
        Fri, 21 Jun 2019 08:26:29 -0700 (PDT)
X-Received: by 2002:a67:ecd0:: with SMTP id i16mr28160382vsp.110.1561130788612;
        Fri, 21 Jun 2019 08:26:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561130788; cv=none;
        d=google.com; s=arc-20160816;
        b=MsQqBNNYHrtEyVhfqd2v2DzpYQp/feFbXdQL/LXAomoxxr2DY3QyoNgSFbVY0qx1HV
         3PoVE8Mpq/DteAe7RPWjHMaR5YROXIDvBrQI/4Cn+PPf7Yx95elMDYmBBMal4Wunn9Gh
         MPq5mFmK2pJQAuwYRfti4C+SBJOHUhA62wBkW88tuZCjdMob3rXtsoDhft+BoZmoZo9D
         VxCGjoBbY5vtQu+se4R3EajCwmhG81P6AnDusveBIUR7gehX6cOlmu6rR1aczG3AW0VO
         k9U4ruIs4P2xnuX7vGVvFlrA75ri0e792FXX80UEdNkOffqBnFo0g/rQsT0nGNR8kRlL
         vHMw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=m9xPXeXawroVT7KKEHMkuhFnWVtfnUIIo75zbYHefO4=;
        b=JOoGxlof3dJh+RD2sSZgDUKoFJ147HACq1o24VvEFTJpmKd2Q4tfT/Ez8rV0PTNH53
         +dRwFOgQoDEKsIfOtohHkfXq60LPfNSdgMxQktqr8WIBVRIQl25xPAXy9sTKP4rKL67M
         td7cGT6aFWdSqGKC32lQK7HgFY0dRgpL7WsEABVMGJnoCVUbDy0OZO7mStqI0dcEG+0S
         grEqB+Tj9kSV3bv5tmWJO8cohHhqs8orgUGE/8eWA3dj+2d1m0NOzxQ8noQylBbdBBZE
         VlkHasxoIBbjrnrTUfJSvX2ny5gxf+9SeucjEgtLIF1hmaWnicajhGCTS8/mxsBf19pJ
         5zYA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=YBEX22lM;
       spf=pass (google.com: domain of glider@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=glider@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p10sor1788670uap.25.2019.06.21.08.26.28
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 21 Jun 2019 08:26:28 -0700 (PDT)
Received-SPF: pass (google.com: domain of glider@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=YBEX22lM;
       spf=pass (google.com: domain of glider@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=glider@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=m9xPXeXawroVT7KKEHMkuhFnWVtfnUIIo75zbYHefO4=;
        b=YBEX22lMJJKj2bmHZv1K3QQAcVuuhP05htHRnyHmGf/+YvfbPemLwthJCwddhDJMez
         P0alncQzTaYxrvqvoqEiTdRZTCxyv8TSzXI7vv8JpY/XYStJ1o20ZsSy1UkoV/UnZ5Qw
         Golh+FkaB/+O99INvf1UMbJE0OBe13BM7mOGNWFaJOxHkQzbl4FOBUug8dLehdHZs8e3
         X+wBW/u+uooc4Ft3o/XUSOyDXXTsijrolJemXu0TSQgkOMDQtKZljZ7u097Yph5jf2LI
         4pC0VmggjJUbtf/Di21odO5SJ+gIpVmdW3sEdq5kXJ/do9bCAVldj7bptTWcL6JUkWtE
         aT5Q==
X-Google-Smtp-Source: APXvYqwU46O0o2fxlmglOdVQi4samVl5zWnKIA9+EYAQ4iWnFaAAISJNikzzcSR24FhYl6xOESBzerPu9dVJbUwKQPA=
X-Received: by 2002:ab0:3d2:: with SMTP id 76mr1131532uau.12.1561130788062;
 Fri, 21 Jun 2019 08:26:28 -0700 (PDT)
MIME-Version: 1.0
References: <1561063566-16335-1-git-send-email-cai@lca.pw> <201906201801.9CFC9225@keescook>
 <CAG_fn=VRehbrhvNRg0igZ==YvONug_nAYMqyrOXh3kO2+JaszQ@mail.gmail.com>
 <1561119983.5154.33.camel@lca.pw> <CAG_fn=WGdFZNrUCeMtbx4wbHhxWqM2s7Vq_GvnMC-9WJZ_mioQ@mail.gmail.com>
 <1561128967.5154.45.camel@lca.pw>
In-Reply-To: <1561128967.5154.45.camel@lca.pw>
From: Alexander Potapenko <glider@google.com>
Date: Fri, 21 Jun 2019 17:26:16 +0200
Message-ID: <CAG_fn=VCF+sXQE3VxvBRa_a97rX8tVGSTXQsk9uiOH=q6Rg9Pw@mail.gmail.com>
Subject: Re: [PATCH -next v2] mm/page_alloc: fix a false memory corruption
To: Qian Cai <cai@lca.pw>
Cc: Kees Cook <keescook@chromium.org>, Andrew Morton <akpm@linux-foundation.org>, 
	Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jun 21, 2019 at 4:56 PM Qian Cai <cai@lca.pw> wrote:
>
> On Fri, 2019-06-21 at 16:37 +0200, Alexander Potapenko wrote:
> > On Fri, Jun 21, 2019 at 2:26 PM Qian Cai <cai@lca.pw> wrote:
> > >
> > > On Fri, 2019-06-21 at 12:39 +0200, Alexander Potapenko wrote:
> > > > On Fri, Jun 21, 2019 at 3:01 AM Kees Cook <keescook@chromium.org> w=
rote:
> > > > >
> > > > > On Thu, Jun 20, 2019 at 04:46:06PM -0400, Qian Cai wrote:
> > > > > > The linux-next commit "mm: security: introduce init_on_alloc=3D=
1 and
> > > > > > init_on_free=3D1 boot options" [1] introduced a false positive =
when
> > > > > > init_on_free=3D1 and page_poison=3Don, due to the page_poison e=
xpects the
> > > > > > pattern 0xaa when allocating pages which were overwritten by
> > > > > > init_on_free=3D1 with 0.
> > > > > >
> > > > > > Fix it by switching the order between kernel_init_free_pages() =
and
> > > > > > kernel_poison_pages() in free_pages_prepare().
> > > > >
> > > > > Cool; this seems like the right approach. Alexander, what do you =
think?
> > > >
> > > > Can using init_on_free together with page_poison bring any value at=
 all?
> > > > Isn't it better to decide at boot time which of the two features we=
're
> > > > going to enable?
> > >
> > > I think the typical use case is people are using init_on_free=3D1, an=
d then
> > > decide
> > > to debug something by enabling page_poison=3Don. Definitely, don't wa=
nt
> > > init_on_free=3D1 to disable page_poison as the later has additional c=
hecking
> > > in
> > > the allocation time to make sure that poison pattern set in the free =
time is
> > > still there.
> >
> > In addition to information lifetime reduction the idea of init_on_free
> > is to ensure the newly allocated objects have predictable contents.
> > Therefore it's handy (although not strictly necessary) to keep them
> > zero-initialized regardless of other boot-time flags.
> > Right now free_pages_prezeroed() relies on that, though this can be cha=
nged.
> >
> > On the other hand, since page_poison already initializes freed memory,
> > we can probably make want_init_on_free() return false in that case to
> > avoid extra initialization.
> >
> > Side note: if we make it possible to switch betwen 0x00 and 0xAA in
> > init_on_free mode, we can merge it with page_poison, performing the
> > initialization depending on a boot-time flag and doing heavyweight
> > checks under a separate config.
>
> Yes, that would be great which will reduce code duplication.
I suggest we disable init_on_alloc/init_on_free under
CONFIG_PAGE_POISONING now then and work towards deduplicating this
code in further patch series.


--=20
Alexander Potapenko
Software Engineer

Google Germany GmbH
Erika-Mann-Stra=C3=9Fe, 33
80636 M=C3=BCnchen

Gesch=C3=A4ftsf=C3=BChrer: Paul Manicle, Halimah DeLaine Prado
Registergericht und -nummer: Hamburg, HRB 86891
Sitz der Gesellschaft: Hamburg

