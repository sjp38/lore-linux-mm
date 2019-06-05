Return-Path: <SRS0=9Pd6=UE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	T_DKIMWL_WL_HIGH,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0189AC28CC5
	for <linux-mm@archiver.kernel.org>; Wed,  5 Jun 2019 04:14:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9ACF920866
	for <linux-mm@archiver.kernel.org>; Wed,  5 Jun 2019 04:14:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="2YKq0Ebk"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9ACF920866
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 20C036B000E; Wed,  5 Jun 2019 00:14:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 196536B0010; Wed,  5 Jun 2019 00:14:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 037576B0266; Wed,  5 Jun 2019 00:14:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id C8F6E6B000E
	for <linux-mm@kvack.org>; Wed,  5 Jun 2019 00:14:20 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id x63so9108344pfx.22
        for <linux-mm@kvack.org>; Tue, 04 Jun 2019 21:14:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=2B/B0prAKkIbjLIXSxxyPuwJGhJKz6fYqry9vA7T2YQ=;
        b=F2HW0B641Oz9U+IYubUofW8BUaBrgRAxpj9dxB0GKJlqBg0+l4HA1Ao0Y3bsxP1P4e
         O0AY09hOGiDiym3ohbcNN1pA2/z7g4gmxqQI4bnSFa2JXUmoESHZeQsutbmlj02SePtY
         FDQJpOCYN/JeDIv0xnoLwKvSzHUQwlO3CQL9KsLv9T64MBJGWoDEOQwZCZ0OnIVo4iS8
         rZIgDK/rJjZNpveUX6mvY5X0/BChoxbI7FAHCTRMCl2IrzwpOtpyc6DQhd6HAC7odNen
         QmtEHod8MLPgNzR1hPVQjWOgAMx1EWkwxeitAIs/sXeSbT8CNeHkCCPktiRDFQ1nROwj
         V6DA==
X-Gm-Message-State: APjAAAW38nBDlysevoylb4ChYeJtiq+yoe5+9ABLgnp+8ab9lZK0lm9S
	8MRkPJJ6wpzgf9QMrOaQ3EruVMWSTXAG81jbHfcGdQxuMO8IFrxSUNR/nxn4VmbmY90zlK/kdNM
	JyPRpxa0iI7LCV0T78hcXWBCGGvBm6IP6RGQxIVE2iTODON6xPq4MeUrvpCS8jxH4hQ==
X-Received: by 2002:a17:90a:8e86:: with SMTP id f6mr40560581pjo.66.1559708060279;
        Tue, 04 Jun 2019 21:14:20 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwE03gweQLmzDX/L5vdrUYVJkHnP8VVL6BtLSs0Fc/q6VwOW15PzAs88vBQbDrzHlF+yVlo
X-Received: by 2002:a17:90a:8e86:: with SMTP id f6mr40560480pjo.66.1559708059341;
        Tue, 04 Jun 2019 21:14:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559708059; cv=none;
        d=google.com; s=arc-20160816;
        b=WU+ZETSF1Uxb664d0J/yYIpRf35QY4wArJHunsbROKy8bSzmR4Y+/Zpi4b3Zeq888j
         EECyljjHjX4DCv547uvUwNnAVB9LsNTLx8KtrzbKnGaWV8r6KlyJqG27AnzbLEp6HmbO
         6SvbXf5EPMUIWI8p5Oxrz55PZUmZFYJ16xyTqJCCVaWqmuWPfeOZgcj0RwgHcBXxdMeB
         sGob+ZsapoQWJhquGIn7Ppa5IMgTC9nlrCN9mkIsODEQd5TLgByC9w5H/Dyk59sg1bja
         mpKASkS9raGbdSYPXXlkmGthG4sWRIkRcDkY0cv0d1dAimyhqm2616Uog3vUMZKsLsZr
         Dkww==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=2B/B0prAKkIbjLIXSxxyPuwJGhJKz6fYqry9vA7T2YQ=;
        b=W/nalHXpvguY99WEoPtq1Ucl3rOEJehslC9/oZgwVzsiiL5deHl2hsXrf120guVM95
         ZEDLXW8mmaKUtou6C1Pa+gCsOqP0myr4qbO/qQgvrbAXIYEZTAcmlW/aE57OSgZpkE1B
         lvzsC/XheGJj2ZdL95zKAqf8M8UupLELEoofuNRLIz7aKWycp+Kh1CAR2GtpQy2WZ39O
         ProlOmyAQorT0zshnwuZX3MysM1aI0gTXVsHzwzvMxTtLoikBOtirZbdevC+f4XggoeL
         4eVSPc8Lp5G4mPfS0ZafjMk1Sui3AnyUrCRIS1XWsAPFqyHTEC9lMguK9tB+i/By3t07
         a+iQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=2YKq0Ebk;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id y16si4449658pfm.236.2019.06.04.21.14.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Jun 2019 21:14:19 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=2YKq0Ebk;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from localhost.localdomain (c-73-231-172-41.hsd1.ca.comcast.net [73.231.172.41])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 8AA582083E;
	Wed,  5 Jun 2019 04:14:18 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1559708058;
	bh=edj9xHB7N4qyQuNAjukxlep6ykAdTpTJSbDVobW9eyE=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=2YKq0Ebk1+cB6qr58E9NAgemhGn6EHb0HDouxp1tY+7raXsMRSeotQrm+P5lIPs1v
	 L6mN1jBg0wqjF15WZC+qr2bLNQOb6kr4HaRV+v0csG/ttAlC9TpwLb3UFcUAR0mm1f
	 QiE+/S8AFSkUzLizIkatXvaSNq3NKDwY8kGiTTn8=
Date: Tue, 4 Jun 2019 21:14:18 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Roman Gushchin <guro@fb.com>
Cc: <linux-mm@kvack.org>, <linux-kernel@vger.kernel.org>,
 <kernel-team@fb.com>, Johannes Weiner <hannes@cmpxchg.org>, Shakeel Butt
 <shakeelb@google.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Waiman
 Long <longman@redhat.com>
Subject: Re: [PATCH v6 00/10] mm: reparent slab memory on cgroup removal
Message-Id: <20190604211418.70d178253550d96da46cee21@linux-foundation.org>
In-Reply-To: <20190605024454.1393507-1-guro@fb.com>
References: <20190605024454.1393507-1-guro@fb.com>
X-Mailer: Sylpheed 3.5.1 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 4 Jun 2019 19:44:44 -0700 Roman Gushchin <guro@fb.com> wrote:

> So instead of trying to find a maybe non-existing balance, let's do reparent
> the accounted slabs to the parent cgroup on cgroup removal.

s/slabs/slab caches/.  Take more care with the terminology, please...

> There is a bonus: currently we do release empty kmem_caches on cgroup
> removal, however all other are waiting for the releasing of the memory cgroup.
> These refactorings allow kmem_caches to be released as soon as they
> become inactive and free.

Unclear.

s/All other/releasing of all non-empty slab caches depends upon the releasing/

I think?

