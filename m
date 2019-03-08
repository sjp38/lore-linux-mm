Return-Path: <SRS0=92PK=RL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BBD72C10F09
	for <linux-mm@archiver.kernel.org>; Fri,  8 Mar 2019 16:15:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6088321773
	for <linux-mm@archiver.kernel.org>; Fri,  8 Mar 2019 16:15:50 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=amazonses.com header.i=@amazonses.com header.b="Bdlh199t"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6088321773
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C1DBB8E0003; Fri,  8 Mar 2019 11:15:49 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BCE3F8E0002; Fri,  8 Mar 2019 11:15:49 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AE21B8E0003; Fri,  8 Mar 2019 11:15:49 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 84D8D8E0002
	for <linux-mm@kvack.org>; Fri,  8 Mar 2019 11:15:49 -0500 (EST)
Received: by mail-qt1-f200.google.com with SMTP id b54so3835393qtc.2
        for <linux-mm@kvack.org>; Fri, 08 Mar 2019 08:15:49 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version
         :feedback-id;
        bh=ji1gWCycI5p2iP4rvxWvryTn4d9iM0jdB98F/39+uw0=;
        b=kUdPsXUlDUGF7PUUcdWRTNAf5dX4K1bVAw6IwaJyHmvRehBu9/VLH25n50RTSlXUyD
         jL/KslDrJntNn1+b1cX5NbFfACHvhJ7zxa92Y7qgi77YkJBY+yM1klmA/jK1vcQLX/1a
         yWYyxy1vw/xs65aWLNgwub+KLxgKuTuCNcVXG8guPyDd6TNzs9LI0V/Xn8rtL4DmKmXA
         s+zptT7NeQEn1HbWc9qXnCZUGsxPQq/W3a7bNOcMEIzskzFA7M+Z3Sbejzo21QaNaL3j
         sMeB644BAjal89S1aSZNDmbrPS3lUW4GWB4j2mqxPeTKpJGw4UaoX0eIrqMx9jwTplBE
         bzKA==
X-Gm-Message-State: APjAAAUnkEu83nY9hr8oWXsulTjR/KgOwnmxfvctAh+B/eUwwXQddBJH
	EFiTUJ5oPBrkIbmay2HY6ciWtdBCx5KrN+JDxALmvZ2G5lqeRGxw2eia9OKhgxCLCEsRzYPHON+
	OkXlQiT2D7qDTVaG3w4X9ziQh/53UgGsn07WOOMMboWrAUw65FdxBTw8V4t+E1Z0=
X-Received: by 2002:ac8:1c71:: with SMTP id j46mr15084710qtk.307.1552061749233;
        Fri, 08 Mar 2019 08:15:49 -0800 (PST)
X-Google-Smtp-Source: APXvYqxviKAUhwkbSFjjvP0hrEC4J7uPLr2fRqOaYUjRrQ5c6M6dtYZciPzGH2beZKC+xhaj+Bx0
X-Received: by 2002:ac8:1c71:: with SMTP id j46mr15084562qtk.307.1552061747181;
        Fri, 08 Mar 2019 08:15:47 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1552061747; cv=none;
        d=google.com; s=arc-20160816;
        b=Y+se3k6KxbH9s1t1OqJN9Jc4BrdgpXJ/lapcDd/I2KaonjvzDrm+xYSOLCjVqjaJNu
         0BuxTYpBsAhDTszlxSdk9IphuSNJ5Smt+ye0xf4XDxPQFvyVv2R9k3t85gNEnZhIXfeS
         4AuECbc76BIYhzhtiz7X9lNAirVxv+yEmc1SUTjuAk2h2nN90lWfWV018FM4fICECVH1
         yun+ee+R9Mk3Oa1RUdluF5+TO9qY3BcLGflyId+JUzgpXc/0dvwRBFdXGaC/q3xwZplP
         dADmK70zVyvnApraESVD1DhS29c5Bq3HJHzaQdz2HjY3jHWI2pPZR3NtlfD/a9yvjRvj
         t7+Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=feedback-id:mime-version:user-agent:references:message-id
         :in-reply-to:subject:cc:to:from:date:dkim-signature;
        bh=ji1gWCycI5p2iP4rvxWvryTn4d9iM0jdB98F/39+uw0=;
        b=z4vWr6qifTNX8bGeYAIfau+BXaqGZ8GnjcUuw4YJwywBHWsKlTvyHSxo+rdCPDugl2
         giCA30V9q92XAAt1Ddtxj0hFbNc9NKBu55BZOSS7VpYRUtkOYWD5hziIMBAqNYrKFe3R
         9XtTilLJpIDELAta3xSevOXd9c+5hR4952JUwq1sGLZ+sze43DLe63iZIUfLzVUS7DEN
         MJBRmsV0mbkB8WinfYVRdkWhl5OUeFUhwUOGIY7KxHLAcE9VTQZZJLKcVdkIQtSyoUVy
         ZXcZ9IYYRH9AjXGVVp5dci5ng/UlA2XRpnUXCR7zwZlU/onz+oPoh2/ZojHZkkQXsaFm
         YPDw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=ug7nbtf4gccmlpwj322ax3p6ow6yfsug header.b=Bdlh199t;
       spf=pass (google.com: domain of 010001695e16cdef-9831bf56-3075-4f0e-8c25-5d60103cb95f-000000@amazonses.com designates 54.240.9.36 as permitted sender) smtp.mailfrom=010001695e16cdef-9831bf56-3075-4f0e-8c25-5d60103cb95f-000000@amazonses.com
Received: from a9-36.smtp-out.amazonses.com (a9-36.smtp-out.amazonses.com. [54.240.9.36])
        by mx.google.com with ESMTPS id 57si1089280qtm.332.2019.03.08.08.15.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 08 Mar 2019 08:15:47 -0800 (PST)
Received-SPF: pass (google.com: domain of 010001695e16cdef-9831bf56-3075-4f0e-8c25-5d60103cb95f-000000@amazonses.com designates 54.240.9.36 as permitted sender) client-ip=54.240.9.36;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=ug7nbtf4gccmlpwj322ax3p6ow6yfsug header.b=Bdlh199t;
       spf=pass (google.com: domain of 010001695e16cdef-9831bf56-3075-4f0e-8c25-5d60103cb95f-000000@amazonses.com designates 54.240.9.36 as permitted sender) smtp.mailfrom=010001695e16cdef-9831bf56-3075-4f0e-8c25-5d60103cb95f-000000@amazonses.com
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/simple;
	s=ug7nbtf4gccmlpwj322ax3p6ow6yfsug; d=amazonses.com; t=1552061746;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:MIME-Version:Content-Type:Feedback-ID;
	bh=/YhXAXDRJDXOsTejfexgfUA00S53mbAhO1iS5RDasTE=;
	b=Bdlh199ty9IN8Ej4gyzpqKaM1H1Wjn9NMIGUmZMBcAvYi7Mhl69vXni2vKVGXj25
	kqt5tnz6THVec9DymhKofVJ2KNbxRnU9nyvmBLQdw33vYJn3Y3SXYdAUgVPebRtsLSi
	eQ0kotJgYuAtoPRNARfzZuCA9l78ofUeTGLCqLtQ=
Date: Fri, 8 Mar 2019 16:15:46 +0000
From: Christopher Lameter <cl@linux.com>
X-X-Sender: cl@nuc-kabylake
To: Tycho Andersen <tycho@tycho.ws>
cc: "Tobin C. Harding" <tobin@kernel.org>, 
    Andrew Morton <akpm@linux-foundation.org>, 
    Pekka Enberg <penberg@cs.helsinki.fi>, 
    Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org, 
    linux-kernel@vger.kernel.org
Subject: Re: [RFC 02/15] slub: Add isolate() and migrate() methods
In-Reply-To: <20190308152820.GB373@cisco>
Message-ID: <010001695e16cdef-9831bf56-3075-4f0e-8c25-5d60103cb95f-000000@email.amazonses.com>
References: <20190308041426.16654-1-tobin@kernel.org> <20190308041426.16654-3-tobin@kernel.org> <20190308152820.GB373@cisco>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-SES-Outgoing: 2019.03.08-54.240.9.36
Feedback-ID: 1.us-east-1.fQZZZ0Xtj2+TD7V5apTT/NrT6QKuPgzCT/IC7XYgDKI=:AmazonSES
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 8 Mar 2019, Tycho Andersen wrote:

> On Fri, Mar 08, 2019 at 03:14:13PM +1100, Tobin C. Harding wrote:
> > diff --git a/mm/slab_common.c b/mm/slab_common.c
> > index f9d89c1b5977..754acdb292e4 100644
> > --- a/mm/slab_common.c
> > +++ b/mm/slab_common.c
> > @@ -298,6 +298,10 @@ int slab_unmergeable(struct kmem_cache *s)
> >  	if (!is_root_cache(s))
> >  		return 1;
> >
> > +	/*
> > +	 * s->isolate and s->migrate imply s->ctor so no need to
> > +	 * check them explicitly.
> > +	 */
>
> Shouldn't this implication go the other way, i.e.
>     s->ctor => s->isolate & s->migrate

A cache can have a constructor but the object may not be movable (I.e.
currently dentries and inodes).


