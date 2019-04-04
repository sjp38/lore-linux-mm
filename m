Return-Path: <SRS0=kGB6=SG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2CE06C4360F
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 15:57:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DEE922082E
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 15:57:25 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=amazonses.com header.i=@amazonses.com header.b="SUh6lLJr"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DEE922082E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 86AF36B000D; Thu,  4 Apr 2019 11:57:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 81AA16B000E; Thu,  4 Apr 2019 11:57:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6E2586B0010; Thu,  4 Apr 2019 11:57:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 404D16B000D
	for <linux-mm@kvack.org>; Thu,  4 Apr 2019 11:57:25 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id 23so2489640qkl.16
        for <linux-mm@kvack.org>; Thu, 04 Apr 2019 08:57:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version
         :feedback-id;
        bh=RuMz4Toeop1wxCt6X2zIK+G7Ftq7sJ4nnRup7oWLd6w=;
        b=W3dXfpKQwFKTDnjCUJ3f5/0t9SsqAvYEoShUXevvCl9zHC2OmRQlTYqox4S/3a7rRB
         8RwKKT85EhFEYXTXGGwkNydWL87fxONqccqe+okJ8Kt8lKk7deCS+qQ7ekYTuQVoM61H
         cl+npYdPYwa+K2KyxwqZQq3q6QPyPXMojf/4wIgekTlKo6jngTqm9OTdTXWrnTRxcLU0
         vKUIh0BNK8rw/+b04d5Fx1GiI1lT+iS8CUN3p4R1gSPy6ZK/ihaMJE8AuHe8XSOl/q45
         ouU/dNJnaNvRt33KCZH8zfr09SB+oAQ8TnZoXimIvcyBUGFgjOM/obWZ8cGoq9yC1hGx
         a+Xw==
X-Gm-Message-State: APjAAAXR72IPQQqo1qzaL6xd0KuXfUJ6Rc5HynVr5Fc3RO7jPDtNEm8k
	Ck6EI7ggVH12wRSCm8wRNFADO4x9iZQfcKqy5PN5n0e5zhBPZn35WD8xZTjnRj/+Lq8HAnZkzII
	kyZUr3/cMM65QsIKHIqI7oqo9cgYpFtt3Os6K9VF7d7fLckXjLdlMw3ZFnY7ghiw=
X-Received: by 2002:a0c:88e3:: with SMTP id 32mr5422979qvo.31.1554393444930;
        Thu, 04 Apr 2019 08:57:24 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxZSlAvMIV+uytqdkH9cR5Dwh2RlzKe5ymd0zY4Iud92dIoND3FkL3fAyTmiN3ujk/uvS67
X-Received: by 2002:a0c:88e3:: with SMTP id 32mr5422940qvo.31.1554393444389;
        Thu, 04 Apr 2019 08:57:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554393444; cv=none;
        d=google.com; s=arc-20160816;
        b=xoMOad0c7wp3QeSKdiObMa/FVmh+t5qwSTxgtGumZgs+RcmHuvgUijKLqOVf+YEzIC
         CjaLXisHuwTWeiU646ZSuFnGoslbkl40vuJS2nN4WDvPUOjCw4ZN3DRXQCSEsmkjm5bY
         EC9XXC9v8jwLfNXc7sSHhyMV2cO0bQ1BtCib/Wz3P/u0tYM0mUE9/ZSAuzQpMiD7M7gJ
         mKCyE85OyBiKCRDQio0UEEeshOq14X6oal2vBkyrBACiX31Dp8tMJgcFQKN2sQ7hAfkJ
         xkDAr3C17euA8cysbCY4miy19vjndLPdJsn+DO+2UcdB5ORF6zaI9LWeUggkmIUGu86/
         02+w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=feedback-id:mime-version:user-agent:references:message-id
         :in-reply-to:subject:cc:to:from:date:dkim-signature;
        bh=RuMz4Toeop1wxCt6X2zIK+G7Ftq7sJ4nnRup7oWLd6w=;
        b=V5AfOwVtt6hBPYOH+c1JEDxBMUTmeGFUwl4PedmhF/0TrZx4Tb8FqbWEWX3VBQCK3T
         4sTBUEcxywY/ZUf9a9wRj29KJ2UKGFVjBlk5FMpAok5nkx2MpSEbxjzrtB6pFIi48lB2
         ocZ1Lo7dqJBKL1N2dG7OI0I208bN9qhNwTuou2Ue+XDjnNKSVo6kDFSh+c53Uv4Lw2zm
         Il8OYk6WNeoxpgZSvXGe+P/oR4s1yJ2fYWkCQR1kGDyrSAieCk7yvjFSNu8QguW7WUJq
         wEgsYEZCI9WkaPv1TvLWNe4dGp95WTZS8Z8MFVoqVEeGqjwpm3pznJ2/alTHLvIiX/bo
         qD4w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=6gbrjpgwjskckoa6a5zn6fwqkn67xbtw header.b=SUh6lLJr;
       spf=pass (google.com: domain of 01000169e911ae41-0abde43e-18e8-442b-b289-e796c461f0b1-000000@amazonses.com designates 54.240.9.54 as permitted sender) smtp.mailfrom=01000169e911ae41-0abde43e-18e8-442b-b289-e796c461f0b1-000000@amazonses.com
Received: from a9-54.smtp-out.amazonses.com (a9-54.smtp-out.amazonses.com. [54.240.9.54])
        by mx.google.com with ESMTPS id o27si2049572qkk.237.2019.04.04.08.57.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 04 Apr 2019 08:57:24 -0700 (PDT)
Received-SPF: pass (google.com: domain of 01000169e911ae41-0abde43e-18e8-442b-b289-e796c461f0b1-000000@amazonses.com designates 54.240.9.54 as permitted sender) client-ip=54.240.9.54;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=6gbrjpgwjskckoa6a5zn6fwqkn67xbtw header.b=SUh6lLJr;
       spf=pass (google.com: domain of 01000169e911ae41-0abde43e-18e8-442b-b289-e796c461f0b1-000000@amazonses.com designates 54.240.9.54 as permitted sender) smtp.mailfrom=01000169e911ae41-0abde43e-18e8-442b-b289-e796c461f0b1-000000@amazonses.com
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/simple;
	s=6gbrjpgwjskckoa6a5zn6fwqkn67xbtw; d=amazonses.com; t=1554393444;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:MIME-Version:Content-Type:Feedback-ID;
	bh=RuMz4Toeop1wxCt6X2zIK+G7Ftq7sJ4nnRup7oWLd6w=;
	b=SUh6lLJrm4vec3E2SFmgWkGVRSs+fQeW9viK/c0l5DTGNw1mokz/ZXG+cWUx+GcS
	VdamHeX5Ew672CyFv5BEEO1VcQ/dKjT3lLcGTd4srAa+lw8gXVVMT4UuSZyF3sdOz+5
	fjuOhF88OcO3A9Tz0MOJWTyiC6l/+IqwI7TKccj4=
Date: Thu, 4 Apr 2019 15:57:24 +0000
From: Christopher Lameter <cl@linux.com>
X-X-Sender: cl@nuc-kabylake
To: Vlastimil Babka <vbabka@suse.cz>
cc: linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, 
    David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, 
    Andrew Morton <akpm@linux-foundation.org>, 
    Mel Gorman <mgorman@techsingularity.net>, linux-kernel@vger.kernel.org
Subject: Re: [RFC 0/2] add static key for slub_debug
In-Reply-To: <20190404091531.9815-1-vbabka@suse.cz>
Message-ID: <01000169e911ae41-0abde43e-18e8-442b-b289-e796c461f0b1-000000@email.amazonses.com>
References: <20190404091531.9815-1-vbabka@suse.cz>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-SES-Outgoing: 2019.04.04-54.240.9.54
Feedback-ID: 1.us-east-1.fQZZZ0Xtj2+TD7V5apTT/NrT6QKuPgzCT/IC7XYgDKI=:AmazonSES
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 4 Apr 2019, Vlastimil Babka wrote:

> I looked a bit at SLUB debugging capabilities and first thing I noticed is
> there's no static key guarding the runtime enablement as is common for similar
> debugging functionalities, so here's a RFC to add it. Can be further improved
> if there's interest.

Well the runtime enablement is per slab cache and static keys are global.

Adding static key adds code to the critical paths. Since the flags for a
kmem_cache have to be inspected anyways there may not be that much of a
benefit.

> It's true that in the alloc fast path the debugging check overhead is AFAICS
> amortized by the per-cpu cache, i.e. when the allocation is from there, no
> debugging functionality is performed. IMHO that's kinda a weakness, especially
> for SLAB_STORE_USER, so I might also look at doing something about it, and then
> the static key might be more critical for overhead reduction.

Moving debugging out of the per cpu fastpath allows that fastpath to be
much simpler and faster.

SLAB_STORE_USER is mostly used only for debugging in which case we are
less concerned with performance.

If you want to use SLAB_STORE_USER in the fastpath then we have to do some
major redesign there.

> In the freeing fast path I quickly checked the stats and it seems that in
> do_slab_free(), the "if (likely(page == c->page))" is not as likely as it
> declares, as in the majority of cases, freeing doesn't happen on the object
> that belongs to the page currently cached. So the advantage of a static key in
> slow path __slab_free() should be more useful immediately.

Right. The freeing logic is actuall a weakness in terms of performance for
SLUB due to the need to operate on a per page queue immediately.

