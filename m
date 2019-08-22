Return-Path: <SRS0=SaVu=WS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B912BC3A5A1
	for <linux-mm@archiver.kernel.org>; Thu, 22 Aug 2019 18:24:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 72DD42133F
	for <linux-mm@archiver.kernel.org>; Thu, 22 Aug 2019 18:24:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="JjSJQtGt"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 72DD42133F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EB9546B034F; Thu, 22 Aug 2019 14:24:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E6A1D6B0351; Thu, 22 Aug 2019 14:24:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D59CE6B0352; Thu, 22 Aug 2019 14:24:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0220.hostedemail.com [216.40.44.220])
	by kanga.kvack.org (Postfix) with ESMTP id AF4806B034F
	for <linux-mm@kvack.org>; Thu, 22 Aug 2019 14:24:29 -0400 (EDT)
Received: from smtpin17.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 4D787180AD7C1
	for <linux-mm@kvack.org>; Thu, 22 Aug 2019 18:24:29 +0000 (UTC)
X-FDA: 75850889058.17.mouth13_27233f606a745
X-HE-Tag: mouth13_27233f606a745
X-Filterd-Recvd-Size: 4396
Received: from mail-ua1-f53.google.com (mail-ua1-f53.google.com [209.85.222.53])
	by imf13.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 22 Aug 2019 18:24:28 +0000 (UTC)
Received: by mail-ua1-f53.google.com with SMTP id g13so2336921uap.5
        for <linux-mm@kvack.org>; Thu, 22 Aug 2019 11:24:28 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=RyMbtTLUWCmoliNTAnndKPMWCp0b4Jb6ryQcQLXyRPk=;
        b=JjSJQtGtEHCCNTj150vGW5+IpYhImY2UzbDtjgs4fQWzbQTHkTDfsTTl6FpavisshJ
         fwcs+njq9+RsyDcoV112B1tJf42BSk8bVmtw3FXoBECYvX++AeTBda1RcvqlSWxy182h
         3x3WyPptDBifo8JNFSVk1D4m9kVAAvElZMUwLx9uyQZZNOoJJvC28/6cg/D3DduaWb6N
         zqGOKC3DbGAvkqbqdbt148Iv31HDBWJe9KIBsqitJe0xtfqQQHn4pZuCU7jmK7liN2I4
         LG/EAV7E0aAVPr2xtqGsPgf1klpmq431jYayAK+17anGdxIN/hKTl76IuPK6Fy0wRjvh
         8vzw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=RyMbtTLUWCmoliNTAnndKPMWCp0b4Jb6ryQcQLXyRPk=;
        b=dXx3kq0FbkoxkQxDg5F4B/BpOZdq+mjVWLnaDF579yXfalODDUM641tyq7lFMc35jk
         +QGi+MOy5akiaEO8EK2dpKCabzsNARssX/DFkJE7xjVYL0k6m0fCxFSvC0oBfPLXThBi
         yAb2GPHVWikuibk4FP1e1B5bZWdz1BliuEqHTLV/6KnGEG/GdGMGkiaFnMvHaRvlXHj4
         qP82uZGS53PHWUHxRa4g45ERaod0xlK0N2MTu8UUedwrc722l8/f9GXdygI8l6SUg45o
         dOm5CdRawT1XC/u65myQSLhfdC833cqxRP1LeivQ4y8V1bjsKET9IfSX5ZSnBwbA3xGP
         lPbQ==
X-Gm-Message-State: APjAAAXhXu/EuzQQoqQ80DglyxG0FULFEMvtE56aJEBxSzMlPlGWM7Xa
	vVOzrnK9Mfur2nTj/+haU0QAXdxml6AoEEo0JDA=
X-Google-Smtp-Source: APXvYqx1J/Ncnfo9JgGyq3fQGw8OEaIMxKLGGLgK2xQXI3wljRgHLN8cm74bJyiNWXXKWFJiioDxBRgNgg6xLX2AjqA=
X-Received: by 2002:ab0:70ac:: with SMTP id q12mr624615ual.134.1566498268191;
 Thu, 22 Aug 2019 11:24:28 -0700 (PDT)
MIME-Version: 1.0
References: <CACDBo57u+sgordDvFpTzJ=U4mT8uVz7ZovJ3qSZQCrhdYQTw0A@mail.gmail.com>
 <20190822125231.GJ12785@dhcp22.suse.cz>
In-Reply-To: <20190822125231.GJ12785@dhcp22.suse.cz>
From: Pankaj Suryawanshi <pankajssuryawanshi@gmail.com>
Date: Thu, 22 Aug 2019 23:54:19 +0530
Message-ID: <CACDBo57OkND1LCokPLfyR09+oRTbA6+GAPc90xAEF6AM_LmbyQ@mail.gmail.com>
Subject: Re: PageBlocks and Migrate Types
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, 
	Vlastimil Babka <vbabka@suse.cz>, pankaj.suryawanshi@einfochips.com
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.005180, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Aug 22, 2019 at 6:22 PM Michal Hocko <mhocko@kernel.org> wrote:
>
> On Wed 21-08-19 22:23:44, Pankaj Suryawanshi wrote:
> > Hello,
> >
> > 1. What are Pageblocks and migrate types(MIGRATE_CMA) in Linux memory ?
>
> Pageblocks are a simple grouping of physically contiguous pages with
> common set of flags. I haven't checked closely recently so I might
> misremember but my recollection is that only the migrate type is stored
> there. Normally we would store that information into page flags but
> there is not enough room there.
>
> MIGRATE_CMA represent pages allocated for the CMA allocator. There are
> other migrate types denoting unmovable/movable allocations or pages that
> are isolated from the page allocator.
>
> Very broadly speaking, the migrate type groups pages with similar
> movability properties to reduce fragmentation that compaction cannot
> do anything about because there are objects of different properti
> around. Please note that pageblock might contain objects of a different
> migrate type in some cases (e.g. low on memory).
>
> Have a look at gfpflags_to_migratetype and how the gfp mask is converted
> to a migratetype for the allocation. Also follow different MIGRATE_$TYPE
> to see how it is used in the code.
>
> > How many movable/unmovable pages are defined by default?
>
> There is nothing like that. It depends on how many objects of a specific
> type are allocated.


It means that it started creating pageblocks after allocation of
different objects, but from which block it allocate initially when
there is nothing like pageblocks ? (when memory subsystem up)

Pageblocks and its type dynamically changes ?
>
>
> HTH
> --
> Michal Hocko
> SUSE Labs

