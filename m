Return-Path: <SRS0=RIH8=R4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EFC3EC10F03
	for <linux-mm@archiver.kernel.org>; Mon, 25 Mar 2019 14:15:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B3EEA2087E
	for <linux-mm@archiver.kernel.org>; Mon, 25 Mar 2019 14:15:28 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=amazonses.com header.i=@amazonses.com header.b="HrFR8unf"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B3EEA2087E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4AD166B0005; Mon, 25 Mar 2019 10:15:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 45CD16B0006; Mon, 25 Mar 2019 10:15:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 324816B0007; Mon, 25 Mar 2019 10:15:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0C3B66B0005
	for <linux-mm@kvack.org>; Mon, 25 Mar 2019 10:15:28 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id c67so8741184qkg.5
        for <linux-mm@kvack.org>; Mon, 25 Mar 2019 07:15:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version
         :feedback-id;
        bh=CA8e9iJdjQQo48tujbYuWXXpvAZFfr86lTRrICmhX5U=;
        b=llEforCItSUNea9SxgtL+BhRUjm0tw60nvHQpGUiNhGvSmyfyol+yZid/yOV1cybMJ
         mxGJFwGXf5WRRa9+Jdlr140fJuFqvaBz1NzOo5A/ck3ynOQhN4ZIKwMhgHRy1a74zCw4
         1Qr3NxRpmyRZz1mECZpRq3ejDuRyA1PTGhDQ4bTi5UKRaZktSpUNvp1XURROnRsoVMYM
         HHrVSiLbtscQXf1xm0tEAqWng25ZO6BQ1s3BDJCuMVbHHrhjfMdY/AbUx13eT5T0EcNi
         pcQquOiRdXywgztpvB6KBcQFjQb6JHGqiitTMPpBOajPJ7lE5O7/8WzZ+hrnZUmNXdNt
         gOFw==
X-Gm-Message-State: APjAAAWvLiGLrzIFBAS/W24LvuhbXYWWykkNJ7W87Z1IpQKiW9rrNpJE
	K15hnYAiYk4jzTBVRSDZdvu1Hlv+DD47ZC43bFeBxDIGS5P+nVJimaruAqY6ZNTfN5hd+f3CmYd
	JTd18JkeOZ7Y4Mszegz86uzZXk58KKIbiEPb83TpliVB8pCesFv9L6lx6SbgO2eo=
X-Received: by 2002:a0c:ad15:: with SMTP id u21mr20594698qvc.37.1553523327780;
        Mon, 25 Mar 2019 07:15:27 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxi5hUkPb+QDi8vmPTKJ3dXH25ulumWrR7ljcHQOxr9oy+ldqJ39Mfs+k+bHyh3DteuYi6m
X-Received: by 2002:a0c:ad15:: with SMTP id u21mr20594559qvc.37.1553523326180;
        Mon, 25 Mar 2019 07:15:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553523326; cv=none;
        d=google.com; s=arc-20160816;
        b=qU+g16iUM7vNfYqj9LZAY1wZa9+7g3X5qBLX/Ykz+AWFGmaJp98s1D6krrXzPPdC+s
         VgPX3i29s3XoyC2ztPYGpOxlY4VHYXexDlsjKR7vVKHI2y++dvErMbDWAC8R/JiRydL2
         ctYAGHAVWHEOZXM9uBR33XgyldZK6ksVyyTDXx19GLcqZmP6bvPd7dev3pfmJTaR0Dlr
         Z2RnmFc8otX7sEbiXW0A9OjyOf0sq+m+fgmLTp8Fs777VTcjAHhXynTwCPX1SZ7ZUOPv
         W/keMN7ZANlFwknuDdbM/39MrUTHZb4FtG/Tfh7s0WSMIKPdTgSgFkMeaGKoZFntyTHW
         1L1w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=feedback-id:mime-version:user-agent:references:message-id
         :in-reply-to:subject:cc:to:from:date:dkim-signature;
        bh=CA8e9iJdjQQo48tujbYuWXXpvAZFfr86lTRrICmhX5U=;
        b=KxVeH+kzosSNwXilgkpMfKKQGnUY29yudb2U7MVr1NG6MITU0ubDxWsXNlU06RYi02
         0dDiZGiLt3jOPP8wyIKCxev8crdWj0upo7h74knxQdkVdOxIE13zlMh6hmBcmyX6hHsx
         lQnTUYvDdLPhmdx+J7nBgv+txM8+o2vrejJTZgaXeIQNQX3vtlB9CtG7E1PAN/kbLAMf
         sUokNdDhJeUFa2060z2wUP4Zsx/XbwoJC3Idqc+4pOwk1/kjAnKzYzsL+BPprj/lVEmV
         CHvdadPoqnYq07/H21teJq5caB/HsWO4qzwfbI3O0KfJPGp5eAL6Il+YKMzmU1XyzO4M
         eyfQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=6gbrjpgwjskckoa6a5zn6fwqkn67xbtw header.b=HrFR8unf;
       spf=pass (google.com: domain of 01000169b534b9e8-31a2af2c-c396-47f9-8534-4cbd934ef09d-000000@amazonses.com designates 54.240.9.46 as permitted sender) smtp.mailfrom=01000169b534b9e8-31a2af2c-c396-47f9-8534-4cbd934ef09d-000000@amazonses.com
Received: from a9-46.smtp-out.amazonses.com (a9-46.smtp-out.amazonses.com. [54.240.9.46])
        by mx.google.com with ESMTPS id y4si1892751qta.151.2019.03.25.07.15.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 25 Mar 2019 07:15:26 -0700 (PDT)
Received-SPF: pass (google.com: domain of 01000169b534b9e8-31a2af2c-c396-47f9-8534-4cbd934ef09d-000000@amazonses.com designates 54.240.9.46 as permitted sender) client-ip=54.240.9.46;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=6gbrjpgwjskckoa6a5zn6fwqkn67xbtw header.b=HrFR8unf;
       spf=pass (google.com: domain of 01000169b534b9e8-31a2af2c-c396-47f9-8534-4cbd934ef09d-000000@amazonses.com designates 54.240.9.46 as permitted sender) smtp.mailfrom=01000169b534b9e8-31a2af2c-c396-47f9-8534-4cbd934ef09d-000000@amazonses.com
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/simple;
	s=6gbrjpgwjskckoa6a5zn6fwqkn67xbtw; d=amazonses.com; t=1553523325;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:MIME-Version:Content-Type:Feedback-ID;
	bh=QxVsvwno82TD/DL3wXtmz3tio2QUfM6l7WxY911mLLw=;
	b=HrFR8unfmFN4rnnt+Hqsx6IMNV5j6Ea/Am8KbVWjJx5WXZ9vC8pAxsdFJsEwsMr8
	IX6ny3v5i4pWq6vZO83gg1U5J8ocP78jveoB25urbgWFuwz8X1ZrdUpqRv3x8XkjIK/
	3zFEhG+E6hEoqvnb3aAcjzbuqhphsuE+dCz+h7hU=
Date: Mon, 25 Mar 2019 14:15:25 +0000
From: Christopher Lameter <cl@linux.com>
X-X-Sender: cl@nuc-kabylake
To: Matthew Wilcox <willy@infradead.org>
cc: Waiman Long <longman@redhat.com>, Oleg Nesterov <oleg@redhat.com>, 
    Andrew Morton <akpm@linux-foundation.org>, 
    Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, 
    Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-kernel@vger.kernel.org, 
    linux-mm@kvack.org, selinux@vger.kernel.org, 
    Paul Moore <paul@paul-moore.com>, Stephen Smalley <sds@tycho.nsa.gov>, 
    Eric Paris <eparis@parisplace.org>, 
    "Peter Zijlstra (Intel)" <peterz@infradead.org>
Subject: Re: [PATCH 2/4] signal: Make flush_sigqueue() use free_q to release
 memory
In-Reply-To: <20190322195926.GB10344@bombadil.infradead.org>
Message-ID: <01000169b534b9e8-31a2af2c-c396-47f9-8534-4cbd934ef09d-000000@email.amazonses.com>
References: <20190321214512.11524-1-longman@redhat.com> <20190321214512.11524-3-longman@redhat.com> <20190322015208.GD19508@bombadil.infradead.org> <20190322111642.GA28876@redhat.com> <d9e02cc4-3162-57b0-7924-9642aecb8f49@redhat.com>
 <01000169a686689d-bc18fecd-95e1-4b3e-8cd5-dad1b1c570cc-000000@email.amazonses.com> <93523469-48b0-07c8-54fd-300678af3163@redhat.com> <01000169a6ea5e46-f845b8db-730b-436e-980c-3e4273ad2e34-000000@email.amazonses.com>
 <20190322195926.GB10344@bombadil.infradead.org>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-SES-Outgoing: 2019.03.25-54.240.9.46
Feedback-ID: 1.us-east-1.fQZZZ0Xtj2+TD7V5apTT/NrT6QKuPgzCT/IC7XYgDKI=:AmazonSES
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 22 Mar 2019, Matthew Wilcox wrote:

> On Fri, Mar 22, 2019 at 07:39:31PM +0000, Christopher Lameter wrote:
> > On Fri, 22 Mar 2019, Waiman Long wrote:
> >
> > > >
> > > >> I am looking forward to it.
> > > > There is also alrady rcu being used in these paths. kfree_rcu() would not
> > > > be enough? It is an estalished mechanism that is mature and well
> > > > understood.
> > > >
> > > In this case, the memory objects are from kmem caches, so they can't
> > > freed using kfree_rcu().
> >
> > Oh they can. kfree() can free memory from any slab cache.
>
> Only for SLAB and SLUB.  SLOB requires that you pass a pointer to the
> slab cache; it has no way to look up the slab cache from the object.

Well then we could either fix SLOB to conform to the others or add a
kmem_cache_free_rcu() variant.

