Return-Path: <SRS0=+T2N=VO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F1E7EC76195
	for <linux-mm@archiver.kernel.org>; Wed, 17 Jul 2019 21:58:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B4FE321850
	for <linux-mm@archiver.kernel.org>; Wed, 17 Jul 2019 21:58:37 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="1fdC9jpg"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B4FE321850
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4D8EA6B0005; Wed, 17 Jul 2019 17:58:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 488946B0006; Wed, 17 Jul 2019 17:58:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 378138E0001; Wed, 17 Jul 2019 17:58:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 043096B0005
	for <linux-mm@kvack.org>; Wed, 17 Jul 2019 17:58:37 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id 6so15277975pfi.6
        for <linux-mm@kvack.org>; Wed, 17 Jul 2019 14:58:36 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=6Dp9jOPV7rxxzUI4MbHMYjvFKA0IpSXRSjtmBJ96fag=;
        b=cmxNMrELQney/guoZdxlFOKi6kmRgcRQ0ApCjAvjfOBm++XvYJEecAPTqfrocZtWdL
         D8o02wTUYBp7y24rbcpIvwkp/Cbo+t3Y2U04thwkWha+dNbPbL3bg3ehEVjJ9xQByf+9
         nl1dBjwUfb3S+jS0cO9jhAeyvBvTdy560FapU6oFxAF1vLc/vQcqmAJT0358XCcXupU2
         E3CU2zoSJ+p3keoNPMm0UgoxnY1jhMSHS0YLc1HbwnzGbCyTmtjQB9G8db7eJTrbXJ3j
         uVcBQ7gxwoiSB0uLcsDBQURk/VEEnOzY4S39pVg3dPZ4wORGILtMnD/UsaTm3cNwxcze
         UudQ==
X-Gm-Message-State: APjAAAUBos7w9s1K9VmJXv8tgbVSa8QSJ7C56JDo3Mdq0Nh7e/NuzcEg
	bT9Zfu5jpczLJkwPDr0fYsh6993TVmILNBnjbKCE833x+w7R73ow/3ARVyNLKuADRlLj7qtblqT
	eGlrzfr09TFSMAFo98koqaZ9keOO2y0w08G054ZjKRknnXq1ZJxGGmQAOkcAaBUUdPg==
X-Received: by 2002:a17:902:b608:: with SMTP id b8mr46502597pls.303.1563400716554;
        Wed, 17 Jul 2019 14:58:36 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwJyOehYRj2KzT3Zmzwa4EPTQ8YJb8rk4/BticHHL4hSexcYsbSYMEAOzduUVI/7lxdKBSV
X-Received: by 2002:a17:902:b608:: with SMTP id b8mr46502563pls.303.1563400715894;
        Wed, 17 Jul 2019 14:58:35 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563400715; cv=none;
        d=google.com; s=arc-20160816;
        b=iN9h39CJ/cDDvez3+GOBMZ2edYnMF01TjDn0ZvMSX4GDqAluVCl1iazXWHpfSgnXUf
         ALrt4iUBQCp3BB/FHFnnRPo/ZOpeMkWblOlQsVsx+bdN85wAOSSt+Q0VKq0Hz26TgrfN
         bD4HIbFinEbNdqwhBfC6pPoynXwbNxR51/B9nwktOAnpza8PLvZNZ7SnBIaJH67j/plL
         8aq0jSmqBg9Ye32z8Bi5t2yOaYuRp16+6oRfm0jqrDl1hQfaWJ8viQigVhez+e4HD9gg
         PztjTn9RAIMpCHzkHtK9yDl5kQC2EnQSz2N3LoKXe+uOs8mZOAk7tu8WpE6TaL7ICvgD
         eU9w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=6Dp9jOPV7rxxzUI4MbHMYjvFKA0IpSXRSjtmBJ96fag=;
        b=VopmhwZCnPCvXMomfpha3N5yVg1TYAs+Rw29MasazotLi5KePRb1DbZq/T038a8nT4
         717d2Lb9+45Mb9eJxbimIvgPtHl0ZyVHthM+XzROGdSr9TU5BqeXiJaGuhuSJa1ijS8b
         wa/RG7WbZp6Ot5lynlDr74jLaLsw1Ek23BnXFij77+6A/Y6gPlVQd3QhsiNgpT3/+kPn
         /MJzDeIs+70ytcy5i3ET6Z32vFnNtsghLJAGnem2v67qkDTcTBiWwsLirgqmEExKfwWs
         mweKZp/3MxYiocrHeQWGDN38auzUIVdBT+ZY8FjXpG6KC7x+WT1FDZBAMbI2vVdPWg+D
         8WpQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=1fdC9jpg;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id k10si8737234pjw.1.2019.07.17.14.58.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Jul 2019 14:58:35 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=1fdC9jpg;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from localhost.localdomain (c-73-231-172-41.hsd1.ca.comcast.net [73.231.172.41])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 1530121849;
	Wed, 17 Jul 2019 21:58:35 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1563400715;
	bh=AVPhuQRO0imI6YrRXaqcsADJ5D+m0LchIU7hp9OgbjI=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=1fdC9jpgdyHwO7OXjIber/c3MPrHN9zcddL/xG+2Je6BtgqOnBCfIhwCHrhabudU+
	 U3uBHdRGGGc2+F+eTCnoXGMDoxckOzaMY/2F/jju5l+mnAlye3jwU26j8DsQ2+C0ps
	 vJ72kl6qTS/E0vA2fJhA7zhh6yW4tDBzFWF9gU6c=
Date: Wed, 17 Jul 2019 14:58:34 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Randy Dunlap <rdunlap@infradead.org>
Cc: Stephen Rothwell <sfr@canb.auug.org.au>, broonie@kernel.org,
 mhocko@suse.cz, linux-next@vger.kernel.org, linux-fsdevel@vger.kernel.org,
 linux-mm@kvack.org, linux-kernel@vger.kernel.org,
 mm-commits@vger.kernel.org
Subject: Re: mmotm 2019-07-16-17-14 uploaded
Message-Id: <20190717145834.1cb98d9987a63602a441f136@linux-foundation.org>
In-Reply-To: <a1179bac-204d-110e-327f-845e9b09a7ab@infradead.org>
References: <20190717001534.83sL1%akpm@linux-foundation.org>
	<8165e113-6da1-c4c0-69eb-37b2d63ceed9@infradead.org>
	<20190717143830.7f7c3097@canb.auug.org.au>
	<a9d0f937-ef61-1d25-f539-96a20b7f8037@infradead.org>
	<072ca048-493c-a079-f931-17517663bc09@infradead.org>
	<20190717180424.320fecea@canb.auug.org.au>
	<a1179bac-204d-110e-327f-845e9b09a7ab@infradead.org>
X-Mailer: Sylpheed 3.5.1 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 17 Jul 2019 07:55:57 -0700 Randy Dunlap <rdunlap@infradead.org> wrote:

> On 7/17/19 1:04 AM, Stephen Rothwell wrote:
> > Hi Randy,
> > 
> > On Tue, 16 Jul 2019 23:21:48 -0700 Randy Dunlap <rdunlap@infradead.org> wrote:
> >>
> >> drivers/dma-buf/dma-buf.c:
> >> <<<<<<< HEAD
> >> =======
> >> #include <linux/pseudo_fs.h>
> >>>>>>>>> linux-next/akpm-base  
> > 
> > I can't imagine what went wrong, but you can stop now :-)
> > 
> > $ grep '<<< HEAD' linux-next.patch | wc -l
> > 1473
> 
> Yes, I did the grep also, decided to give up.

I forgot to fix all those :(

iirc they're usually caused by people merging a patch into mainline
which differs from the version they had in -next.

