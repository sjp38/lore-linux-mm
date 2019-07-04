Return-Path: <SRS0=d6aY=VB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CF4B0C0651F
	for <linux-mm@archiver.kernel.org>; Thu,  4 Jul 2019 19:32:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 96261218A0
	for <linux-mm@archiver.kernel.org>; Thu,  4 Jul 2019 19:32:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="xLYlLoVc"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 96261218A0
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3332E6B0003; Thu,  4 Jul 2019 15:32:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2E5238E0003; Thu,  4 Jul 2019 15:32:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1FA798E0001; Thu,  4 Jul 2019 15:32:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id EF6426B0003
	for <linux-mm@kvack.org>; Thu,  4 Jul 2019 15:32:20 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id t19so4181559pgh.6
        for <linux-mm@kvack.org>; Thu, 04 Jul 2019 12:32:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=sDn9pqNnZNQls6TlQC0E4i4OA5fVIAHZsv1mK7QjuUU=;
        b=og6vO/FX7hp0v+zyX8uLDgwTe4RPzJ2AT4bxXBca1p7Nx43e23vO7FjHt1dgGMyb5t
         wmE1xkCm8cswaj41UoTd3M5pPmhBIitha8R9SsmNyegw3zlFsKIA4aUAyH+okw/bsmFh
         DGQ86J9MUoVzzz3dnQFATs4V2eOiLMPdub/WXlZ7ELy7YLVRoH7pgWp3c2MAInb9oEfo
         fMuAZhajWtfdlz2OexDXZeKH41Bd22Z8x+TbB4/46lGzfhvzHYIggB0ikzvJjRcsGCvk
         nKpjrVm4ZNskUDWsnjfLmFKVMXcCVDAQEbU9g81GjDs0+4syLKb6I1hkVwGB/m6gW1qo
         3obQ==
X-Gm-Message-State: APjAAAUEmR80QYSgdVghOZjzDBSTt7zwsZID8iCcFjZ+QeBaTgjb5adu
	mCksjru5Cx4vDcdOY+7PWxfn4mEI04+K4HrIX7RVj471/Nzhet/ciUhtYXFbBv3+vBcR1DbtO6B
	RuiSR8oAJoRLtXbHsnmLh0BRjPmtYJUlYFFN5ui1923EUBPiriTinCHMsGVM7Ul3FBQ==
X-Received: by 2002:a17:902:4501:: with SMTP id m1mr51221400pld.111.1562268740522;
        Thu, 04 Jul 2019 12:32:20 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxSfEqK/s10MPErbOGxu3lNArRiWs20482cLz1qGtIfEM6LiS1sS1iEYNNX+akS1cMDSuIy
X-Received: by 2002:a17:902:4501:: with SMTP id m1mr51221348pld.111.1562268739866;
        Thu, 04 Jul 2019 12:32:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562268739; cv=none;
        d=google.com; s=arc-20160816;
        b=OKVe2K5bvS3f3JLXxvwZdOPnQBx7ztQlZSjlXUgPZgLdELdg1dNTWRPxaFmRgVOo0K
         wfxYCphr7YNlNr6Y2zPLv8rNqfkEA4u8Jk5cGYhuvKjU4UsO1Srdt7kLHRIesIifBJ1W
         VwQAnuQGKpua56U4tm7qQ7S+sCDeBv/FWbOWgPAyb15Xp5Ix7s06t0nzcf/YIbVDDM55
         eJT1j+hVRAZlyM5ub8e/PU8RvUJlbvNxQ9SezzSm1oe4jkumB/mU+uGurjov970gz3Jw
         rov1adJ2+JabaIJWzFkDB2gtqF6KcXp7kIGGeACzxLnIXZ9p2c/mlj46lHY6/H8g7Q/v
         NvgQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=sDn9pqNnZNQls6TlQC0E4i4OA5fVIAHZsv1mK7QjuUU=;
        b=Ctcc3sbRItS9ldqmdgBfAnWdhnLYxkorwyjq1g/itnXAN+VleJTBHcOVHL8DaaX5nn
         1QZCqln3BtuWwz8sHS6IG5e9Y8Qlvaw6cVPNncGKLzvtISUX9Cq5WLHw3tM107bB3mMZ
         OHPHRWgciCBaOsxbIPQFLMMLd2/TzyAl3JqyVQ8WE//kMqx2HjI3FvRc2Zz2flQ/puVC
         fGn7mOGSCGGqf+ZPxD9LpeNWHHbsyzOUluhTUB//ZyHAxCi4tS3JwN/6Mg1Z12keG3Wc
         b1rrv7Waq0dy9JvTm1G4TDvkMTBMNysvqiSwIaJZ8z1YnIVPJiPYJaLG9kJCcskydJ7Y
         //Rw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=xLYlLoVc;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id i198si6736428pfe.228.2019.07.04.12.32.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Jul 2019 12:32:19 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=xLYlLoVc;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from localhost.localdomain (c-73-223-200-170.hsd1.ca.comcast.net [73.223.200.170])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id D707D2189E;
	Thu,  4 Jul 2019 19:32:18 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1562268739;
	bh=sDn9pqNnZNQls6TlQC0E4i4OA5fVIAHZsv1mK7QjuUU=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=xLYlLoVcNxDZe4xjXUvwx/phI6Gk2I2s1MqHsJnhvK2dhiM5vmmOgxqD3KpPOq1GI
	 YZNDgDS+RHGtv/QAuLWVM4LeZoRGCgQfTba6bUvfTmu8bvT07N8/18ASofU5gvPZM6
	 qTzELQghgD4BvffARvPi77TQK27tSY7dRePWiBGY=
Date: Thu, 4 Jul 2019 12:32:18 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: Qian Cai <cai@lca.pw>, axboe@kernel.dk, hch@lst.de,
 peterz@infradead.org, gkohli@codeaurora.org, mingo@redhat.com,
 linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins
 <hughd@google.com>
Subject: Re: [PATCH] swap_readpage: avoid blk_wake_io_task() if !synchronous
Message-Id: <20190704123218.87a763f771efad158e1b0a89@linux-foundation.org>
In-Reply-To: <20190704160301.GA5956@redhat.com>
References: <1559161526-618-1-git-send-email-cai@lca.pw>
	<20190704160301.GA5956@redhat.com>
X-Mailer: Sylpheed 3.5.1 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 4 Jul 2019 18:03:01 +0200 Oleg Nesterov <oleg@redhat.com> wrote:

> swap_readpage() sets waiter = bio->bi_private even if synchronous = F,
> this means that the caller can get the spurious wakeup after return. This
> can be fatal if blk_wake_io_task() does set_current_state(TASK_RUNNING)
> after the caller does set_special_state(), in the worst case the kernel
> can crash in do_task_dead().

I think we need a Fixes: and a cc:stable here?

IIRC, we're fixing 0619317ff8baa2 ("block: add polled wakeup task helper").

