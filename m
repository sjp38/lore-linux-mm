Return-Path: <SRS0=iaDK=VA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6739AC06511
	for <linux-mm@archiver.kernel.org>; Wed,  3 Jul 2019 20:14:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0AFEF21850
	for <linux-mm@archiver.kernel.org>; Wed,  3 Jul 2019 20:14:47 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="hsd+hhLl"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0AFEF21850
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 616B28E001D; Wed,  3 Jul 2019 16:14:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5C7B68E0019; Wed,  3 Jul 2019 16:14:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4B5E88E001D; Wed,  3 Jul 2019 16:14:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2BE528E0019
	for <linux-mm@kvack.org>; Wed,  3 Jul 2019 16:14:47 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id k8so4411003qtb.12
        for <linux-mm@kvack.org>; Wed, 03 Jul 2019 13:14:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=yYUsHMTWauYHWqlo9ty/zJzUyUz6zmCJ5iqAlMLp6F0=;
        b=Nd1gvZu0lhPbTI+SS/NpT4cjvlQoR3juuRZNbji3Kbc0HQnCNX1LaV4QXYqivURq5H
         Cs0YBvxTaDcdB/gVeZh3zfEFnZlaNw+mcbbQ0QgwSlhxkywLysHfxQTTDXOiSWTYJZ0m
         ETD7dGbEnA09H6HRGW7B4F+SWEcLu/JI+8NlC+LUlA4+Lt/FF/otCvX2a8m+1EEAUd2S
         qOwAUN/v0xDcCGU+RmcHy2wiKtdTzVYv4IvpKjSVdOzbUxw04dbGyue4VM5ijXN0hFEM
         MUPjAskREHkDOMoi0HBpg7YjkHCVMQ3Jn2XH0ucodxJ2sUNHB1Eao9wqmhEz9aloZG2u
         3uaQ==
X-Gm-Message-State: APjAAAWMTLyFpWzy6PIz7Ecc9N6X1DvKw5CDBKcRk+9Z/qcRWtuqL8QQ
	e7Mz9Q0sm9wplmSsgDMNvcAbtS0RTxpEqMZejnX4t/CVpfOPuhfJ9RI8leuqIO+xKpcHlkUx5J7
	WCTQQVjLZQs62gAKvWvabh9gBrOtFekJ6r3nv030BdaeDtgXOG+pp1Dolhu3glw/m7g==
X-Received: by 2002:a81:1a4e:: with SMTP id a75mr23775417ywa.310.1562184886926;
        Wed, 03 Jul 2019 13:14:46 -0700 (PDT)
X-Received: by 2002:a81:1a4e:: with SMTP id a75mr23775360ywa.310.1562184886196;
        Wed, 03 Jul 2019 13:14:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562184886; cv=none;
        d=google.com; s=arc-20160816;
        b=pPwZsQSvl0RXosTpwJbjCwW+ZySBtwlct4VlKlD2Wj+gVvqwSIsTmNp2fuSyUzWOHw
         GxpiqAaQ89Yo1/JuA3FHkY708Q8wt64dnAMAp+Q1ocppYCit0L0je3knLGcyB8RdNBou
         0HNo1Fctl0RZYGU93Cg4giQJdhywymB0/jWr0E8hvgsjRXXRCsWEwVkCnG7hMUn1jTHY
         5QVcGpPBXL7fulJh72Md6S1jqNgMMo3vHi6ZRYhdr6nsA1M+jrLhWCwhMUB4/n7cP1W6
         6xECkQyd/j8GUca67ixINhW6p2IAY7Rm7oh4Bs9WojtNJ0Z+mTNmJbedaBGPIRMZxMAS
         /2FQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=yYUsHMTWauYHWqlo9ty/zJzUyUz6zmCJ5iqAlMLp6F0=;
        b=ekDzSW5Ormecc2bcgrNV6QnH3AFR645vLcsrNcXWCMIPqJUZn2k84zetiHkxh2lW1B
         hL/ifM4EvGusz853EXEuoFi0xHsGM273KGGCkUy4mEvWFTCK36ulH90UVKqr1k+yyYDV
         1u7DhKkPLzsCsolu8rZ2J40A4ZKmGyt4kjZwVpRZ+c4d7p7cNBxao7O8PjX0oeFMBotx
         WYTpTGZlg1QhX556UIfgolNpOG7cH0NDPiPzDje2ADNw5Tw46iIW/TZsMr4xdvfn2YgK
         nVahKwOF8C5vBbsacCOLS2DQzPQPZdWQSEzV/c6LKfq7Nk4Hbybyh90ouu4E0r1izZEV
         pOhw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=hsd+hhLl;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x10sor1844054ywa.212.2019.07.03.13.14.46
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 03 Jul 2019 13:14:46 -0700 (PDT)
Received-SPF: pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=hsd+hhLl;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=yYUsHMTWauYHWqlo9ty/zJzUyUz6zmCJ5iqAlMLp6F0=;
        b=hsd+hhLlxEGDdvpWo6KHr+7ipbRO0Tpjqi/yfrTH9FDKheJ6fGdXTYEiCj28seOz2l
         g/TjkEb8Td3Ga7v6D+piUUejHsLAcijpARYZtwoW1RJSMUvPf87zMGya0KxPrJfVVMWv
         bXN+jQ3JwVWQpc3OowW7OKFslKmEJjOjFAwKepBGD6x1bI92iSiEiEc1IqRS7HLfsJqv
         3CzASWm+KFGMCY4sGVmn2d4Mnx8RYBGNFlTkPLYn2M151gj70N1GzxuERCluhe1sltCG
         abC0A5AraypsRtqrGUvR75f67LBlDm4d9i1Fj6ak8cbxNRGsLcYvu/UsFwm7fSvt8JBx
         TGpQ==
X-Google-Smtp-Source: APXvYqxvm9RgE3mf6qJxv+IRH8IDppVFvJ1B6dViHCGIkkaRWjJXhzPOE5ckkXEYd2b2JX5VDQHFb3tCF7/zEqxZw4U=
X-Received: by 2002:a81:4c44:: with SMTP id z65mr23892003ywa.4.1562184885658;
 Wed, 03 Jul 2019 13:14:45 -0700 (PDT)
MIME-Version: 1.0
References: <20190701173042.221453-1-henryburns@google.com>
 <CAMJBoFPbRcdZ+NnX17OQ-sOcCwe+ZAsxcDJoR0KDkgBY9WXvpg@mail.gmail.com>
 <CAGQXPTjX=7aD9MQAs2kJthFvPdd3x8Nh53oc=wZCXH_dvDJ=Vg@mail.gmail.com> <CAMJBoFMBLv9OpXtQkOAyZ-vw5Ktk1tYtvfT=GPPx8jnKBN01rg@mail.gmail.com>
In-Reply-To: <CAMJBoFMBLv9OpXtQkOAyZ-vw5Ktk1tYtvfT=GPPx8jnKBN01rg@mail.gmail.com>
From: Shakeel Butt <shakeelb@google.com>
Date: Wed, 3 Jul 2019 13:14:34 -0700
Message-ID: <CALvZod57CZ20SG0eYu95=PDqJ+adoiUErdgAmhc_+qxDo68GoA@mail.gmail.com>
Subject: Re: [PATCH] mm/z3fold: Fix z3fold_buddy_slots use after free
To: Vitaly Wool <vitalywool@gmail.com>
Cc: Henry Burns <henryburns@google.com>, Andrew Morton <akpm@linux-foundation.org>, 
	Vitaly Vul <vitaly.vul@sony.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, 
	Xidong Wang <wangxidong_97@163.com>, Jonathan Adams <jwadams@google.com>, 
	Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000007, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jul 2, 2019 at 11:03 PM Vitaly Wool <vitalywool@gmail.com> wrote:
>
> On Tue, Jul 2, 2019 at 6:57 PM Henry Burns <henryburns@google.com> wrote:
> >
> > On Tue, Jul 2, 2019 at 12:45 AM Vitaly Wool <vitalywool@gmail.com> wrote:
> > >
> > > Hi Henry,
> > >
> > > On Mon, Jul 1, 2019 at 8:31 PM Henry Burns <henryburns@google.com> wrote:
> > > >
> > > > Running z3fold stress testing with address sanitization
> > > > showed zhdr->slots was being used after it was freed.
> > > >
> > > > z3fold_free(z3fold_pool, handle)
> > > >   free_handle(handle)
> > > >     kmem_cache_free(pool->c_handle, zhdr->slots)
> > > >   release_z3fold_page_locked_list(kref)
> > > >     __release_z3fold_page(zhdr, true)
> > > >       zhdr_to_pool(zhdr)
> > > >         slots_to_pool(zhdr->slots)  *BOOM*
> > >
> > > Thanks for looking into this. I'm not entirely sure I'm all for
> > > splitting free_handle() but let me think about it.
> > >
> > > > Instead we split free_handle into two functions, release_handle()
> > > > and free_slots(). We use release_handle() in place of free_handle(),
> > > > and use free_slots() to call kmem_cache_free() after
> > > > __release_z3fold_page() is done.
> > >
> > > A little less intrusive solution would be to move backlink to pool
> > > from slots back to z3fold_header. Looks like it was a bad idea from
> > > the start.
> > >
> > > Best regards,
> > >    Vitaly
> >
> > We still want z3fold pages to be movable though. Wouldn't moving
> > the backink to the pool from slots to z3fold_header prevent us from
> > enabling migration?
>
> That is a valid point but we can just add back pool pointer to
> z3fold_header. The thing here is, there's another patch in the
> pipeline that allows for a better (inter-page) compaction and it will
> somewhat complicate things, because sometimes slots will have to be
> released after z3fold page is released (because they will hold a
> handle to another z3fold page). I would prefer that we just added back
> pool to z3fold_header and changed zhdr_to_pool to just return
> zhdr->pool, then had the compaction patch valid again, and then we
> could come back to size optimization.
>

By adding pool pointer back to z3fold_header, will we still be able to
move/migrate/compact the z3fold pages?

