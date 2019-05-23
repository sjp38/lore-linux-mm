Return-Path: <SRS0=On+J=TX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,T_DKIMWL_WL_MED,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ABB70C282DD
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 18:49:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6660720868
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 18:49:54 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="u0BN/6Ny"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6660720868
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 138B16B02A1; Thu, 23 May 2019 14:49:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0C3436B02A2; Thu, 23 May 2019 14:49:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id ECB6B6B02A3; Thu, 23 May 2019 14:49:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f198.google.com (mail-yb1-f198.google.com [209.85.219.198])
	by kanga.kvack.org (Postfix) with ESMTP id C6EB56B02A1
	for <linux-mm@kvack.org>; Thu, 23 May 2019 14:49:53 -0400 (EDT)
Received: by mail-yb1-f198.google.com with SMTP id x8so6038519ybp.14
        for <linux-mm@kvack.org>; Thu, 23 May 2019 11:49:53 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=q/4hzu5ZLVp3mgIPesJPmq/IWbfe4flwA2HG1sCD0TQ=;
        b=NX7WAtpMNeIP7PpwjZcCNfkyQSZtY7CK1HOEIPTvOZS2xD7eyJjanhIXyXjx0+z96y
         aABLrpouJHgYTmghI9Qq8iWLmkxAcol0Bh8jrcIDpAybubSOfZk2WGROik3eX4u0Kcos
         ehmM2DzEylRoDK4xz3CkATrjN3qXGk8Idh0zL3jMkDLBp1iRflP/4H9lQCz3e/HSu3Lm
         wIDYnNf8mIJoGSYwGO2SKATCp4vycKC3FRjp/LWRGPDUz1Pbq0pdH7gR1Ro+K0lCTqd2
         I4byXQFoPAVwAFilZuMdET/xNEaFUmwq99WITb9YspOr5WvZlXYvLGM7O0bRQU2Mb7ws
         h/JQ==
X-Gm-Message-State: APjAAAWet4Oy5Vf6QtlBKCP4HNNiv7kVAUzC4GQTnDf6vAaaTjJOHd0M
	l4wGdVaSnk95U4JkFtAy7baTzZ+5kCLQ41GwjNC+ozUtN6UcvvCd6rkb7LarZg3vsgJMxjugNcZ
	n0IMkz8DQHgircKqO40lk1rBRptrbgu8cnfOM0I3e76DmLeNvFcnTd6p/7OgCo93W3A==
X-Received: by 2002:a25:cc02:: with SMTP id l2mr20546402ybf.107.1558637393571;
        Thu, 23 May 2019 11:49:53 -0700 (PDT)
X-Received: by 2002:a25:cc02:: with SMTP id l2mr20546387ybf.107.1558637393016;
        Thu, 23 May 2019 11:49:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558637393; cv=none;
        d=google.com; s=arc-20160816;
        b=GUGhnXJJk3P6V8oEvMDxYrONPZldcp43fm8cEGpf60ehy/idj7JZOLtlXI5ODUPuUe
         2hr71ZIvPpP1ElfKW1kpfzlPsYMDlhjdV/+4yTxea6+7S605NLF7qoYjGmFjo5AOdrVN
         FqpVtVo0lsOXbrnno4XqMPxu7nprvFz1Ko8JryoMaE2l7JvUyoJFgSKUXyxr+Zlops0G
         NDnmXFKMZ20sB3m14fZ30WwoP9hGmYZMb9bI/Ktya72W32YsI6kKVbSQgOoP88RGdNVl
         n7nM60M238wqt4iSSHdsyBseMoXkO4/mLB2sBz+ka9qdxnbODYbc2VW9lBTsgv/MFUGI
         LqOg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=q/4hzu5ZLVp3mgIPesJPmq/IWbfe4flwA2HG1sCD0TQ=;
        b=ybWpty4er4afdLh/kBI/bZ4uP05VgrAbFoVFwDK2qoQ1GAucynrg2UrHp6SaxN6zXP
         JsND+yydJxM+dc0z1OiWKF8e9A0yUksuaWg1/fWRlm52daX3SaoAuXye0r0cNPOXcbCP
         e+0PxCwqVGvxVLsg7P2frk2NEdghyO2+H+ZLjAGieCYiW9rx0InvJy9fowSrh2o5Osyy
         6IJpOg7MA5dnVqZ/1dXavtJWftw3YybuOa8E4BkBq+6uXi8iDn4Mi9VUrRWhiJrZLude
         smWAMn995NDyskj9BekgKPjcR/j5JDZ5SQzjjvxi0J+ADLQZEmAXyIB0FALWTVxsaSlQ
         WaqQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="u0BN/6Ny";
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id q7sor113687ywg.94.2019.05.23.11.49.52
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 23 May 2019 11:49:53 -0700 (PDT)
Received-SPF: pass (google.com: domain of shakeelb@google.com designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="u0BN/6Ny";
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=q/4hzu5ZLVp3mgIPesJPmq/IWbfe4flwA2HG1sCD0TQ=;
        b=u0BN/6Ny8Z4+blOm22Z5UCSC8Wy5XnV4pzNa9RSEvcRmexqQPvcwNghBha2X4MQ36C
         7dzsdV+f6ydrqcsngoZ6b81Z6BiBjBfDHoUWeZaLAK49agcruYHxVKfgwvl6vkbI7a2g
         qWF7FK3K5DeBcV4zvxpXp0o81by/At5dYBRjnk7yfQBXl0RTZNucfLEpe2dPkSFCumKX
         lM23S8zrXdpTm2qs3mlX+TjAUJg+SGmA3p+ePvgDlWxlg/5n+eJfvBZ/ka/EFGLzfvai
         bSt2zk6ItfPP82e9IfgqRiHMA9BW3IYp9vtRWaIl180exc8Z8hQL9gAUR3c4PwBkBOO2
         q+Yw==
X-Google-Smtp-Source: APXvYqzw3j/oSC5Q9iYfqvGAp+HoFdUfIIMs+Btzd/EKLDObZYBH8mQUpoL/qVeAVC9OPWePoER5CA68wIGZsaWSqM0=
X-Received: by 2002:a81:5ec3:: with SMTP id s186mr47879009ywb.308.1558637392374;
 Thu, 23 May 2019 11:49:52 -0700 (PDT)
MIME-Version: 1.0
References: <20190523174349.GA10939@cmpxchg.org> <20190523183713.GA14517@bombadil.infradead.org>
In-Reply-To: <20190523183713.GA14517@bombadil.infradead.org>
From: Shakeel Butt <shakeelb@google.com>
Date: Thu, 23 May 2019 11:49:41 -0700
Message-ID: <CALvZod4o0sA8CM961ZCCp-Vv+i6awFY0U07oJfXFDiVfFiaZfg@mail.gmail.com>
Subject: Re: xarray breaks thrashing detection and cgroup isolation
To: Matthew Wilcox <willy@infradead.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, 
	Linux MM <linux-mm@kvack.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, 
	LKML <linux-kernel@vger.kernel.org>, Kernel Team <kernel-team@fb.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, May 23, 2019 at 11:37 AM Matthew Wilcox <willy@infradead.org> wrote:
>
> On Thu, May 23, 2019 at 01:43:49PM -0400, Johannes Weiner wrote:
> > I noticed that recent upstream kernels don't account the xarray nodes
> > of the page cache to the allocating cgroup, like we used to do for the
> > radix tree nodes.
> >
> > This results in broken isolation for cgrouped apps, allowing them to
> > escape their containment and harm other cgroups and the system with an
> > excessive build-up of nonresident information.
> >
> > It also breaks thrashing/refault detection because the page cache
> > lives in a different domain than the xarray nodes, and so the shadow
> > shrinker can reclaim nonresident information way too early when there
> > isn't much cache in the root cgroup.
> >
> > I'm not quite sure how to fix this, since the xarray code doesn't seem
> > to have per-tree gfp flags anymore like the radix tree did. We cannot
> > add SLAB_ACCOUNT to the radix_tree_node_cachep slab cache. And the
> > xarray api doesn't seem to really support gfp flags, either (xas_nomem
> > does, but the optimistic internal allocations have fixed gfp flags).
>
> Would it be a problem to always add __GFP_ACCOUNT to the fixed flags?
> I don't really understand cgroups.

Does xarray cache allocated nodes, something like radix tree's:

static DEFINE_PER_CPU(struct radix_tree_preload, radix_tree_preloads) = { 0, };

For the cached one, no __GFP_ACCOUNT flag.

Also some users of xarray may not want __GFP_ACCOUNT. That's the
reason we had __GFP_ACCOUNT for page cache instead of hard coding it
in radix tree.

Shakeel

