Return-Path: <SRS0=KVn2=RQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EDCB7C43381
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 19:05:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id ACD682075C
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 19:05:04 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=amazonses.com header.i=@amazonses.com header.b="OnFv8cOO"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org ACD682075C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 39B808E0005; Wed, 13 Mar 2019 15:05:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 34AC88E0001; Wed, 13 Mar 2019 15:05:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 239C58E0005; Wed, 13 Mar 2019 15:05:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 015F28E0001
	for <linux-mm@kvack.org>; Wed, 13 Mar 2019 15:05:04 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id x12so2929360qtk.2
        for <linux-mm@kvack.org>; Wed, 13 Mar 2019 12:05:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version
         :feedback-id;
        bh=xipMzI5wN46dvzpIIeLGM7h+ZMHrHGWnWINaUjeKyFE=;
        b=T6OFr4vb095lU9MtjcCnBiJeexDoNT1ypwWMMOty+BsVMvPT6wAfCOYqUfJUkMCvFz
         yu2FFgqsLVOn+ZINpPBiqhf3sbyc6+1dBPsdf6fqySEji8p/KDk0Baklerh4yPrzULDP
         dv1agvaD9UuG4z+XG/Ahv4o4+eZBYLlaQTuItEfK5TaqoEsWf5hk6djLzUUIPkOgs9SG
         sVa9zAdrzSIPyhzp+PjT6dytfQbdjNdeEXsbOLNmiggOjDQTdjmzJ84L52Iju9ZyKCeA
         IxwPNhljyxsHcQEWzIxEGPcACxsJAiWmlPAGBsTN95PXe9ioUizohj/HGTKS2wG73rTf
         hXNg==
X-Gm-Message-State: APjAAAX2zHOTFvu/NqZIAVh3soakgrzpKwJQPmPd2/dQHakcHPbEoc6b
	ulIGxRzCp+oGZJxcYD/c8u49lAPXIrNWqf/wJ6ExWO062Wvi+ySPgQP67O0QJDBrnGp8CUtcmkn
	NnPf+gNBn4wNA5rJTxt07u+bJXZGzXVSwfiU9fwD5jERrkXnEsyPstA6ALZJ0Cvg=
X-Received: by 2002:a05:620a:1443:: with SMTP id i3mr1157313qkl.265.1552503903822;
        Wed, 13 Mar 2019 12:05:03 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx4irFjUOXLGUlTl45/avdTZh13KnBG2o5vJbhr6ZLvVWyu5kFEHiOou/edgp313gTUSw60
X-Received: by 2002:a05:620a:1443:: with SMTP id i3mr1157250qkl.265.1552503903064;
        Wed, 13 Mar 2019 12:05:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552503903; cv=none;
        d=google.com; s=arc-20160816;
        b=N+yRSVIE6THC1GxRShAvZt61EgZQ97hx3ZFku3ntBW1ucR4gWaoF+WPDY4Ndrlboa+
         SgZOOavLxYgaPDyrLTE0MFXY1DFTos3P2nYVxe7H0EeyDEyMakjgHwdDNm8a6Gs/ZMXY
         TPTadowuFj5BfGgSMdHI5UuQfZLRwhExapim5tLn41LUJo+GG9/UT/cV5wIRk+AHj1CT
         z9JbKdtvubB1Owz04r35RLgdQ79B7BvfDY5i2Qc9MX/1biBhhEdF8cmqYYo4RZ5ynS0g
         /1WaKsC5vnWPeh1kzXaXPy+zz0xDC8OqUZyPCV7F7ZZgpFa7SyGkRE5VHj5RwhVqwg7d
         AuMA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=feedback-id:mime-version:user-agent:references:message-id
         :in-reply-to:subject:cc:to:from:date:dkim-signature;
        bh=xipMzI5wN46dvzpIIeLGM7h+ZMHrHGWnWINaUjeKyFE=;
        b=rcjqG4OdjTf83GkRLxCQ2Q3/lLOTc0ItrecRZ4/0zbB41IPpCxYzLvSwq+pyStdsB8
         1xfSGedkrYNy1/4Ok1AQlh8k5PIsETvr/gDVS27H91JUzwqBwJKGoY8Ukj+G+JfhE+kN
         tCPan3JzOxOM96DIc4sW2O1po7Ij3jUPr2Mti7DLuBWlPT488JqBOF40soneg3eve2jn
         juFXW4IuVva5OmtC/yAib67Y2ELa/JKTlSw/WAu1lFbm/bibi0yOL8bNOXnQuBTF8Sgu
         zsvD4vSDRoOHINHKJqOvaCY1rMmZ6m2ubZ5lsV0gvZ4BJJhX2ssQer4RgC3Rv2Dj/4ZQ
         kO7w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=6gbrjpgwjskckoa6a5zn6fwqkn67xbtw header.b=OnFv8cOO;
       spf=pass (google.com: domain of 0100016978719138-5260db28-77f5-4abb-8110-2732aa709c5e-000000@amazonses.com designates 54.240.9.92 as permitted sender) smtp.mailfrom=0100016978719138-5260db28-77f5-4abb-8110-2732aa709c5e-000000@amazonses.com
Received: from a9-92.smtp-out.amazonses.com (a9-92.smtp-out.amazonses.com. [54.240.9.92])
        by mx.google.com with ESMTPS id z48si7895qvc.138.2019.03.13.12.05.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 13 Mar 2019 12:05:03 -0700 (PDT)
Received-SPF: pass (google.com: domain of 0100016978719138-5260db28-77f5-4abb-8110-2732aa709c5e-000000@amazonses.com designates 54.240.9.92 as permitted sender) client-ip=54.240.9.92;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=6gbrjpgwjskckoa6a5zn6fwqkn67xbtw header.b=OnFv8cOO;
       spf=pass (google.com: domain of 0100016978719138-5260db28-77f5-4abb-8110-2732aa709c5e-000000@amazonses.com designates 54.240.9.92 as permitted sender) smtp.mailfrom=0100016978719138-5260db28-77f5-4abb-8110-2732aa709c5e-000000@amazonses.com
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/simple;
	s=6gbrjpgwjskckoa6a5zn6fwqkn67xbtw; d=amazonses.com; t=1552503902;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:MIME-Version:Content-Type:Feedback-ID;
	bh=CDYmVMH7PAkHSQKUXC14Z3jOmSyhKpP/gELxNikp4NE=;
	b=OnFv8cOOAKVXVVH0bLgfTrhVe2UIZcprhHhFW2YY1sdh3KtqeMBoeQtcQ89QgZXi
	wuDP2mJSlDWEfGjhQnYOcArIhieEXw+1ymWBxk48McCj0ICnAfak74SADK3a1Jwgj9L
	lV6PQhPtLJxksHhczsozt4o3qKAqBsidqv3byjBA=
Date: Wed, 13 Mar 2019 19:05:02 +0000
From: Christopher Lameter <cl@linux.com>
X-X-Sender: cl@nuc-kabylake
To: "Tobin C. Harding" <tobin@kernel.org>
cc: Andrew Morton <akpm@linux-foundation.org>, Roman Gushchin <guro@fb.com>, 
    Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, 
    Joonsoo Kim <iamjoonsoo.kim@lge.com>, Matthew Wilcox <willy@infradead.org>, 
    linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH v2 4/5] slob: Use slab_list instead of lru
In-Reply-To: <20190313052030.13392-5-tobin@kernel.org>
Message-ID: <0100016978719138-5260db28-77f5-4abb-8110-2732aa709c5e-000000@email.amazonses.com>
References: <20190313052030.13392-1-tobin@kernel.org> <20190313052030.13392-5-tobin@kernel.org>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-SES-Outgoing: 2019.03.13-54.240.9.92
Feedback-ID: 1.us-east-1.fQZZZ0Xtj2+TD7V5apTT/NrT6QKuPgzCT/IC7XYgDKI=:AmazonSES
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 13 Mar 2019, Tobin C. Harding wrote:

> @@ -297,7 +297,7 @@ static void *slob_alloc(size_t size, gfp_t gfp, int align, int node)
>  			continue;
>
>  		/* Attempt to alloc */
> -		prev = sp->lru.prev;
> +		prev = sp->slab_list.prev;
>  		b = slob_page_alloc(sp, size, align);
>  		if (!b)
>  			continue;

Hmmm... Is there a way to use a macro or so to avoid referencing the field
within the slab_list?

