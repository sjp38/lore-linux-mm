Return-Path: <SRS0=Hl4p=TW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DBFB8C282CE
	for <linux-mm@archiver.kernel.org>; Wed, 22 May 2019 18:19:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A6D2B216F4
	for <linux-mm@archiver.kernel.org>; Wed, 22 May 2019 18:19:19 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="BWHq6373"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A6D2B216F4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 589836B000D; Wed, 22 May 2019 14:19:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5395F6B000E; Wed, 22 May 2019 14:19:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 44FEA6B0010; Wed, 22 May 2019 14:19:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1CE066B000D
	for <linux-mm@kvack.org>; Wed, 22 May 2019 14:19:19 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id 93so1824407plf.14
        for <linux-mm@kvack.org>; Wed, 22 May 2019 11:19:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=FwWp5RRKikkIIRHUmRqkwRpc7CY4CyqIf4M/5GG0/tk=;
        b=mrnJkbWd+Ph0BuiC/IGOCwC/ESTXxnczbb7nFiNWErCf6AGhrzsMknk5qlxluO1s2q
         1jhY0Wqefn4VuXN5bS08u2Sj3AzXDSC4FAyY6eBM3cw3ZVCe867KiFVBTvwvQHzKUk+z
         NpTlvvbQZ4wDxRqVF08h/od7kYej84l0e+cKYSk61PE6NqQxvlsdFixAq3vQGNjBJEzO
         OfwolyMsob6C04MShzzIkR7Y1qOw2W1Y6j1m50Orw2LeM3l+QfWLGpiHEGxhmLnY4zWV
         OxPsRZAf0P3pfaaJxMfydb+zMF3PyukzkeWwAd2qTa/2sww1S4/7VFtSCQch+rf/sse5
         uWQA==
X-Gm-Message-State: APjAAAVkYm18byMnOnFNtKq8YCGi4K6m5m9hYaSs4/oyFQjPWT361G9T
	qbCqBsswW2bJpIjKZ1wZmH/kaLMf05yN2MAxOx73/kB1IcV1T3sTyCAH4yRBZfUBFK1hKhN4KHB
	Bnfqsbel32kuSlJOhYjxB47tQFCSC5XLkx/W8sv9CAGhiLYoF2FWBZqA2YVtxA+eHrg==
X-Received: by 2002:a63:7d09:: with SMTP id y9mr71136558pgc.350.1558549158777;
        Wed, 22 May 2019 11:19:18 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxe8sSb6oaBeaEjVLX7HH0MJZEFDTrQMOtlokPcHMB+ppGQ3cvKGS8GE2ztdiEOKB+NvYEA
X-Received: by 2002:a63:7d09:: with SMTP id y9mr71136490pgc.350.1558549158028;
        Wed, 22 May 2019 11:19:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558549158; cv=none;
        d=google.com; s=arc-20160816;
        b=U01FnUDCglQGPKZEnGtkyLDbKK2d6w9uwa3fDbhuQ7RlGxGCv3a41D1nUzWxfXSEsN
         /BE5Sg7OniNroVLDqwV8uSt8g6fcG2HlC9Sfe09rCfCrJUCRTEY+fen8YU1dekZysK9h
         YVc3JwhGP7CgzQfWsBMw7LJ3qiQz2kfOQ8SiZ2zachj0echaQlkylO3rCjvL0PJWw6c9
         EY1Y7G0g7O7UsHoVClFHt8QhDWMF4SgnZMb7MgSkwQvilF3J0fWdjkqQbkEtR2KE8xog
         dc08aye+E+Z748W3wCfYfJ5FEmIpgg1N80jUcPx2fBRXfgZNY0EAugf/6EGfMv2xmYTg
         P/oQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=FwWp5RRKikkIIRHUmRqkwRpc7CY4CyqIf4M/5GG0/tk=;
        b=IaR52UM7yqIgaQXTB0xM0URK/z4fInZ0HQthnfA/dfuCG4gnoASRh0q8rP2Wf+b1nC
         pPWW2H04F771ZCCXpX1ZWfj9VgYUMoOAfAV6vSlDxSNpTrCOWUA0/jwtZLaHBVqZ2pWU
         9u4KfdrVut5eE7zz4VAFHE+bFFx+KkLICopL/y06MY9DlFlTkJ28wiekDdcG8XcoDYq7
         Eqx70tdAtqGKriKBC3PmGOYsAac3HhT2kwWumgzIvjNleIVwCH+3YI03nAJx1z3NaG/1
         DngEGxkS2VsVNgCRs/gdYCPw37RN97w1uuhMZnCQzro88E+8Quy/IhSgzjO/YWBth7g7
         JMPQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=BWHq6373;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id f14si19530170pgv.265.2019.05.22.11.19.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 May 2019 11:19:18 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=BWHq6373;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from localhost.localdomain (c-73-223-200-170.hsd1.ca.comcast.net [73.223.200.170])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 30FF92173C;
	Wed, 22 May 2019 18:19:17 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1558549157;
	bh=FwWp5RRKikkIIRHUmRqkwRpc7CY4CyqIf4M/5GG0/tk=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=BWHq6373GnTo8u02TOCLcpwAujfx/Jtic6RHRvtS/cCp1RooT9vzGcrvy7c7N0y8k
	 mmNdKiFe5SB8Da56xeTTokV/wocZWrAIczQslB4vlWePuM9uu8uTnWXaPMpF2JQzaL
	 9OdaA7e1AGMKU7YcbfPO5GIbpgk/ZpmoCqXWEYpU=
Date: Wed, 22 May 2019 11:19:16 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: "Uladzislau Rezki (Sony)" <urezki@gmail.com>
Cc: Roman Gushchin <guro@fb.com>, Michal Hocko <mhocko@suse.com>, Matthew
 Wilcox <willy@infradead.org>, linux-mm@kvack.org, LKML
 <linux-kernel@vger.kernel.org>, Thomas Garnier <thgarnie@google.com>,
 Oleksiy Avramchenko <oleksiy.avramchenko@sonymobile.com>, Steven Rostedt
 <rostedt@goodmis.org>, Joel Fernandes <joelaf@google.com>, Thomas Gleixner
 <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Tejun Heo
 <tj@kernel.org>
Subject: Re: [PATCH 4/4] mm/vmap: move BUG_ON() check to the unlink_va()
Message-Id: <20190522111916.b99a18d67bc76f7cf207d9e6@linux-foundation.org>
In-Reply-To: <20190522150939.24605-4-urezki@gmail.com>
References: <20190522150939.24605-1-urezki@gmail.com>
	<20190522150939.24605-4-urezki@gmail.com>
X-Mailer: Sylpheed 3.5.1 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 22 May 2019 17:09:39 +0200 "Uladzislau Rezki (Sony)" <urezki@gmail.com> wrote:

> Move the BUG_ON()/RB_EMPTY_NODE() check under unlink_va()
> function, it means if an empty node gets freed it is a BUG
> thus is considered as faulty behaviour.

So... this is an expansion of the assertion's coverage?

