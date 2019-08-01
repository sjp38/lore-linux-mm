Return-Path: <SRS0=cJsh=V5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9598AC433FF
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 07:01:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 34B0D2089E
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 07:01:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 34B0D2089E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DC77F8E0006; Thu,  1 Aug 2019 03:01:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D778B8E0001; Thu,  1 Aug 2019 03:01:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C407E8E0006; Thu,  1 Aug 2019 03:01:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8E6A68E0001
	for <linux-mm@kvack.org>; Thu,  1 Aug 2019 03:01:55 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id s18so35031064wru.16
        for <linux-mm@kvack.org>; Thu, 01 Aug 2019 00:01:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=/S2h88IKiOej42Ja9Iot5OrAIsAOaPUWxITxWpZwYj8=;
        b=nq0zvUc7iK3NN+USRQyW7KBrI3Mp62gjWyMWMPwFHy/hp7dgM65OZL7pVWN6nqRBq/
         Yh+36QBQHAt5smtAUHPkXYOV42xoqRD1+X5HhvQkA5lapLj8ysaEUP9ITvtb5ttfklq+
         HdBNbRfnwBDpt4x0eSn0ITuwenguliLQlP26tOlhtkLDx7P0lP3TTHQFXrt79QzA6wmA
         44lRk0FFLOWp+SdSNn8dfGq9Hqv3tGDWXma0BaKbRjHndZK50bEAFoZBFFLDUcHoSkEN
         NiaSU3Buhy04Wwv7e6cgsTcRkIJAHyFN37s+gennVU8KyuXw6hVc/hcjb7FNu15XhLGf
         TNWQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
X-Gm-Message-State: APjAAAVSwMO3A1NbAzmhB7N/S3LBIreMuRzVirhi8/bhsp8OtT8dzPfZ
	KpQhIodub5Lni75MOW7RCvNLTcdSgGtoHrgZaxi0+uNBU7yNpxNNC4IkajpQ6UFimo7Z9CmPxjh
	76YhrzNc+pNp57gu90jpwvPfcF8SgOiGyyHAX9dpsbEOfrRMAYDcd2EDc+/Kf24p3KA==
X-Received: by 2002:a1c:e009:: with SMTP id x9mr112646285wmg.5.1564642915083;
        Thu, 01 Aug 2019 00:01:55 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxfHBClaY/yf08QHpH1MElnFHaPe4XO3wwQa3z2H8izDN7eTRCeJGMIFqxWMn5QYNxwZApL
X-Received: by 2002:a1c:e009:: with SMTP id x9mr112646210wmg.5.1564642914273;
        Thu, 01 Aug 2019 00:01:54 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564642914; cv=none;
        d=google.com; s=arc-20160816;
        b=0A9iZWsK5m1eRp6amauFMw61nAjvq0IfA1g2vpEuBM05vcIsVXmR8IlMgTN0C0RrFj
         xcVTmha0j7Y4ez01fMpo07p6YGwNJpuzhd6JdNBd7UnlFSJXKBQ8LK3AWNpc+6uQ5y9a
         F2qdihecQJfMvrqEH/z7/5dKoiB+xDk++tJxZPPvMuznYveRjzvSJ9hqYk4ewASfSJ+9
         0W72j3AygcMav6wM3KcD49TyM47X8PncY7XDqnDxCVGNswo8UmX1AF/n6YwlWpCXUG/n
         t4hrugx8sH8FxGpxNi1uWyJWZmJbkTpjJ3zOg1yttVOhw2wKuogwppA9N9kQXyOSmhMU
         sgIw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=/S2h88IKiOej42Ja9Iot5OrAIsAOaPUWxITxWpZwYj8=;
        b=jl+/mRQyuXDRmIutSINP6zV7i4t0JFlbXNZhKPpYufERSNDOSUCiWyiA52q0hJ1cA8
         538VmFfZyEb+MDzJrTENdgcHc6XtolfChiGBNH2Wa602ATmcikEn9WE98vuW2+s7MnWo
         CMuo6EGx6VQ6P9LPyRMkQbs0guozU385zN0wM0g2mP+FK8bZfJO6CFOXoKy5mnVNuRuK
         FBW8ZijXIffzewG18JEiiIgej6zRRv99/CxkQmTEWDNn1QOzoNPXPs+Mjmd06ct+L/PO
         dWTbR5OoZQwJ2BJrUNr8jcTGdaRkjcDVi5JE5vzfaKXTeSy3TsCIVJORc/6egm16jC+I
         A+6A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: from verein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id p191si53949503wme.144.2019.08.01.00.01.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Aug 2019 00:01:54 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) client-ip=213.95.11.211;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: by verein.lst.de (Postfix, from userid 2407)
	id 8C39E68AFE; Thu,  1 Aug 2019 09:01:51 +0200 (CEST)
Date: Thu, 1 Aug 2019 09:01:51 +0200
From: Christoph Hellwig <hch@lst.de>
To: Jason Gunthorpe <jgg@mellanox.com>
Cc: Christoph Hellwig <hch@lst.de>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	Ben Skeggs <bskeggs@redhat.com>,
	Felix Kuehling <Felix.Kuehling@amd.com>,
	Ralph Campbell <rcampbell@nvidia.com>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"nouveau@lists.freedesktop.org" <nouveau@lists.freedesktop.org>,
	"dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>,
	"amd-gfx@lists.freedesktop.org" <amd-gfx@lists.freedesktop.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH 11/13] mm: cleanup the hmm_vma_handle_pmd stub
Message-ID: <20190801070151.GB15404@lst.de>
References: <20190730055203.28467-1-hch@lst.de> <20190730055203.28467-12-hch@lst.de> <20190730175309.GN24038@mellanox.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190730175309.GN24038@mellanox.com>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jul 30, 2019 at 05:53:14PM +0000, Jason Gunthorpe wrote:
> > -	/* If THP is not enabled then we should never reach this 
> 
> This old comment says we should never get here
> 
> > +}
> > +#else /* CONFIG_TRANSPARENT_HUGEPAGE */
> > +static int hmm_vma_handle_pmd(struct mm_walk *walk, unsigned long addr,
> > +		unsigned long end, uint64_t *pfns, pmd_t pmd)
> > +{
> >  	return -EINVAL;
> 
> So could we just do
>    #define hmm_vma_handle_pmd NULL
> 
> ?
> 
> At the very least this seems like a WARN_ON too?

Despite the name of the function hmm_vma_handle_pmd is not a callback
for the pagewalk, but actually called from hmm_vma_handle_pmd.

What we could try is just and empty non-inline prototype without an
actual implementation, which means if the compiler doesn't optimize
the calls away we'll get a link error.

