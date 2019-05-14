Return-Path: <SRS0=IoHm=TO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DB844C04AB7
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 21:25:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9A8222168B
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 21:25:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="in6s4kav"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9A8222168B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3300D6B0005; Tue, 14 May 2019 17:25:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2DFF96B0006; Tue, 14 May 2019 17:25:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1CFB66B0007; Tue, 14 May 2019 17:25:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id E8AAE6B0005
	for <linux-mm@kvack.org>; Tue, 14 May 2019 17:25:29 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id s8so365502pgk.0
        for <linux-mm@kvack.org>; Tue, 14 May 2019 14:25:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=WgerOWjZ9+4Ai4l2gMcrs7bWBOutj23VZyALvFXO3OM=;
        b=dZIkOs2QSIVNvllr1yoYlRCRpnivFy42XoIGGLd8xccP5T1jaH2P9bBS7hqd6q3kWI
         9HpzeObSxraczzLGIn4ObMx5DrCf1+dxPVWl5nXpKjX9OoaYXLYbQjQqeHhI2vWYPVQz
         p8FGYJKPGL0RbCPsOij8U+A4l/duV8jXNRihBEqsqpt/JDss3uakAUhTXnJ9YP86xm0e
         dum978+zX32uzqjZwnu8YP4WZAyNwy+W3dWLrA6LQzMBbAU5SgV69pka82yLDqaNh2Q0
         Ks0mVyUPuxYS/UF2NmeCR3NSGjkeqIytLLNHfUha5lU/KrNGeRGIjSM8UY8is6NQ46N+
         dlZA==
X-Gm-Message-State: APjAAAVYaNKpSd/JS/9ZKs7xMZPzWkQpUp6obSb0/jiikqmuwCPX+JyH
	KpMzFc/+Nl8tpZeXyGmxGzleDUNlrxU9MgIiUKxAJj8voezKXlI2K/I80RF01UtfT401V/DVTGR
	EUwrVVfSHzPuw4FKE+alZwnamPDvEcjBAurdPbgzhGXzuk7ZxG8t5wSgXuUved8ii8g==
X-Received: by 2002:a17:902:aa45:: with SMTP id c5mr39218129plr.144.1557869129489;
        Tue, 14 May 2019 14:25:29 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwBt9rSL2py0DFI6h47zZSg+t/Bzs5IwtiTyXLg/JaKftqe0xoVcuDI4Y+7DoL7R7/k08P5
X-Received: by 2002:a17:902:aa45:: with SMTP id c5mr39218093plr.144.1557869128873;
        Tue, 14 May 2019 14:25:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557869128; cv=none;
        d=google.com; s=arc-20160816;
        b=Nl764zvxGJWjgcnG0cj3F8bb9Rj/EWQxkruSW0sQJxalAeKLAtH7P5keA7KdelYnSy
         P4ILR6Ycf/XTVWow0+0DiTRQOa4/iK2XQGlT7eOf/c+BdiZeIxExtlYSrxkuUeHf9zlI
         IbosJNMGmoiyF6j/4WCq5nlfG0/M4i3BdGYbR3SW+tiAaE1naIM2xcW3dysOOBS6Swrz
         LBEkeih0FQ8HQmUywonkFxluN6yFsdlD1GVQXmxp/1EHRQM069SAD6j9EsqGt7H6ahHj
         DpiNVlphkWzjWVooPd+/5i7todboILOZ8ejYLS4FfNH4KhVkHbY5xoTUr7CTWgD4MLPe
         AzlQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=WgerOWjZ9+4Ai4l2gMcrs7bWBOutj23VZyALvFXO3OM=;
        b=V7hxVL58KSYxP/HPNIYcLTv8KrPHwYKaxdV3nBLv/FI2lDcIVx9KOsJxJiePItYH/i
         00IZPrbWV4Xma/CleBWWplrasnR/JTOLtPQdGeTLugQdpALvM3pCRjmTbYeJqb85uRnm
         0ujAIGYNCyBlruQcFW5ey20HySsYEsEPaS6MHWGY5BnDapQN32P85d+EHeY/0t4Nw975
         0Ip4jtyWMnzhBmUHoS/CML5WD5R3Q2q0y6DGPi7AQH3oFpFlpIDuzq40/56kXLq7Yrsk
         jFFB2o1J0X1ZJeZmL3seCS4PXjSFDOvbU5/03J848axAqFyhpLOWGYnaV8KltVbnEAG+
         DdpQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=in6s4kav;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id cp14si1906890plb.183.2019.05.14.14.25.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 May 2019 14:25:28 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=in6s4kav;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from akpm3.svl.corp.google.com (unknown [104.133.8.65])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 5477C20850;
	Tue, 14 May 2019 21:25:28 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1557869128;
	bh=UZ4GiHlaes+DK9pTRaINLCCHnDA+gTfRjxFFWYfxM7A=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=in6s4kavbJOqz1htYNcOrmRgNhqbR7debNloGeI2j6UOlezuFCKfAmXN7F5c9pKYh
	 uskx6J3YJLPlJeih8oVt5Lw4Q3e7lrzehsr6+Wwm0nz95Kyyi6g1d5+nS7LASkZZ7Q
	 xvOsJhAsaMVwkubJO9XAemKPjMf8QHfxQN/hX+ws=
Date: Tue, 14 May 2019 14:25:27 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Yu Zhao <yuzhao@google.com>
Cc: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org
Subject: Re: [PATCH] mm: don't expose page to fast gup before it's ready
Message-Id: <20190514142527.356cb071155cd1077536f3da@linux-foundation.org>
In-Reply-To: <20180109101050.GA83229@google.com>
References: <20180108225632.16332-1-yuzhao@google.com>
	<20180109084622.GF1732@dhcp22.suse.cz>
	<20180109101050.GA83229@google.com>
X-Mailer: Sylpheed 3.7.0 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 9 Jan 2018 02:10:50 -0800 Yu Zhao <yuzhao@google.com> wrote:

> > Also what prevents reordering here? There do not seem to be any barriers
> > to prevent __SetPageSwapBacked leak after set_pte_at with your patch.
> 
> I assumed mem_cgroup_commit_charge() acted as full barrier. Since you
> explicitly asked the question, I realized my assumption doesn't hold
> when memcg is disabled. So we do need something to prevent reordering
> in my patch. And it brings up the question whether we want to add more
> barrier to other places that call page_add_new_anon_rmap() and
> set_pte_at().

Is a new version of this patch planned?

