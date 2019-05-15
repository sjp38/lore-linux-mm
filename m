Return-Path: <SRS0=idO3=TP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D4918C04E87
	for <linux-mm@archiver.kernel.org>; Wed, 15 May 2019 15:18:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9673020862
	for <linux-mm@archiver.kernel.org>; Wed, 15 May 2019 15:18:20 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="tB4V3nQd"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9673020862
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 366636B000A; Wed, 15 May 2019 11:18:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 317796B000D; Wed, 15 May 2019 11:18:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 206496B000E; Wed, 15 May 2019 11:18:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id D9E146B000A
	for <linux-mm@kvack.org>; Wed, 15 May 2019 11:18:19 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id d9so23546pfo.13
        for <linux-mm@kvack.org>; Wed, 15 May 2019 08:18:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=nKlUy/hi0pOvOwp9+flkg2CxiT2GvqwO6wvGfA+BWbw=;
        b=XVB3WJ3QGTXVMEatFrt49LCQpHEN33z/0m1IcFZy5WoTdySM7dmuthEMXHv5rsG+G4
         4aBCkWFV0AeXscZZrr+VGLP+xd847rKRu+wO13aciSm55HrxaaUO6WDJgUTzIjmJntsH
         C1WijW5WX6tmFHk/ZOVJ81QX9KBF3rP8YU0tYj7o+mgPxBh89EQlKXRFuuhwj7Xnz1W8
         VebtTVsHrgKxixUqYFS2YftP0MPAe2kh6J4mn3ncEdeev9T/iND89j6uEX8hXenAAVTv
         0NKMfHyLq3kUQq/mqnt6TJZuknEfN1o6AdE8+kXp2VIJB0r9qPekzrqcqMW2p65KfFnp
         G6og==
X-Gm-Message-State: APjAAAX6AZVNMQ291YSISKyYydjR8OrpL1Kk6zT/yk/gJDXJPUmXPE3c
	Mv1n1kBZ6p92All5AN/qVBH/ASYbqZ+/6+Xbinvh/2nTEFbmIkgrkHdeC38zObKY8gEodkv1n3S
	GmV9xXWTRtY7jmqXOFNTXTk+bEvc6o5VrEZvgGn6JFuS/CAiaiFpEbHzsMUEf+mJPNQ==
X-Received: by 2002:a63:5964:: with SMTP id j36mr44790005pgm.384.1557933499452;
        Wed, 15 May 2019 08:18:19 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzyYwbDDGYNNU6zeRpkjYusL01URbU6X69QVcXxhkbcGFOLOHJprgycNGy3HUETj05xQz52
X-Received: by 2002:a63:5964:: with SMTP id j36mr44789944pgm.384.1557933498657;
        Wed, 15 May 2019 08:18:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557933498; cv=none;
        d=google.com; s=arc-20160816;
        b=0UC2QmYylLi6BP6B0nRKmUYWquK5RaBgQvfHzAbIK2kLMWppTcXVUv6KQhdc/ijxhA
         FQZJAF63OLgy3dY/t/erN24ZaumS1DbjE4YxZRB2HCKFxGxCUJSmzzBwnB8kI5grKNtJ
         Oz1H0Sm9W2M7Pegv5g7XEyraCPQyxdMHGY/DUcv/1htf0P6QJ2TJaI1wOUWcwaNfakZF
         gZBCxqPfENlSVfuK+jO+NqRCZg1mrHcRkT9QQtyleMw21kdsY9NHBsSg98l1iW3Qrw+o
         h2UUI33hvtZRje60CpBGCFNSpypjO80YoOsSJLSs9MRYg78IwGz5NWkAmt2DGUCWTkW6
         RxoA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=nKlUy/hi0pOvOwp9+flkg2CxiT2GvqwO6wvGfA+BWbw=;
        b=lLX0Di4rxf9XiBp0b95AYAEgn4HNzsf/RKv7177RHPpix1Wzma+F7PZdAeMLxJSlFP
         eaMc6bHx+qIsdI7rE4C+or2VhME4ciSsgghatfDi+0WznUoxRx/5jR6R5Tcr1xUBlwl6
         d3glJvxkoqJ1HqSapnKQNSAvoYotjoAewYAfX2javkJEIfbdxp+g1hbN+pGwjWxGh7KR
         NzSCR4nr/tuFKk0q4jG1rJfTccyubQE7URHaDRTuMuvt1OoNfDh5nb6egt/YdkTnIIy/
         WP+DlCSd597A1eALaTJK3RvKezMZzx6zYQpRp3fuS89z7VMF2I4r0NIER/Why9vsVLop
         Ojww==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=tB4V3nQd;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id d129si2383288pfd.267.2019.05.15.08.18.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 15 May 2019 08:18:18 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=tB4V3nQd;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=nKlUy/hi0pOvOwp9+flkg2CxiT2GvqwO6wvGfA+BWbw=; b=tB4V3nQd2C2I75CfF3dnpH/D8
	afJxcTTl3v9s5M27ZpBjsj2FhoMDXtk+xX300GkyzknTnwHOMK7dFZjDUJLFVbJqFfsykTYTqkTDd
	xtBfoJcdtvTjztwwz/gvFno5ysKIRrGqF5indcfeedmRa6tF45nuDcZn/H1icaLOk2mcvpkjRrqQM
	fHFal71CVmW2uWOVt5CER3FpAXZWYR0dcbZadz0A2WREgGofJx6X0X6kbxK0FfjFbs2Znq+9CVJWT
	CqJc7Ye+8NeGL+5n6K1Z/Nnj3JmuO3SQ7Jl9TdkEiK4CnHtzUdnpVcgd9nhX1aoFGpAHDxb2MHZlM
	xG4tl8AuQ==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hQvfb-0001fU-1F; Wed, 15 May 2019 15:18:15 +0000
Date: Wed, 15 May 2019 08:18:14 -0700
From: Matthew Wilcox <willy@infradead.org>
To: Eric Dumazet <edumazet@google.com>
Cc: Lech Perczak <l.perczak@camlintechnologies.com>,
	Al Viro <viro@zeniv.linux.org.uk>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Piotr Figiel <p.figiel@camlintechnologies.com>,
	Krzysztof =?utf-8?Q?Drobi=C5=84ski?= <k.drobinski@camlintechnologies.com>,
	Pawel Lenkow <p.lenkow@camlintechnologies.com>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: Re: Recurring warning in page_copy_sane (inside copy_page_to_iter)
 when running stress tests involving drop_caches
Message-ID: <20190515151814.GD31704@bombadil.infradead.org>
References: <d68c83ba-bf5a-f6e8-44dd-be98f45fc97a@camlintechnologies.com>
 <14c9e6f4-3fb8-ca22-91cc-6970f1d52265@camlintechnologies.com>
 <011a16e4-6aff-104c-a19b-d2bd11caba99@camlintechnologies.com>
 <20190515144352.GC31704@bombadil.infradead.org>
 <CANn89iJ0r116a8q_+jUgP_8wPX4iS6WVppQ6HvgZFt9v9CviKA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CANn89iJ0r116a8q_+jUgP_8wPX4iS6WVppQ6HvgZFt9v9CviKA@mail.gmail.com>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, May 15, 2019 at 08:02:17AM -0700, Eric Dumazet wrote:
> On Wed, May 15, 2019 at 7:43 AM Matthew Wilcox <willy@infradead.org> wrote:
> > You're seeing a race between page_address(page) being called twice.
> > Between those two calls, something has caused the page to be removed from
> > the page_address_map() list.  Eric's patch avoids calling page_address(),
> > so apply it and be happy.
> 
> Hmm... wont the kmap_atomic() done later, after page_copy_sane() would
> suffer from the race ?
> 
> It seems there is a real bug somewhere to fix.

No.  page_address() called before the kmap_atomic() will look through
the list of mappings and see if that page is mapped somewhere.  We unmap
lazily, so all it takes to trigger this race is that the page _has_
been mapped before, and its mapping gets torn down during this call.

While the page is kmapped, its mapping cannot be torn down.

