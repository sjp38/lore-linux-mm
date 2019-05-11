Return-Path: <SRS0=ybLw=TL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2A5CFC04AB1
	for <linux-mm@archiver.kernel.org>; Sat, 11 May 2019 23:29:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D4CC52184B
	for <linux-mm@archiver.kernel.org>; Sat, 11 May 2019 23:29:00 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="nU6413kV"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D4CC52184B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 653316B0003; Sat, 11 May 2019 19:29:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6037C6B0005; Sat, 11 May 2019 19:29:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 51A466B0006; Sat, 11 May 2019 19:29:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1B1306B0003
	for <linux-mm@kvack.org>; Sat, 11 May 2019 19:29:00 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id f1so6858975pfb.0
        for <linux-mm@kvack.org>; Sat, 11 May 2019 16:29:00 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=es864z3d4LIjwNS1NE+AwOG5dicN2shdSWnMht9wQZw=;
        b=OSFVlcEYg4R3MIYy4skvdgc0ljyvyqE4IS5FHcZtJnNbBCGkUQ1xrJXEEmYzIDDQjQ
         V53OJAg3VR/xe8htBWTW618tTi9gWGHrkvkJMoX9Qt8lFp3YW70KW0ygw2WG0l2Iil/c
         Bf0fYSmm0Hgb8QePxjag90uxedTvAkcxhQ7RvWAkmz8s1hcbEYTr0uxQvT7a39boaE4A
         8pimy6sjsffixqMzApUfJjNNV3n5ZGGtW30hNI5yTmSfSevGKzHMdMoi7ZiGTOWWpArv
         Cas4uTr7Ipd2HrBDl3xgbAS+k0dudPGkXddY+2K5pw71zvWuZmvipXBGshHdIVCUhw2E
         5l9A==
X-Gm-Message-State: APjAAAU9QGfrsCugc/5aQMRvO7sb9UrVrcmm1wbH88vikyrcpMS+UEmL
	HE0CdOwueMbxclLwxqvp+CXDsvx2l9l+66dy7zwDufQZ6lfKsjTlXPI2EAZfIM2mLuwpYLUKt9a
	+MU2Z4RXOZaP1tmQBq8wTIc2j5SORdqNMBBUSIwWEKjK4HmSGQvap0hvCF3SZEcnlIQ==
X-Received: by 2002:a17:902:e48d:: with SMTP id cj13mr22604360plb.156.1557617339556;
        Sat, 11 May 2019 16:28:59 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzk8PtQUQr7QrTXJ/kmMwH+BVPtW+v6Gaj308zNEAE42SQ1f9x7ydqzc1Xpgdh+gx0qswlG
X-Received: by 2002:a17:902:e48d:: with SMTP id cj13mr22604302plb.156.1557617338608;
        Sat, 11 May 2019 16:28:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557617338; cv=none;
        d=google.com; s=arc-20160816;
        b=QZL+EIjLEI3CbR1Le2sm+Zq47S3pWVhCuRS49HdrmuzeBav24LCV7QxstnQv0XhfYs
         fUi67ojt25eTdNW7Iol214Xq1zAI1APVMrKOYp/g7PXjyDh5hZdhuYjxof0+WkBDZjqc
         ciNOThsYhavNszQT6G7np7tiRgoQ3EgNHU86v1epeUSoT/mflRSjZlxR7a937Yl2vZEs
         6UgXIuh3iz/QaGt+QtLpnPkBihdXI1FGVA089Var2M6PaVvqTuyLsROAxncei0PWkGpr
         /NiV0cWdyhQtScdrkw519Nvd5bdTrGwxZ+TqWLwbZRj1MUydmwzC4aCuLuFSy5rt7jie
         e3fg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=es864z3d4LIjwNS1NE+AwOG5dicN2shdSWnMht9wQZw=;
        b=jjmL0zp7dmRJZ8JR9Tr2J4HXtrIZliSsGKcRbvd8ViqeyoN/Xy3ulI7CMNgQnsGx0q
         0M1f3E26Undl1ussJIut5I/JuQsh6Hnnr/mFGemVHpmvAYdK4j3VLkYOLgPHg/ez20Na
         lybEouPEIKnMGBxlfkePnbaOAe7hR0dITrbsepN6bEubpeG7PaJP8CQ/l8917kvrhOVH
         aVNF+XguEyV/koAfEHcF+TDupyjq2PkOse2HN3ogO5T9ph8u0SvgSM1B3pQU7rqOfzIe
         0cAot9fB0NgKQbedYmVcosaT0izeXEi/5XLiuyMfTzCDAdOursFB5gWho/L439VC3Ove
         ncKQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=nU6413kV;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id c22si12194133pfr.15.2019.05.11.16.28.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 11 May 2019 16:28:58 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=nU6413kV;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from localhost.localdomain (c-73-223-200-170.hsd1.ca.comcast.net [73.223.200.170])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id E07EA2183F;
	Sat, 11 May 2019 23:28:57 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1557617338;
	bh=BHuLhxI5aHGVG83YqK2/hCHQq9kJO+FuJp6SI28BFfI=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=nU6413kVDb+PIGWHElsfQ6tapvlj2bCz/1bmMGpNgUPeXxkuwKNe3Dy0uTFp1NVY8
	 oCufa71IzIzaWeO/VIMqQoTq+iMdsqzx/TsBpN8ie3xb6RkIk7GGM5lGedl+Hb2ar0
	 7aa1ZW3Ce8KqrZFOGYDQ5AU7/0gQmNKz5IGJ7VEw=
Date: Sat, 11 May 2019 16:28:57 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Michal Hocko <mhocko@suse.com>
Cc: Yafang Shao <laoar.shao@gmail.com>, jack@suse.cz, linux-mm@kvack.org,
 shaoyafang@didiglobal.com
Subject: Re: [PATCH] mm/page-writeback: introduce tracepoint for
 wait_on_page_writeback
Message-Id: <20190511162857.12e08e792b32d9cff1fb630a@linux-foundation.org>
In-Reply-To: <20190428210538.GB956@dhcp22.suse.cz>
References: <1556274402-19018-1-git-send-email-laoar.shao@gmail.com>
	<20190426112542.bf1cd9fe8e9ed7a659642643@linux-foundation.org>
	<20190428210538.GB956@dhcp22.suse.cz>
X-Mailer: Sylpheed 3.5.1 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 28 Apr 2019 23:05:38 +0200 Michal Hocko <mhocko@suse.com> wrote:

> On Fri 26-04-19 11:25:42, Andrew Morton wrote:
> > On Fri, 26 Apr 2019 18:26:42 +0800 Yafang Shao <laoar.shao@gmail.com> wrote:
> [...]
> > > +/*
> > > + * Wait for a page to complete writeback
> > > + */
> > > +void wait_on_page_writeback(struct page *page)
> > > +{
> > > +	if (PageWriteback(page)) {
> > > +		trace_wait_on_page_writeback(page, page_mapping(page));
> > > +		wait_on_page_bit(page, PG_writeback);
> > > +	}
> > > +}
> > > +EXPORT_SYMBOL_GPL(wait_on_page_writeback);
> > 
> > But this is a stealth change to the wait_on_page_writeback() licensing.
> 
> Why do we have to put that out of line in the first place?

Seems like a good thing to do from a size and icache-footprint POV. 
wait_on_page_writeback() has a ton of callsites and the allmodconfig
out-of-line version is around 600 bytes of code (gack).

> Btw. wait_on_page_bit is EXPORT_SYMBOL...

OK, I'll leave wait_on_page_writeback() as EXPROT_SYMBOL().

