Return-Path: <SRS0=AiS9=SS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 06A3BC10F14
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 15:38:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AAE102087C
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 15:38:56 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=amazonses.com header.i=@amazonses.com header.b="c0EbnDaE"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AAE102087C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 45E2E6B02BC; Tue, 16 Apr 2019 11:38:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 40F416B02BE; Tue, 16 Apr 2019 11:38:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2FE106B02BF; Tue, 16 Apr 2019 11:38:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0DBE36B02BC
	for <linux-mm@kvack.org>; Tue, 16 Apr 2019 11:38:56 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id g17so19550860qte.17
        for <linux-mm@kvack.org>; Tue, 16 Apr 2019 08:38:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version
         :feedback-id;
        bh=CdDwOcgWJmYzDGc9u4Vhp0PJvr1SR0tEt6RVLCvHPFw=;
        b=sL/3KiG7exSJsOE9tE9VzCaSlPmWyQ+j6ZSxF7NZUg70iN49nkTlIhPtCU8FkZCpZi
         aEKjTZH3LD2cocpTTbgScg7Oo65DMlQLXNxc7m0Ld21UjgLkchL/XeoPt23hongit4e0
         sS8O7mNik8kj94dC1Lwid1O5FHXnQzKOll2tr2W0tKct8QogEqKFXAfZyL+3Eust0mNH
         P+GE9afQ2UqNO+tshKg+rBiiRPEgC7OuHeGRcoKbdBoJzOaMdShHQ1ENcLLXbyAaTyG6
         o6wWOcobdTvBS79WGmyHxw5F8o77/SNXdxUJ5iTXu25u1+TYWKg85m+4Ns87tbmWA7XU
         +q7g==
X-Gm-Message-State: APjAAAUPAMH7gc12d0Zcdy7XvadXyD9sfJWh1R1/ebIq9JKgkWkabeVR
	Fq29gy+pnKeAx5VnMJp0AUO9b39MnmCBCdiXu9QV8a9gVvNBfAY8Wy4/B13/EWbFcedIe8b/vXo
	BG/kqBiTJGd+MMP4Y4fheXRDS734+DU2jaUyt/XpM9mru30kbxdDpvkkUkjVcb8s=
X-Received: by 2002:a05:620a:15ef:: with SMTP id p15mr59372332qkm.317.1555429135769;
        Tue, 16 Apr 2019 08:38:55 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzmAhQNyaQQSqsiIW1xOZ9ToWROxlCsNQ5NmIjoXvaHNGSmI9Hsu2Li6f3ufiUDqBGolput
X-Received: by 2002:a05:620a:15ef:: with SMTP id p15mr59372277qkm.317.1555429135062;
        Tue, 16 Apr 2019 08:38:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555429135; cv=none;
        d=google.com; s=arc-20160816;
        b=n+UO/3O55GvNj8DEjIjTiq9Qds7gjFFszP74+vjTS/aEqu3KdgXwf95ZGVyUck49Ug
         YGBilDYd5g5CpTMCZmhddCepT3/WuCgPER7zQYazK9gm790AN6xOgFilhKtmlb5JKJmg
         QUDdUHykqknqICEFsgbs7xOAJioqXCGuhhMMeQzCVBdFiLZa5w0PJpLRSnrZDD16Xmgq
         S1fR6FbczcCf2dN0E5sI5229jgJPrSziV948VPyeCqh92g2WhUMvbSEBT3RkuyfOkubC
         FJQrLosVnnTGvTfOC1jRgzuAj8aPM4WDIvIeStAcDwGhtKOZJW2LmaEBwcICMk9OigrS
         0nwg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=feedback-id:mime-version:user-agent:references:message-id
         :in-reply-to:subject:cc:to:from:date:dkim-signature;
        bh=CdDwOcgWJmYzDGc9u4Vhp0PJvr1SR0tEt6RVLCvHPFw=;
        b=edsMSPsBmoeCS2My5ntAiZlgfhOxvII51q6NaD70XBAox71Ies9GpKbBsOZZ2QVzCu
         NjHaMHOWOHbOATb/zJ6l/A3yvp1X5ZFfGiBtv7kaLI1MiNViEWMq41CFpOz1WwWHRn/m
         GSLwYXzklde/CnSThWj+qoVWeWsfN70JCLRLaA3KG2GKVFZ/r2N+S/Icj9AzRl6AVTD8
         X93S+DttwW12VTdXdZnBenZteOyAVp4cGR9VpY9KPjPwpxP1zhFWosAH/M7JFlTWxmxz
         Y6wcY95JqRRyCT4whqiQTV650yMd0hPNhKEFMsq7bOcKRsZRE+CWQAUXIc/tHLjcSQft
         B1Hg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=6gbrjpgwjskckoa6a5zn6fwqkn67xbtw header.b=c0EbnDaE;
       spf=pass (google.com: domain of 0100016a26cd1058-d1ed3b2e-0cca-4e61-8837-79dfeca68682-000000@amazonses.com designates 54.240.9.99 as permitted sender) smtp.mailfrom=0100016a26cd1058-d1ed3b2e-0cca-4e61-8837-79dfeca68682-000000@amazonses.com
Received: from a9-99.smtp-out.amazonses.com (a9-99.smtp-out.amazonses.com. [54.240.9.99])
        by mx.google.com with ESMTPS id h14si8215798qvc.98.2019.04.16.08.38.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 16 Apr 2019 08:38:55 -0700 (PDT)
Received-SPF: pass (google.com: domain of 0100016a26cd1058-d1ed3b2e-0cca-4e61-8837-79dfeca68682-000000@amazonses.com designates 54.240.9.99 as permitted sender) client-ip=54.240.9.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=6gbrjpgwjskckoa6a5zn6fwqkn67xbtw header.b=c0EbnDaE;
       spf=pass (google.com: domain of 0100016a26cd1058-d1ed3b2e-0cca-4e61-8837-79dfeca68682-000000@amazonses.com designates 54.240.9.99 as permitted sender) smtp.mailfrom=0100016a26cd1058-d1ed3b2e-0cca-4e61-8837-79dfeca68682-000000@amazonses.com
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/simple;
	s=6gbrjpgwjskckoa6a5zn6fwqkn67xbtw; d=amazonses.com; t=1555429134;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:MIME-Version:Content-Type:Feedback-ID;
	bh=TkFGn3ILZJOMrhJJWyNYT4Envk++7Wre6S8alltMeeY=;
	b=c0EbnDaEW3zUT6p0YLvxaJaN9q71+L8TwSXqTYicpNStWsmfJLiHz9GBqoKrUXEH
	B9uClT3C17ecNZWrhw68u/JHJ8Pk+MmBB9rQGjLFhWX5DjFn7EAOtAwBSyLiW/o0Mpe
	KIuqWKNgNj/Tan5o58Me3mKYhFONWLbQasxaZzrE=
Date: Tue, 16 Apr 2019 15:38:54 +0000
From: Christopher Lameter <cl@linux.com>
X-X-Sender: cl@nuc-kabylake
To: Vlastimil Babka <vbabka@suse.cz>
cc: James Bottomley <James.Bottomley@HansenPartnership.com>, 
    lsf-pc@lists.linux-foundation.org, 
    Linux-FSDevel <linux-fsdevel@vger.kernel.org>, 
    linux-mm <linux-mm@kvack.org>, linux-block@vger.kernel.org, 
    Michal Hocko <mhocko@kernel.org>, David Rientjes <rientjes@google.com>, 
    Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, 
    Ming Lei <ming.lei@redhat.com>, linux-xfs@vger.kernel.org, 
    Christoph Hellwig <hch@infradead.org>, Dave Chinner <david@fromorbit.com>, 
    "Darrick J . Wong" <darrick.wong@oracle.com>
Subject: Re: [LSF/MM TOPIC] guarantee natural alignment for kmalloc()?
In-Reply-To: <68385367-8744-50c3-8a81-be3a4637ea80@suse.cz>
Message-ID: <0100016a26cd1058-d1ed3b2e-0cca-4e61-8837-79dfeca68682-000000@email.amazonses.com>
References: <790b68b7-3689-0ff6-08ae-936728bc6458@suse.cz> <1555053293.3046.4.camel@HansenPartnership.com> <68385367-8744-50c3-8a81-be3a4637ea80@suse.cz>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-SES-Outgoing: 2019.04.16-54.240.9.99
Feedback-ID: 1.us-east-1.fQZZZ0Xtj2+TD7V5apTT/NrT6QKuPgzCT/IC7XYgDKI=:AmazonSES
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 12 Apr 2019, Vlastimil Babka wrote:

> On 4/12/19 9:14 AM, James Bottomley wrote:
> >> In the session I hope to resolve the question whether this is indeed
> >> the right thing to do for all kmalloc() users, without an explicit
> >> alignment requests, and if it's worth the potentially worse
> >> performance/fragmentation it would impose on a hypothetical new slab
> >> implementation for which it wouldn't be optimal to split power-of-two
> >> sized pages into power-of-two-sized objects (or whether there are any
> >> other downsides).
> >
> > I think so.  The question is how aligned?  explicit flushing arch's
> > definitely need at least cache line alignment when using kmalloc for
> > I/O and if allocations cross cache lines they have serious coherency
> > problems.   The question of how much more aligned than this is
> > interesting ... I've got to say that the power of two allocator implies
> > same alignment as size and we seem to keep growing use cases that
> > assume this.

Well that can be controlled on a  per arch level through KMALLOC_MIN_ALIGN
already. There are architectues that align to cache line boundaries.
However you sometimes have hardware with ridiculous large cache line
length configurations like VSMP with 4k.

> Right, by "natural alignment" I meant exactly that - align to size for
> power-of-two sizes.

Well for which sizes? Double word till PAGE_SIZE? This gets us into weird
and difficult to comprehend rules for how objects are aligned. Or do we
start on the cache line size to provide cacheline alignment and do word
alignment before?

Consistency is important I think and if you want something different then
you need to say so in one way or another.


> > I'm not so keen on growing a separate API unless there's
> > a really useful mm efficiency in breaking the kmalloc alignment
> > assumptions.
>
> I'd argue there's not.


