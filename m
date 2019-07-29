Return-Path: <SRS0=FoEm=V2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D3A4EC7618B
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 09:35:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 85612206B8
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 09:35:10 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 85612206B8
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-m68k.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E3CA68E0003; Mon, 29 Jul 2019 05:35:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DC60C8E0002; Mon, 29 Jul 2019 05:35:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C8D978E0003; Mon, 29 Jul 2019 05:35:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f70.google.com (mail-wm1-f70.google.com [209.85.128.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7A90B8E0002
	for <linux-mm@kvack.org>; Mon, 29 Jul 2019 05:35:09 -0400 (EDT)
Received: by mail-wm1-f70.google.com with SMTP id f189so13532436wme.5
        for <linux-mm@kvack.org>; Mon, 29 Jul 2019 02:35:09 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:mime-version
         :references:in-reply-to:from:date:message-id:subject:to:cc;
        bh=MKfg/YzZ/kKbAR+g0cMsbALxccH9iNlGfj4yCp09JRM=;
        b=L5ghEefwj1WXbJbDtwxzt6/FXmSblHsCwgto1rys7WGVmAuqfZZvA7mRDXqxaGJwxW
         uFdOm6RBv8ulK5aMg1CD1XpgRDTeRyK/bGnHyPhbLZHWSqJQdtEuuJPxptKEpZkwDTG2
         zzMjQ2/X5FgSG5fBHCAgEvikv0In4yluJSZ7LX/19zFd0nrsl1qtM3UoUpy3ZV3r4nJN
         s1S+pOpo4K4Uon7DbawVrym51QhayvU02mKx9WzKgeI7kpxmE5vX2wY0yJtNH2fcwUfi
         THsAWza8Rjm1XNx62RmIFUSWSJEuB69S47+DDbMcCNh+KdDb+xLV/uEeG8lt3/xRQ/cz
         MlEw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of geert.uytterhoeven@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=geert.uytterhoeven@gmail.com
X-Gm-Message-State: APjAAAWY1ZX5ilF1q889SymCULFAx0s3wJ/yX8lXqGyI/6YgkqiP4/c+
	jGGWv4ZGURenEqXOFlfPTFlIg7IrDLruJSR9wXzT5UHOMAJI0a2zJWy265UbZuf6QMQe1iAg7AQ
	iCuO/8QX+DRaLTM/8LOBFEQ3g+2IESL+boEfUe4WZFeb3AD82IG0DcKTj14JN4vs=
X-Received: by 2002:a05:6000:112:: with SMTP id o18mr39143555wrx.153.1564392909070;
        Mon, 29 Jul 2019 02:35:09 -0700 (PDT)
X-Received: by 2002:a05:6000:112:: with SMTP id o18mr39143455wrx.153.1564392908314;
        Mon, 29 Jul 2019 02:35:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564392908; cv=none;
        d=google.com; s=arc-20160816;
        b=bheBH0SDIg5+V9BsWRldYF2fkV8TtD+EAOh6cpBVZEb+RCHhgwCT7Xn2AiZCbxv1mt
         wuJwIXhV68hKJwpdS6z1oZ3/2NqImLyIMtSXlP2Jpr0Ge4KNXzYtSomWW9qYYiZTthj/
         HxmIgRSUu4gpdHa/CP8dXc2WqDhMYJg7pcaJvkTCEH0CyjcghUilO+HeNtxx+45h+sZT
         oKZPD/O2+BjgwMJpDd/GWsCCqTAvkQgN63vt8GkmkvPkTurWYpXVr7fDsdM1NEu0oiWb
         DjcMoyNDqfhGfScPfyhcKDdofBW1JuTSCny8Kq3R4PbzLyOMy8bozhvC/emBRuW+bb60
         pEsA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version;
        bh=MKfg/YzZ/kKbAR+g0cMsbALxccH9iNlGfj4yCp09JRM=;
        b=Dx6lAAkdwQNoHSpTjJ3ufjlTAztAcgBZo5IzGQaV3kS1/o2MBJ7dcpDnr4DFoiZ6Xk
         vuxrlqqKg9Qax1Cx/zWdzpnO+q5AqfdjnoBsaY3/xes0Gf2X7NS9A+SRokspHOXK2HH2
         sDT5TrCjCeBgYDOdu5G0ZdlrJimwQct+6qroPHn8cvsm+k8/sb2JVBwqCkpTc3kJN/u/
         gDoat4HfXu8HLg4S0WZDtFbiDRNX/dMSvd+iPFCCprBgzfRTfhzQbe/1W2t3H0+n1dfT
         pea/BZL725UF//hxF/amqDALMylNUIgDs66tH+jrlI31PeWBs//53d4x1n5RWkqiIYSf
         tm9g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of geert.uytterhoeven@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=geert.uytterhoeven@gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u12sor33791809wmj.16.2019.07.29.02.35.08
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 29 Jul 2019 02:35:08 -0700 (PDT)
Received-SPF: pass (google.com: domain of geert.uytterhoeven@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of geert.uytterhoeven@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=geert.uytterhoeven@gmail.com
X-Google-Smtp-Source: APXvYqz/OhYicCcLtqkQnzQNoMEjcNe01xTQFKFL+dXyjIV5Vkz8OVN7FY7Cnac437nPx2UKb/3LUE/T0yzmDxN6SUY=
X-Received: by 2002:a1c:a7c6:: with SMTP id q189mr100128923wme.146.1564392907896;
 Mon, 29 Jul 2019 02:35:07 -0700 (PDT)
MIME-Version: 1.0
References: <20190722141133.3116-1-mark.rutland@arm.com>
In-Reply-To: <20190722141133.3116-1-mark.rutland@arm.com>
From: Geert Uytterhoeven <geert@linux-m68k.org>
Date: Mon, 29 Jul 2019 11:34:56 +0200
Message-ID: <CAMuHMdWdSeRRSQJFDXh=_rzWuPkqt0aa=grvdyHdBYtYYkP-ow@mail.gmail.com>
Subject: Re: [PATCHv2] mm: treewide: Clarify pgtable_page_{ctor,dtor}() naming
To: Mark Rutland <mark.rutland@arm.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, 
	Anshuman Khandual <anshuman.khandual@arm.com>, Matthew Wilcox <willy@infradead.org>, 
	Michal Hocko <mhocko@suse.com>, Yu Zhao <yuzhao@google.com>, Linux MM <linux-mm@kvack.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jul 22, 2019 at 7:27 PM Mark Rutland <mark.rutland@arm.com> wrote:
> The naming of pgtable_page_{ctor,dtor}() seems to have confused a few
> people, and until recently arm64 used these erroneously/pointlessly for
> other levels of page table.
>
> To make it incredibly clear that these only apply to the PTE level, and
> to align with the naming of pgtable_pmd_page_{ctor,dtor}(), let's rename
> them to pgtable_pte_page_{ctor,dtor}().
>
> These changes were generated with the following shell script:
>
> ----

Using "---" here might lead to the loss of everything below, including
your SoB.

> git grep -lw 'pgtable_page_.tor' | while read FILE; do
>     sed -i '{s/pgtable_page_ctor/pgtable_pte_page_ctor/}' $FILE;
>     sed -i '{s/pgtable_page_dtor/pgtable_pte_page_dtor/}' $FILE;
> done
> ----
>
> ... with the documentation re-flowed to remain under 80 columns, and
> whitespace fixed up in macros to keep backslashes aligned.
>
> There should be no functional change as a result of this patch.
>
> Signed-off-by: Mark Rutland <mark.rutland@arm.com>

[...]

>  arch/m68k/include/asm/mcf_pgalloc.h        |  6 +++---
>  arch/m68k/include/asm/motorola_pgalloc.h   |  6 +++---
>  arch/m68k/include/asm/sun3_pgalloc.h       |  2 +-

For the m68k changes:
Acked-by: Geert Uytterhoeven <geert@linux-m68k.org>

Gr{oetje,eeting}s,

                        Geert

-- 
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds

