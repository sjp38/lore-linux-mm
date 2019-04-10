Return-Path: <SRS0=DRoR=SM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A19B2C10F11
	for <linux-mm@archiver.kernel.org>; Wed, 10 Apr 2019 18:27:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6465420830
	for <linux-mm@archiver.kernel.org>; Wed, 10 Apr 2019 18:27:44 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="bSr7MxHC"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6465420830
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E8A056B0003; Wed, 10 Apr 2019 14:27:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E39C76B0005; Wed, 10 Apr 2019 14:27:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D4E706B0006; Wed, 10 Apr 2019 14:27:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ua1-f69.google.com (mail-ua1-f69.google.com [209.85.222.69])
	by kanga.kvack.org (Postfix) with ESMTP id ADAAE6B0003
	for <linux-mm@kvack.org>; Wed, 10 Apr 2019 14:27:43 -0400 (EDT)
Received: by mail-ua1-f69.google.com with SMTP id j8so365356uaq.13
        for <linux-mm@kvack.org>; Wed, 10 Apr 2019 11:27:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=EWEqtNllEvpYJI4SR8SxraijSXCc4AK8CwC4R1aamEI=;
        b=B2XyOI46M9R0mnf5cPVKfGubnfEZXti9g+9HPdNU4Klt3gNP2Wsv/uKSiIoWcjxyMB
         kcqiFhFpCxErDWPcxoC1CTLod62QDwq7A6dI1KJCMcAs0A+rrVmkcpDIOGAVxpNsH1Em
         gRUZ3aiXsa5keBYsrSpavSp1XM4CtljWS5uhDLkjdLFpfoxqX6u5qohwwjuBH5HE4nr0
         17SzHyk4bGZmJ9VEVGGu05LSq1TJc3/e275Jl1WAfAPLQ7TSmYQZxFkjN4ermQ65Gsfb
         i7S1YkxlXA1Jvwj6Pz3NXBzTo1l7MUugHiv4N6suLN4SZcLMTsNegEHYGz/X2GOIfpJQ
         frnA==
X-Gm-Message-State: APjAAAVbUvUQ0Au5xLMH+PQKYwZbw6Xwe9dyrn+qdsPTYy3MYNzy9AG5
	GGb+yurfBxyJTRRNDhAv2ZlzGVX0xkRwAPy7vbZwytDcMFZdON5WmSXi3uv/HPWENrNtctzsRuu
	JO+LYtAZSN3HwVkEm8X8NEKuW4GaFtYcUqpdEiEdshF05PGE5v1r7yh2KqkjRSwEezA==
X-Received: by 2002:ab0:70d4:: with SMTP id r20mr7547191ual.67.1554920863361;
        Wed, 10 Apr 2019 11:27:43 -0700 (PDT)
X-Received: by 2002:ab0:70d4:: with SMTP id r20mr7547153ual.67.1554920862700;
        Wed, 10 Apr 2019 11:27:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554920862; cv=none;
        d=google.com; s=arc-20160816;
        b=L9caClRiJ5FnQIwhlMRgK+At9MnwLioQAhGj5SvZN0TA9VTsT94uzKUZuJt3HyuXnK
         wAyinYdUnmgA8ZypfbbFcqhQT75dERCgMxp6L1FghiLdEO30/lHlSxe+44m/7yfXImQX
         oQ+uwcPXI/e693ndzE4OXTSypT2fIsrzHUI6vyPZJisy/+Elr3p8xCjRSeg4fUrwK0H4
         jFp3gT5twAzgo8OBv1+Jr49z2NU6ksClr3vaHUDvsYmhUCLp+IBeHN+xWlfHTJIgTg0S
         r4QBP1A+iL1CZEmh9aWDdFBC2a2zTfaodx3pfk4UzynvwN3su0bqcia9MSzgWYcw3n2Q
         D1ew==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=EWEqtNllEvpYJI4SR8SxraijSXCc4AK8CwC4R1aamEI=;
        b=LawZaIutvdjc9+9887y7B+52GhKmbHfNmn8y7uMIb8MMWHqit3R0Su6PsBHjTIzD9d
         mqtQjI891nOUrX2WaC0+V1/gpXU0wzirBr8wSzeYrauqiwfPVApuPOhOoIiGCPm6ipgS
         9G7/jkoPTyqxrdTs7qB6Hvb9lJ/BSxZGwE/PegCaRAbHW8iyTbolXy+sCX53q7lWpFFy
         FlJ5BWNnA0aKFP6Y3GGGdjuaDQyPyKC46hGvi0CzP9pRrL3eMiOl1hyny0CfixkvFzVA
         pfXgjKbmwowOimHi91GolG3N8EqDQenJ3ZK0TfpiCNWQjgYh+5AFcco9rfxYE7ADoyRo
         CfnA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=bSr7MxHC;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y76sor21966647vsc.39.2019.04.10.11.27.42
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 10 Apr 2019 11:27:42 -0700 (PDT)
Received-SPF: pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=bSr7MxHC;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chromium.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=EWEqtNllEvpYJI4SR8SxraijSXCc4AK8CwC4R1aamEI=;
        b=bSr7MxHCBXn6h0g3WRGDyc2DhbuqqkdN6kW4p22Hos+GjTZLWrFrQlrp7jWHR6ShdZ
         2uemyxpXrWgr4x5PSuKplueV9Xenc396YezASzbUdmimeusHUAsVR9xEc9/Ce4YVvdd/
         +FKf9Ta+3vfdBUTnObARr7b4AQUoa15vGEWKE=
X-Google-Smtp-Source: APXvYqxvEQNUqBLkEEPFvVjr2HavNAGm++yB403vYq4LhMs7whUjP9G9a1eXtUy9NW4BQnF1USNfWQ==
X-Received: by 2002:a67:7c8a:: with SMTP id x132mr24726477vsc.172.1554920862105;
        Wed, 10 Apr 2019 11:27:42 -0700 (PDT)
Received: from mail-vs1-f48.google.com (mail-vs1-f48.google.com. [209.85.217.48])
        by smtp.gmail.com with ESMTPSA id g184sm4946430vkd.31.2019.04.10.11.27.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Apr 2019 11:27:39 -0700 (PDT)
Received: by mail-vs1-f48.google.com with SMTP id d8so1963835vsp.2
        for <linux-mm@kvack.org>; Wed, 10 Apr 2019 11:27:39 -0700 (PDT)
X-Received: by 2002:a67:7816:: with SMTP id t22mr24096520vsc.115.1554920858548;
 Wed, 10 Apr 2019 11:27:38 -0700 (PDT)
MIME-Version: 1.0
References: <20190404055128.24330-1-alex@ghiti.fr> <20190404055128.24330-3-alex@ghiti.fr>
 <20190410065908.GC2942@infradead.org> <8d482fd0-b926-6d11-0554-a0f9001d19aa@ghiti.fr>
In-Reply-To: <8d482fd0-b926-6d11-0554-a0f9001d19aa@ghiti.fr>
From: Kees Cook <keescook@chromium.org>
Date: Wed, 10 Apr 2019 11:27:27 -0700
X-Gmail-Original-Message-ID: <CAGXu5jKt8f7=DKrvcPg-NUJGbc-vanMNojfDsEiBt3vP05G4oQ@mail.gmail.com>
Message-ID: <CAGXu5jKt8f7=DKrvcPg-NUJGbc-vanMNojfDsEiBt3vP05G4oQ@mail.gmail.com>
Subject: Re: [PATCH v2 2/5] arm64, mm: Move generic mmap layout functions to mm
To: Alexandre Ghiti <alex@ghiti.fr>
Cc: Christoph Hellwig <hch@infradead.org>, Albert Ou <aou@eecs.berkeley.edu>, 
	Kees Cook <keescook@chromium.org>, Catalin Marinas <catalin.marinas@arm.com>, 
	Palmer Dabbelt <palmer@sifive.com>, Will Deacon <will.deacon@arm.com>, 
	Russell King <linux@armlinux.org.uk>, Ralf Baechle <ralf@linux-mips.org>, 
	LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, 
	Paul Burton <paul.burton@mips.com>, Alexander Viro <viro@zeniv.linux.org.uk>, 
	James Hogan <jhogan@kernel.org>, 
	"linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, 
	linux-mips@vger.kernel.org, linux-riscv@lists.infradead.org, 
	linux-arm-kernel <linux-arm-kernel@lists.infradead.org>, Luis Chamberlain <mcgrof@kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 10, 2019 at 12:33 AM Alexandre Ghiti <alex@ghiti.fr> wrote:
>
> On 04/10/2019 08:59 AM, Christoph Hellwig wrote:
> > On Thu, Apr 04, 2019 at 01:51:25AM -0400, Alexandre Ghiti wrote:
> >> - fix the case where stack randomization should not be taken into
> >>    account.
> > Hmm.  This sounds a bit vague.  It might be better if something
> > considered a fix is split out to a separate patch with a good
> > description.
>
> Ok, I will move this fix in another patch.

Yeah, I think it'd be best to break this into a few (likely small) patches:
- update the compat case in the arm64 code
- fix the "not randomized" case
- move the code to mm/ (line-for-line identical for easy review)

That'll make it much easier to review (at least for me).

Thanks!

-- 
Kees Cook

