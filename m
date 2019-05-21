Return-Path: <SRS0=IGNm=TV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_IN_DEF_DKIM_WL autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C698FC04AAF
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 15:53:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7A3C221019
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 15:53:09 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="SCWW9XLd"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7A3C221019
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 28E096B0006; Tue, 21 May 2019 11:53:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 240C16B0007; Tue, 21 May 2019 11:53:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 131176B0008; Tue, 21 May 2019 11:53:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f199.google.com (mail-vk1-f199.google.com [209.85.221.199])
	by kanga.kvack.org (Postfix) with ESMTP id E5B196B0006
	for <linux-mm@kvack.org>; Tue, 21 May 2019 11:53:08 -0400 (EDT)
Received: by mail-vk1-f199.google.com with SMTP id z6so901463vkd.12
        for <linux-mm@kvack.org>; Tue, 21 May 2019 08:53:08 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc
         :content-transfer-encoding;
        bh=M+Fy+Dv7IAvIp9wM9LD81KQdUDxns6+Ve3Y3gCcA6+w=;
        b=FEIOOlN/qqKydW3yuyn6MfntAJuGyU8mkCMVkk0pUTwpm/ep6nJ/lAqmuxyXfRfeQz
         rbvZekHfkNPxDOLpGnAUlUhNdK8VRb4oyACy0q2vaBgD0ssZ+tawJV9uKSQoyh6sZkGz
         7DUBWQBXXZstqKGDBPdKTbEmIQsQTiMLz3t8/30wYKI9eQceGetTkqklDx+qcN87K2cO
         xevpmjD4eWpAZs1WiP/3yUqnJCmTdYnUXjhq+zXnZgF6w7sNxNNOChQTEhExgLK3i8O3
         fdVWyD+dc4028vWLqN7D9DEexS9okPolYGsmmYRXlFN1U17cldd8T0qQnSI/46pOQpgR
         PTdg==
X-Gm-Message-State: APjAAAX3Wdoa2fcH7wJZX2sALDmdDbeWErL4mR5BBQDYSc8bS0dSVbmr
	jzU++Lb1zE+91awENaLAzHnCeg3sdpPOqv0YDa4rbWLMpm23IEF5+uHeoYelwBn/zS2MZ6Ngu82
	rI2A5d+rBQEjtJd4M5o++aHvPqnVsz6oNhaqkIfmmAPhbaednb8BzyseXEt+gZlgnEQ==
X-Received: by 2002:a67:f88f:: with SMTP id h15mr23085285vso.67.1558453988439;
        Tue, 21 May 2019 08:53:08 -0700 (PDT)
X-Received: by 2002:a67:f88f:: with SMTP id h15mr23085263vso.67.1558453987876;
        Tue, 21 May 2019 08:53:07 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558453987; cv=none;
        d=google.com; s=arc-20160816;
        b=uhS07/V+3SeA+s7hSSB3ObnwMTVRlUWBDXK1TRC/LbtdVO7MPhJWBJcLkq69/Y5A+r
         4bpDW6VXjsiCb1OO04ee9OQWqMUCQVfjf+nr0A+Mg0tRM5ly/US5H3lTGw7aCoKhhWgO
         LqlOM7ueKJGV1wDNpnmkOW8yuSnwMMTGfVumJnInQbAb/LG6rAn/80AB49CrXH+fsdbL
         iJy+Y5qHPs6v1JeH44a6lR3iYJ7tVNmma4avaFltWcmb4yAo0vZyirdGsT70dkwb/JHT
         ulM1Sh5Ilc2kleNF/yyhxGH1YtUwBVem9XxskbQTBO9jyHKGzmqZS5KSZbIar63+Na4U
         /Uyg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=M+Fy+Dv7IAvIp9wM9LD81KQdUDxns6+Ve3Y3gCcA6+w=;
        b=RUhUsLCgXzkJgQksPiPWLrnmKLp9E9qFTkeC7DYqc39oufbJB10DYFWNubq5w4X8pm
         wAdvAo1I8S44SqffI/L4wH93LRAY1SuNyWobnNf4JSPlNXZCCIx/SLm/omefxeWG/FEz
         VEExGvwHPJELUD7tpTv37IkwU38t5DwPgTNrbi/et8WeQMPLY8MJM0/8OAebzlPiCYMm
         q51NOmPV07cf/zkwuaJnkCoENG5s/bSQ1M21DeTxnflW7AUJJe0wEC0H5Ju50LDReq8T
         9iedQW6PEupnZzsUEpMW8uIg/IHpFbxhGjI95diWXoHEtj2JacrUI+rrar00FXMMzSq0
         dugQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=SCWW9XLd;
       spf=pass (google.com: domain of glider@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=glider@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y12sor1072949vsl.81.2019.05.21.08.53.07
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 21 May 2019 08:53:07 -0700 (PDT)
Received-SPF: pass (google.com: domain of glider@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=SCWW9XLd;
       spf=pass (google.com: domain of glider@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=glider@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=M+Fy+Dv7IAvIp9wM9LD81KQdUDxns6+Ve3Y3gCcA6+w=;
        b=SCWW9XLdsPw9Dbsh5KL6xVyDY0rX4O5d9enGOPhpycV9Y6K9rosydI/Wlk6NyU8Kte
         BDjViIeiW8pDzy0+pXpuKIfOK6q7lCzsR5o+tsDOcS4oVA/Plo1Z/Gl7Xaw4/S3dfjlP
         +TYxG53nLwL/Hdxn/s7e8xypiQ2nTrPoW61MZCVDiWXaRdvGPcbHk5weJMjYioOICzdR
         HDJC8Ks4/5DvyQMaqKCbH20Idmf9eRPgf4NxzUvXhYL1aiewFYDHnFJO8yWGFdC4Sto5
         DpzS2u0AHAD5Fl5qXsTv9dmc55eSJa/zwDTnnViImT0urRRTpNpJ3KPIQsiYspU1cWtG
         Qnjw==
X-Google-Smtp-Source: APXvYqy6IGMQPbJZO+kIouZqRoFw9qUZHLRLgIs6Dh6Xv5coJSMBcpEofSB2jHGaaeH09CNzCZFcAI0DOxFM1m/T2nA=
X-Received: by 2002:a67:d615:: with SMTP id n21mr26515680vsj.39.1558453987203;
 Tue, 21 May 2019 08:53:07 -0700 (PDT)
MIME-Version: 1.0
References: <20190520154751.84763-1-elver@google.com> <ebec4325-f91b-b392-55ed-95dbd36bbb8e@virtuozzo.com>
In-Reply-To: <ebec4325-f91b-b392-55ed-95dbd36bbb8e@virtuozzo.com>
From: Alexander Potapenko <glider@google.com>
Date: Tue, 21 May 2019 17:52:55 +0200
Message-ID: <CAG_fn=W+_Ft=g06wtOBgKnpD4UswE_XMXd61jw5ekOH_zeUVOQ@mail.gmail.com>
Subject: Re: [PATCH v2] mm/kasan: Print frame description for stack bugs
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Marco Elver <elver@google.com>, Dmitriy Vyukov <dvyukov@google.com>, 
	Andrey Konovalov <andreyknvl@google.com>, Andrew Morton <akpm@linux-foundation.org>, 
	LKML <linux-kernel@vger.kernel.org>, 
	Linux Memory Management List <linux-mm@kvack.org>, kasan-dev <kasan-dev@googlegroups.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, May 21, 2019 at 5:43 PM Andrey Ryabinin <aryabinin@virtuozzo.com> w=
rote:
>
>
>
> On 5/20/19 6:47 PM, Marco Elver wrote:
>
> > +static void print_decoded_frame_descr(const char *frame_descr)
> > +{
> > +     /*
> > +      * We need to parse the following string:
> > +      *    "n alloc_1 alloc_2 ... alloc_n"
> > +      * where alloc_i looks like
> > +      *    "offset size len name"
> > +      * or "offset size len name:line".
> > +      */
> > +
> > +     char token[64];
> > +     unsigned long num_objects;
> > +
> > +     if (!tokenize_frame_descr(&frame_descr, token, sizeof(token),
> > +                               &num_objects))
> > +             return;
> > +
> > +     pr_err("\n");
> > +     pr_err("this frame has %lu %s:\n", num_objects,
> > +            num_objects =3D=3D 1 ? "object" : "objects");
> > +
> > +     while (num_objects--) {
> > +             unsigned long offset;
> > +             unsigned long size;
> > +
> > +             /* access offset */
> > +             if (!tokenize_frame_descr(&frame_descr, token, sizeof(tok=
en),
> > +                                       &offset))
> > +                     return;
> > +             /* access size */
> > +             if (!tokenize_frame_descr(&frame_descr, token, sizeof(tok=
en),
> > +                                       &size))
> > +                     return;
> > +             /* name length (unused) */
> > +             if (!tokenize_frame_descr(&frame_descr, NULL, 0, NULL))
> > +                     return;
> > +             /* object name */
> > +             if (!tokenize_frame_descr(&frame_descr, token, sizeof(tok=
en),
> > +                                       NULL))
> > +                     return;
> > +
> > +             /* Strip line number, if it exists. */
>
>    Why?
>
> > +             strreplace(token, ':', '\0');
> > +
>
> ...
>
> > +
> > +     aligned_addr =3D round_down((unsigned long)addr, sizeof(long));
> > +     mem_ptr =3D round_down(aligned_addr, KASAN_SHADOW_SCALE_SIZE);
> > +     shadow_ptr =3D kasan_mem_to_shadow((void *)aligned_addr);
> > +     shadow_bottom =3D kasan_mem_to_shadow(end_of_stack(current));
> > +
> > +     while (shadow_ptr >=3D shadow_bottom && *shadow_ptr !=3D KASAN_ST=
ACK_LEFT) {
> > +             shadow_ptr--;
> > +             mem_ptr -=3D KASAN_SHADOW_SCALE_SIZE;
> > +     }
> > +
> > +     while (shadow_ptr >=3D shadow_bottom && *shadow_ptr =3D=3D KASAN_=
STACK_LEFT) {
> > +             shadow_ptr--;
> > +             mem_ptr -=3D KASAN_SHADOW_SCALE_SIZE;
> > +     }
> > +
>
> I suppose this won't work if stack grows up, which is fine because it gro=
ws up only on parisc arch.
> But "BUILD_BUG_ON(IS_ENABLED(CONFIG_STACK_GROUWSUP))" somewhere wouldn't =
hurt.
Note that KASAN was broken on parisc from day 1 because of other
assumptions on the stack growth direction hardcoded into KASAN
(e.g. __kasan_unpoison_stack() and __asan_allocas_unpoison()).
So maybe this BUILD_BUG_ON can be added in a separate patch as it's
not specific to what Marco is doing here?
>
> --
> You received this message because you are subscribed to the Google Groups=
 "kasan-dev" group.
> To unsubscribe from this group and stop receiving emails from it, send an=
 email to kasan-dev+unsubscribe@googlegroups.com.
> To post to this group, send email to kasan-dev@googlegroups.com.
> To view this discussion on the web visit https://groups.google.com/d/msgi=
d/kasan-dev/ebec4325-f91b-b392-55ed-95dbd36bbb8e%40virtuozzo.com.
> For more options, visit https://groups.google.com/d/optout.



--=20
Alexander Potapenko
Software Engineer

Google Germany GmbH
Erika-Mann-Stra=C3=9Fe, 33
80636 M=C3=BCnchen

Gesch=C3=A4ftsf=C3=BChrer: Paul Manicle, Halimah DeLaine Prado
Registergericht und -nummer: Hamburg, HRB 86891
Sitz der Gesellschaft: Hamburg

