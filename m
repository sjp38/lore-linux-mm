Return-Path: <SRS0=On+J=TX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	T_DKIMWL_WL_HIGH,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B5C11C282DD
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 21:33:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 748782177E
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 21:33:18 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="mFbl7W2X"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 748782177E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0727F6B0003; Thu, 23 May 2019 17:33:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0214E6B0005; Thu, 23 May 2019 17:33:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E2BB26B0006; Thu, 23 May 2019 17:33:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id BC34E6B0003
	for <linux-mm@kvack.org>; Thu, 23 May 2019 17:33:17 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id 11so5149430pfb.4
        for <linux-mm@kvack.org>; Thu, 23 May 2019 14:33:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=brzwJ9/Q1crPupxO4pYw46UIbDNtVFld1Gc4iiV7UvI=;
        b=QUtSrUNZL6+ovzR9i7Ka0LWbsNuoWRloQ0jexfNU9LUdD3pGRNPmTeKYbqOXH6YtAz
         +bMzXtxw1gB2phWhHsFL7/aT2kAgdhmftQ0NpUT02uOkNnU0NQwuucrXNDXbszQ7xwC7
         9Qs78wIENve3XLWyXqHmYgqKx/38Na7BpRkETylW+uxKI9Gnj7pCUJ1yTDy1DN288fGt
         INuaqCLIKnBWYo4OlYuesRvPgzpd2dFoi6Oz/ERzkRPP03QGokMeGPrdDYWipd8v5ue/
         OmIf1EeOS7JshFsRNlCY4Y+8NKHZTUAoghc1pGLLZfaPIvmttWpg4rhliFU9mVyepQg+
         1/BQ==
X-Gm-Message-State: APjAAAUDDAQZvAbn+0XPxXCUhckagS46qXy87fedqAZgtoBbZoCY+m6x
	o4RceSkEF2BSdLBJ+h3TiL07fHxOe3rj5k832SEHc9eFvFggo81wxi81nHwIrq2I+CB5e5Ielns
	J2K9xIP961dk5eZlRLak9rMiJiilc4ib94PWXaPSaIAS4yuEzEaGD6awKPMr5g7ob0g==
X-Received: by 2002:a63:191b:: with SMTP id z27mr100871047pgl.327.1558647197306;
        Thu, 23 May 2019 14:33:17 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzQcTATR6LqHKtw1wToRHBccuScpmXLqO7ydDt1BHFavHp0Kkd0r3eDiJvjIXy45/4vFS/s
X-Received: by 2002:a63:191b:: with SMTP id z27mr100870985pgl.327.1558647196643;
        Thu, 23 May 2019 14:33:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558647196; cv=none;
        d=google.com; s=arc-20160816;
        b=Xpe96j1AEWOfYNOvo7V8DfQIjotVU2ohNU1bHKSI3IjFHDXLKUhYpg6dae8dAv7QUk
         STv/lGDFUzS4K9amxIOgbvHKF+LjUXtYToTk3Re66IycmtTroaJLvK4AA+U0Lu/bp0gJ
         0vq4/1EeV+q5gXCM6kc5zkD4xvl+mXPt2WaUTKUHQaORIIw3aHcBJhFh2gewuQNT4TJ9
         ba3YihR2ROqumi8NbQgKPbCDph9KtzznK4KgGjPYrz65/tfOdg6Pp+xWwD7oSpEeDzzj
         OeqCeoDXqLSp6hEAN7gNGL7XQ7xqiy6BVK7ATH9Ix1/cAS4bRSEysH5kiGa+vD5BkAb6
         bMrg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=brzwJ9/Q1crPupxO4pYw46UIbDNtVFld1Gc4iiV7UvI=;
        b=QWQ+OT5CDL7zTbf5KVVF3qSNfAwDemPVYEJrk3wa+UHCSTubL0YMctjRQh3j3f006x
         IzxGYrjH8muuHEpekNchrTi5TJi1504GCv08aaBSwold1StJ/bqRG2LIlnxPHsuMh+YC
         WHP7u0+ZAfwRuhpGMO/Urm/g64gUoOIWWrK9uFWz8a1G9GwQriVGgveu43Knr2Z6O1sw
         Eo00fnoedLKyvK88a8XpWtTAE3SMOp0l2Zf4iW0Itg/amvcsPuR5bQ72HE5Ptwfz1mNY
         +okR+DPU22McAVYGSEXMlSN3YH7JHWwvaNhBGRoU2eUc+hmhsvEkJLdrySeybt1iZgWF
         KgwQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=mFbl7W2X;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id u92si1091189pjb.10.2019.05.23.14.33.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 May 2019 14:33:16 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=mFbl7W2X;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from akpm3.svl.corp.google.com (unknown [104.133.8.65])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 273AB21773;
	Thu, 23 May 2019 21:33:16 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1558647196;
	bh=h+m829r5l+lLoTjaTPTWUFMyS7kSp9Q6x/ifJZKzvys=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=mFbl7W2XislDUBDw4y7W7sGD+tt8q4dupSwJpNl1UFMLw/TqySTuiQSgwEb6f2dFB
	 4kf48agroeTyyY95Xhwg0Y0i1bpC1h5zgbNuRrKluk83XJ9KHUNKWoOvpoYS8beUtY
	 TweqmB1RvIF7BfIQ5BYFO8KMMHuo9efJo3Kwzrew=
Date: Thu, 23 May 2019 14:33:15 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Kirill Tkhai <ktkhai@virtuozzo.com>, linux-mm@kvack.org
Subject: Re: [PATCH] mm: Introduce page_size()
Message-Id: <20190523143315.9191b62231fc57942b490079@linux-foundation.org>
In-Reply-To: <20190523015511.GD6738@bombadil.infradead.org>
References: <20190510181242.24580-1-willy@infradead.org>
	<eb4db346-fe5f-5b3e-1a7b-d92aee03332c@virtuozzo.com>
	<20190522130318.4ad4dda1169e652528ecd7af@linux-foundation.org>
	<20190523015511.GD6738@bombadil.infradead.org>
X-Mailer: Sylpheed 3.7.0 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 22 May 2019 18:55:11 -0700 Matthew Wilcox <willy@infradead.org> wrote:

> > > +	return (unsigned long)PAGE_SIZE << compound_order(page);
> > > + }
> > 
> > Also, I suspect the cast here is unneeded.  Architectures used to
> > differe in the type of PAGE_SIZE but please tell me that's been fixed
> > for a lomng time...
> 
> It's an unsigned int for most, if not all architectures.  For, eg,
> PowerPC, a PUD page is larger than 4GB.  So let's just include the cast
> and not have to worry about undefined semantics screwing us over.

I think you'll find that PAGE_SIZE is unsigned long on all
architectures.

