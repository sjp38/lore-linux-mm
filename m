Return-Path: <SRS0=HJeg=QJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,PLING_QUERY,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 55C44C282DB
	for <linux-mm@archiver.kernel.org>; Sat,  2 Feb 2019 11:52:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E415820818
	for <linux-mm@archiver.kernel.org>; Sat,  2 Feb 2019 11:52:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="RD7FJlwk"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E415820818
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4CE0C8E0018; Sat,  2 Feb 2019 06:52:40 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 47CCF8E0001; Sat,  2 Feb 2019 06:52:40 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 36C5C8E0018; Sat,  2 Feb 2019 06:52:40 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id D3E2B8E0001
	for <linux-mm@kvack.org>; Sat,  2 Feb 2019 06:52:39 -0500 (EST)
Received: by mail-wr1-f69.google.com with SMTP id x3so3325545wru.22
        for <linux-mm@kvack.org>; Sat, 02 Feb 2019 03:52:39 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=Ksj9lR9aCRIAxKlY5wuozGKeWj7FX+QSVWoU3V6r49Y=;
        b=pXGtB2UVYOW93XOnP9WT3CWrArKeyU3K8Ln9Et+HPs+2O6i/T6IoeyEN+onEG5jxTa
         JTAroHnp0vYSp9VVlUzxPXEXe/RCWD+4NFSz+S2PaJNEHnkkrDV6Cd02Mr7b9pTapVIJ
         eR9BpCtttayOJDKLXrT8+oVtNNOEhsdVHe3PL7PagpvfHnVokCbbyRuMHMeK5ea3em0V
         vzKMlbQkjt9aczY1hbAp95Mh0CnK8wgGjWG2rIBTH8B8i4a/M1DR+/uS17Ih1+nkKUpY
         y3jH4dYjzF9jZ37i7sLi0UPDmxmtSSMDzMvLx5KS3R5TSBefc83eD2AHCzHsdKTWK3ae
         y/1g==
X-Gm-Message-State: AHQUAuY3zoXByPfNIGB5milFBPfCoC9AXGcWcWLCDVyWtUjpxd7Ico1c
	oeklT9RW6cPobNRg/cMwpz1DmW/X7PLZLiu6MitiQvUsU9OeTtJDh9MOld5RGLjt9hMfSdxqQ3t
	YbJioYIMmtf0kR9ev+tDwcUD1U8YpbuXyyLrB+EsApuKNfn1fQ5yso4xebdB2139/aWm3fzxifP
	q44QrVKaBcCJoqJn8YWkjTI/MzMs8zmckre0M37YPu+2WNhuLwpu6PVm2jctiEdIpiKojeSYUgw
	JttTYmxphUHVbLPsClYkzXG/etOmXP7pAhy43r60Xx5+Bwu4L5nk5I6MY/zTicCVoUmVSvSLJ1W
	X5LjhuAfm+rSSsyEm6PVSJIt1F26mux4oiXeWncnXb5ajAmV5+Nbc5/QapGGTvVLUmVTw5+8tSZ
	8
X-Received: by 2002:a1c:cec1:: with SMTP id e184mr6371121wmg.75.1549108359138;
        Sat, 02 Feb 2019 03:52:39 -0800 (PST)
X-Received: by 2002:a1c:cec1:: with SMTP id e184mr6371079wmg.75.1549108358069;
        Sat, 02 Feb 2019 03:52:38 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549108358; cv=none;
        d=google.com; s=arc-20160816;
        b=SkmeZZ+izBd7prNIEfT7FWPPDiCtTxnscGPItshK+KBds9SIbp6z2elZS3q4GEpxCh
         jEq9Lh+YVMGvyjQDF6TGiey895BsYOhda4QOM63XhqwnnYKUzhHu0nSS9ONWmqbANHsV
         DwQs/WhWjaJc2rF82XB1CnGHA5lgl03od/p1EZweNs7cWpUoGnit7yhf/fSMeaqcrxuT
         Zmb8v+4iBTv30xIDWT4cbBIp59M9l0c8MjMTPeDMjERm8H4ojNJOKpNxu2fxXlXCu4uW
         NeVHRpQZOPAJyx4m9Ur89GP6SUrgEbVLk5fvD2MKsH0+xVQ+EFKmT4WDBQssp/xbAXhi
         s8pA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=Ksj9lR9aCRIAxKlY5wuozGKeWj7FX+QSVWoU3V6r49Y=;
        b=gyi5KYacaoJY0MwxxWGnt7jii5fun1g2o/K50MrjV9AgI86+tYSbIxr5btnW5Mltkj
         QCKz5fkVnXfaGwHPaEopCtgf6lhnw+D/GQqM8b7ppHRIlujHwPIQNllUhRiMtK6BgmdB
         ipzcEEo/KWEK0KYtnvaq43nFcssrFi8a0EHEDcxdVyTYxB9Sl/Fm1/dkn9Y2L17Y0ZsN
         kjN1ZQ3ytMNnAZic3nhMzslPK2QgcKfYizqb7eaV9c1AEZqLNHorRTfDlCNVY6X+pkpd
         Np09smOkvvMoU6djUXNaw51KCh/SuJK07O0/HkeaZop6xjDdLVScWyNSFxHNxB3i1h6z
         0r7A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=RD7FJlwk;
       spf=pass (google.com: domain of zenghuiyu96@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=zenghuiyu96@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p9sor2750615wrq.21.2019.02.02.03.52.37
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 02 Feb 2019 03:52:38 -0800 (PST)
Received-SPF: pass (google.com: domain of zenghuiyu96@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=RD7FJlwk;
       spf=pass (google.com: domain of zenghuiyu96@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=zenghuiyu96@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=Ksj9lR9aCRIAxKlY5wuozGKeWj7FX+QSVWoU3V6r49Y=;
        b=RD7FJlwk6dyu39zhTyejr6x+hkwOVQLzObRwjw3svckwdOAWEs5qlUrGI1WrTULLt9
         aYRPIC5yuOm9OVhGUV3GkbFTHfBe+WzgJQxlF4MK+cEDAUPasp1IL6qKY9E56GIu3eIE
         t9I/XWdoXItZ7PBhvjf6IPMpO/qZFYqgO0/zIUKSjtDuL3B10U3mNz+xRye/+5arTWbp
         cvx8anxgNUhV+E/vVV3tMVYS65UdgjkkrR1oPDjCZK/GFg9SB+zsrVzFWwMJaxvBKJfW
         1t4IWaM3PMJu0rPTRPkk/ndWEdwRa17+80zxyXshudN1aCwoEO3tTJqMVhuvTXcL420G
         DeVg==
X-Google-Smtp-Source: ALg8bN7Q+G/hi+qkocjZsl7fVgDev5XTi14ZjGY4GY5hfNitqwJGIst7JcbcD7FPrgU4cCmgN2pXACrXWp4EDOH1iak=
X-Received: by 2002:adf:ae1a:: with SMTP id x26mr41120668wrc.0.1549108357587;
 Sat, 02 Feb 2019 03:52:37 -0800 (PST)
MIME-Version: 1.0
References: <CAKcZhuW-ozJp-MVU3gw=uhuSc9+HTMVJza8QRUL3TaRrbqjJew@mail.gmail.com>
 <CACT4Y+aJADsj37Y8jPAV7PASqKm_L-iJ=MDv68yPUO0TFvhdRg@mail.gmail.com>
 <CACT4Y+ZxgzdbCeFquYmKThfiTGg3pZhn90X_Fk3yRXGYfepU4Q@mail.gmail.com>
 <CAKcZhuWE_2+D_AP_U0XZP-bjb=8Eec1Ku3KD8qO8K0zDGo98Ow@mail.gmail.com>
 <CACT4Y+Ye+0bBV5sB1F3wVbCC1guyA=RdsRnYHgrar=AhftGtQA@mail.gmail.com>
 <20190121175842.0f526757@vmware.local.home> <CACT4Y+Y7PJ1=dv6wzDTVRkFJCnrtDYyksmYp6UibW9a8_ob0Nw@mail.gmail.com>
In-Reply-To: <CACT4Y+Y7PJ1=dv6wzDTVRkFJCnrtDYyksmYp6UibW9a8_ob0Nw@mail.gmail.com>
From: Zenghui Yu <zenghuiyu96@gmail.com>
Date: Sat, 2 Feb 2019 19:52:24 +0800
Message-ID: <CAKcZhuXfgXvpb2YNVanA_TZHzHWj59_sB2YYwyTsoXKeW2bG2g@mail.gmail.com>
Subject: Re: [RESEND BUG REPORT] System hung! Due to ftrace or KASAN?
To: Andrew Morton <akpm@linux-foundation.org>, Dmitry Vyukov <dvyukov@google.com>
Cc: Linux-MM <linux-mm@kvack.org>, Dave Hansen <dave.hansen@linux.intel.com>, 
	Andy Lutomirski <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>, 
	Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, 
	"H. Peter Anvin" <hpa@zytor.com>, "the arch/x86 maintainers" <x86@kernel.org>, linux-trace-devel@vger.kernel.org, 
	kasan-dev <kasan-dev@googlegroups.com>, 
	"open list:KERNEL BUILD + fi..." <linux-kbuild@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, 
	Andrey Konovalov <andreyknvl@google.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, 
	Linus Torvalds <torvalds@linux-foundation.org>, Christoph Lameter <cl@linux.com>, 
	Mark Rutland <mark.rutland@arm.com>, Will Deacon <will.deacon@arm.com>, 
	Steven Rostedt <rostedt@goodmis.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jan 29, 2019 at 9:16 PM Dmitry Vyukov <dvyukov@google.com> wrote:
>
> On Tue, Jan 29, 2019 at 1:27 AM Andrew Morton <akpm@linux-foundation.org> wrote:
> >
> > On Mon, 21 Jan 2019 10:36:25 +0100 Dmitry Vyukov <dvyukov@google.com> wrote:
> >
> > > > Thanks Dmitry! I'll try to test this commit tomorrow.
> > > >
> > > > BTW, I have bisect-ed and tested for this issue today. Finally it turned out
> > > > that
> > > >         bffa986c6f80e39d9903015fc7d0d99a66bbf559 is the first bad commit.
> > > > So I'm wondering if anywhere need to be fixed in commit bffa986c6f80 ("kasan:
> > > > move common generic and tag-based code to common.c").
> > >
> > > Thanks for bisecting. I think we have understanding of what happens
> > > here and it's exactly this that needs to be fixed:
> > > https://groups.google.com/d/msg/kasan-dev/g8A8PLKCyoE/vXnirYEnCAAJ
> > > And this commit already fixes it.
> >
> > Has that been sent in my direction?  I can't find it.
> >
> > If sending it please add
> >
> > Tested-by: Dmitry Vyukov <dvyukov@google.com>
> > Acked-by: Steven Rostedt (VMware) <rostedt@goodmis.org>
>

Also,

Tested-by: Zenghui Yu <zenghuiyu96@gmail.com>

on x86 machines, if need :)


Thanks!

>
> Yes, it's here (State: New):
> https://lore.kernel.org/patchwork/patch/1024393/
>
> This page says it was mailed to linux-mm mailing list too:
> https://groups.google.com/forum/#!topic/kasan-dev/g8A8PLKCyoE
>
> But I can't find linux-mm archives here:
> http://vger.kernel.org/vger-lists.html
>
> How can I add a tag to an existing change under review? Patchwork does
> not show something like "add Tested-by: me tag" to me on the patch
> page.
>
> Patchwork shows Todo list on the main page with "Your todo list
> contains patches that have been delegated to you". But I don't see an
> option to delegate this patch to you either...

