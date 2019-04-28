Return-Path: <SRS0=7ROk=S6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D68CCC43219
	for <linux-mm@archiver.kernel.org>; Sun, 28 Apr 2019 16:12:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6DCF5206BB
	for <linux-mm@archiver.kernel.org>; Sun, 28 Apr 2019 16:12:00 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="DAN4lk4g"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6DCF5206BB
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linuxfoundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E8C206B0005; Sun, 28 Apr 2019 12:11:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E390C6B0006; Sun, 28 Apr 2019 12:11:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D50866B0007; Sun, 28 Apr 2019 12:11:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id A9F356B0005
	for <linux-mm@kvack.org>; Sun, 28 Apr 2019 12:11:59 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id b8so4516614pls.22
        for <linux-mm@kvack.org>; Sun, 28 Apr 2019 09:11:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=dHR1+jo20MCFrN4Rkk6nwhSG3M9mS73ha2b2zCEwaSo=;
        b=fBwAnK3uOWQVg9fKloWILXsenjsou15HS3/djx4TGehwvAiHseLQtWzLLXKf5YC13h
         Uomw7k6KtjqB3K9IwnvwYBfpRaxCjkn/w34DM4iFDZmtz8wiw9iO1/Z46Di+XUO+pdiw
         cZtjLrjSUP95qn/wNF85qh+bld0gga/z7SvT8apFyj9Tm5oB1+qgPLDjHYZtuQ7F5HBV
         Xp2q++Y/mAAq3A1/sa6HSPYewBaal8d7IkpYNgI98P3SAqTbnSZfqLqgilVOVsFH7EkO
         uJ/k7DSurWLWMvAjlbClCnpThnVHEn6S37vD7/rT7TtV+Dbq5FMa6e7vPLuCE99e4YGI
         Fs+w==
X-Gm-Message-State: APjAAAWZRT8rlL92deXhraJltfM0+kZNzkN6rYok8EEEUB3SbfGmEoPs
	uqfky0oJaD1xwMPCymzENzbNfb2Ne5cL+p76Ow7nJYeWeo0ktD+Lgs+XLtBJ6b3Rl9dzEuPh0ce
	ykmQJJwBx1Gh3YZpISw4X8lF4JotFwWXSEgv4Ut7Unsq5czf9jaGILsE2Na+CLiIHoQ==
X-Received: by 2002:a17:902:e208:: with SMTP id ce8mr42802613plb.99.1556467918752;
        Sun, 28 Apr 2019 09:11:58 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwVIlIuFWyAtznvmkolL5z0P7Rv9vO01NwfMKHgFRTOsQNocwH33xDQ2w2xf14nXKLpvKSN
X-Received: by 2002:a17:902:e208:: with SMTP id ce8mr42802554plb.99.1556467917830;
        Sun, 28 Apr 2019 09:11:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556467917; cv=none;
        d=google.com; s=arc-20160816;
        b=BD0b8zZQjSObol8t5phRpFJnbC/4epU5Moypzbtv/Hu682btFUl+gfLBcbtu2hO/lY
         693+jKRlDXdxCD3ZZP8dANamI2YzbNPYG6lCLrYJ4ZDCLQlir9InXFKdgP/+RydBYJoW
         RFmxgmrYeO4uoLXYTAJ7PjD0JlpOhhiJt9EUJ5hiGyyg9DqkldJ9Df/w5cetAKh6N38S
         pd6CEAgLD3HzeEhdlGU5V5v3B+abSQnX91Ij80K0aybKu1DIQyziiUM3Tdg0TeP0k/Qk
         IYATDM0+QCu/JymdpKVshwX5T6cPHFnYACmyPaM20zofKhJeAHBDpJYkwu+9Abat973S
         yB6Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=dHR1+jo20MCFrN4Rkk6nwhSG3M9mS73ha2b2zCEwaSo=;
        b=LE4r4qGjuoey4gec08fSlQU15qzUzsBveysA/EiSb0M3iC6jLrQsK6XQmlzhnyT5rU
         dvr451jPmfrwsFEGUAXXFSHG/9KTnvZ5SnR19MNrdphocnVmirlfWAGb7MkFTD7IrVwo
         q7QYwGHZvqv5iy9OjX0PjGP8lTL51WhDKhIBFerNZbwkTv4XGZuwK7lgB12sdg/tvcMH
         jcGARj2Akg8GeD3iHp4lLkzC5kQi8lhnGaX7XYbhew82sCuPdO1XycAQkYIvPuU7Nwzd
         jbK8o5UGbPz3zTqNw8Ar3QL/DUmYFe9ThDc2/2G6pI2NsyGhHoV9zudlopc5+PoUsK2b
         k4zQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=DAN4lk4g;
       spf=pass (google.com: domain of gregkh@linuxfoundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=gregkh@linuxfoundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id j11si3168721plb.302.2019.04.28.09.11.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 28 Apr 2019 09:11:57 -0700 (PDT)
Received-SPF: pass (google.com: domain of gregkh@linuxfoundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=DAN4lk4g;
       spf=pass (google.com: domain of gregkh@linuxfoundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=gregkh@linuxfoundation.org
Received: from localhost (83-86-89-107.cable.dynamic.v4.ziggo.nl [83.86.89.107])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id B0148206BB;
	Sun, 28 Apr 2019 16:11:56 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1556467917;
	bh=2Ih74ArNwrd6gnsd0tRO11DhEMb/gVUv+2PFxNCE+G8=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=DAN4lk4g6/dTf1qoG/xYQWHG4nkNjfg65R3CC6FHYwrqsB/Rp87fBqdFpZisa5ST9
	 uZ3chYsuUVm+r+rfEYUcJtQeWOXlUm0fOYNK3uvf3ZsRA850AgjBUrkE0NjSnpWUHt
	 coeI8RomF3dpN3F47qVhw/MU7UvGceCSrC2AW644=
Date: Sun, 28 Apr 2019 18:11:54 +0200
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
To: "Tobin C. Harding" <tobin@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>,
	David Rientjes <rientjes@google.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH] mm: Fix kobject memleak in SLUB
Message-ID: <20190428161154.GA13309@kroah.com>
References: <20190427234000.32749-1-tobin@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190427234000.32749-1-tobin@kernel.org>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Apr 28, 2019 at 09:40:00AM +1000, Tobin C. Harding wrote:
> Currently error return from kobject_init_and_add() is not followed by a
> call to kobject_put().  This means there is a memory leak.
> 
> Add call to kobject_put() in error path of kobject_init_and_add().
> 
> Signed-off-by: Tobin C. Harding <tobin@kernel.org>

Reviewed-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>

