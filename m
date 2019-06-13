Return-Path: <SRS0=7jwN=UM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.7 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E0981C31E46
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 01:54:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9D2DF21721
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 01:54:53 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="r8JdgWt2"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9D2DF21721
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 441996B0007; Wed, 12 Jun 2019 21:54:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3F1C16B000D; Wed, 12 Jun 2019 21:54:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2E1936B000E; Wed, 12 Jun 2019 21:54:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id E9E246B0007
	for <linux-mm@kvack.org>; Wed, 12 Jun 2019 21:54:52 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id r142so12030088pfc.2
        for <linux-mm@kvack.org>; Wed, 12 Jun 2019 18:54:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=CMz/h9Cg+4Ikv/NNOp10TajaP/65dVUVJmIJWOyAffw=;
        b=ga70ZfLtOiJqYqUJQ/Ic9eow27oTeS7z+Kg9YtbGUXaAk+L363YR3uKdpAvSEooc9N
         TDLwtvG2nATwJYMu/rUCT5F2SQfvZ4JA5wBXKqjaXOl9ZbfmAkZzz/9R3gHMo9B3q6O8
         raX9BQRQ23QgtFxYq/I0FhJXYxwuhfPAl+ALnBMdqQaXaP3ahnXVhGemsENjI1Aycm+0
         otT+86E4Pozbg7oorVnpz4egOg6ttz5nzhIdnprAmyecL4bIxNs+DssaG2BcJgmJGF41
         Yo/JvKdvoBIlxJ6NnfnQkUiCOAubLtQeKCMKnqCOz46SDP3rf7ZcRaNBtULZxb9ocvZF
         uhZg==
X-Gm-Message-State: APjAAAWKjUDsqsNUE/rOrF6EDxLPDo9LpZ+S5mdAnuwfmgJhNQ4VkSfJ
	wnjhwoP3uIy3p8OXsrd3PkUgL3wKuqt4q2kfT4qjkszrXpe24bn3ETf/lnp+elQX6mGsaO0EbaN
	8jVdDMJavzYUcwioi9KutEzoEi/9LoZ876JqnyVPIsnyhV6d2E9YtDTQZVGMqnEU8hg==
X-Received: by 2002:a63:4a1f:: with SMTP id x31mr17822284pga.150.1560390892388;
        Wed, 12 Jun 2019 18:54:52 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwetre6gKLAXX2/HcCECOs8oJbLY80tYfI5+8p0k9HsIoXCP2GgSQfnuXv+fF3kpoZwcE/8
X-Received: by 2002:a63:4a1f:: with SMTP id x31mr17822252pga.150.1560390891521;
        Wed, 12 Jun 2019 18:54:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560390891; cv=none;
        d=google.com; s=arc-20160816;
        b=V6OScP4xCLpPeDTiacPdcFKKVlSmBzLVc1rAoBdjU86kKU5tV41Ny1MTp9AfnmU3Lf
         +pA864Q4/uLB1JolSwNyk5oXCKCAjAtohsPllgP1HUF44YzyFFhhwuDngQJvHKBaZWqC
         zY6da2MhBm1nOfn8CP7QG0xjphAe8RCxtG6rDfMEnb5g1Rd1gZ5iU555DOvHSvO0EfRQ
         0pXqBOsztSZxgzFrrPuXMQHPn6gTvK9l5CHQt24j9Zw+YNJTREp89B9bl13T0LV0Hgfo
         PxdwoorUZHwFRfxmOR3XO3HZutQb8rqhcwoxGT6HyraP/gvdMXngNJ/NMNZ9nnAoeRiG
         zg4g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=CMz/h9Cg+4Ikv/NNOp10TajaP/65dVUVJmIJWOyAffw=;
        b=ely5yqT5ezFeVwXrWzJxI75j6H7hMFpOeUTsqIw37Nzk5UVPsFlozVmZNNR6V/wTL9
         pP3H+38aawK7c/iCHWHno2L1fPheAEahnqkkz4wkr6cI7KaEf+FpFyV9kr7Ana4aYjOc
         F+iaoWoeFebf2calajtUWT2qJClaumD8wnlZUh1bYB4tMuBL/BuE0C9lEdZxotprKADV
         FaWwm3M/ubE9Q25ZLTOtT+SDJg+72oQ219vTKctDHB3XmKFWgsjjXYkDq+q1QwPH8hYH
         rjCqjVMQcOHAcAah990ioEOi1HymdGvX/sMvuXgq3Y8yvOpiWlTZ5JmYl46U5cKP9ULz
         fOsA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=r8JdgWt2;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id j17si1277906pfn.278.2019.06.12.18.54.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Jun 2019 18:54:51 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=r8JdgWt2;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from localhost.localdomain (c-73-223-200-170.hsd1.ca.comcast.net [73.223.200.170])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id A68BF208CA;
	Thu, 13 Jun 2019 01:54:50 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1560390891;
	bh=GXivTwKQk8Y+X5xE03CN8fthnLjjz3AlLtUYgE6QieY=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=r8JdgWt24mLYxAVnydiRtAdlx+xRwCOlsBeGXcMQy1oJV3B/cDxN+OnDejmpSyIV6
	 RcIibyipNA+YGPuxHDsGF+U/AKFps7DbsQDuq1Fpc/BUfIrexokv2IP71eCmwXk283
	 fI0rscTQw/skUc8NwPguKxlABRXZDgasoljgBWxA=
Date: Wed, 12 Jun 2019 18:54:50 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: David Hildenbrand <david@redhat.com>
Cc: Anshuman Khandual <anshuman.khandual@arm.com>, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
 catalin.marinas@arm.com, will.deacon@arm.com, ard.biesheuvel@arm.com,
 osalvador@suse.de, mhocko@suse.com, mark.rutland@arm.com
Subject: Re: [PATCH V5 - Rebased] mm/hotplug: Reorder
 memblock_[free|remove]() calls in try_remove_memory()
Message-Id: <20190612185450.73841b9f5af3a4189de6f910@linux-foundation.org>
In-Reply-To: <67f5c5ad-d753-77d8-8746-96cf4746b3e0@redhat.com>
References: <36e0126f-e2d1-239c-71f3-91125a49e019@redhat.com>
	<1560252373-3230-1-git-send-email-anshuman.khandual@arm.com>
	<20190611151908.cdd6b73fd17fda09b1b3b65b@linux-foundation.org>
	<5b4f1f19-2f8d-9b8f-4240-7b728952b6fe@arm.com>
	<67f5c5ad-d753-77d8-8746-96cf4746b3e0@redhat.com>
X-Mailer: Sylpheed 3.5.1 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 12 Jun 2019 08:53:33 +0200 David Hildenbrand <david@redhat.com> wrote:

> >>> ...
> >>>
> >>>
> >>> - Rebased on linux-next (next-20190611)
> >>
> >> Yet the patch you've prepared is designed for 5.3.  Was that
> >> deliberate, or should we be targeting earlier kernels?
> > 
> > It was deliberate for 5.3 as a preparation for upcoming reworked arm64 hot-remove.
> > 
> 
> We should probably add to the patch description something like "This is
> a preparation for arm64 memory hotremove. The described issue is not
> relevant on other architectures."

Please.  And is there any reason to merge it separately?  Can it be
[patch 1/3] in the "arm64/mm: Enable memory hot remove" series?

