Return-Path: <SRS0=80m6=VT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 72D87C76195
	for <linux-mm@archiver.kernel.org>; Mon, 22 Jul 2019 09:38:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3B29C218EA
	for <linux-mm@archiver.kernel.org>; Mon, 22 Jul 2019 09:38:30 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3B29C218EA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DFFBC6B0266; Mon, 22 Jul 2019 05:38:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D88566B0269; Mon, 22 Jul 2019 05:38:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C50CB6B026A; Mon, 22 Jul 2019 05:38:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f69.google.com (mail-wm1-f69.google.com [209.85.128.69])
	by kanga.kvack.org (Postfix) with ESMTP id 770BF6B0266
	for <linux-mm@kvack.org>; Mon, 22 Jul 2019 05:38:29 -0400 (EDT)
Received: by mail-wm1-f69.google.com with SMTP id y130so8787608wmg.1
        for <linux-mm@kvack.org>; Mon, 22 Jul 2019 02:38:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=CJjf272c4QCg9mLbCqQ0djpoW3m6zPXzbl+Z7jgLL7s=;
        b=I6Z6W1RsSF7VywK4MyeqFrCDEpLFVJ/HSEfxHTCjKg/VDR56M00/q5dZy654MLs54+
         WejtfyRcOqOxFWGl6n7apZiEqRbSJ+eB25DtHWi+IGDHmYg+9iFgVF8nvDd8niH59vks
         6wLOEkV2501RRI61LDOQfwY/8Kf/7CczW3X7/nwpWzm3SlXAW+sMSnJxCo/vfXwnwchz
         aEqZCd1axge/WOcfu40S2jgbOZTuE+MxHBBuI7NpLn2MSGW9tyqNnN+dIxe9rNdq90rn
         UL8DPreIumGTL86naNrMINA/O9oz89lu+FT7CS5PEq2FrVYEPhRs5e2GNhfU4FYvEI8Y
         +iMg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
X-Gm-Message-State: APjAAAXOTeKG4yoT/1DM9KPEEsLieJ+D60vgynJ02OU/CouUyl+A8+Ow
	0S2WsGL6/9T8mrTQq6Ctktlmvx2MTz/0hr/ogGXHV3yaXrBDV8Mfsf2bbqMTo1bEHgD5Fxz8N9R
	Mhy/ZLkmjL+68Z28GZllj66NlL26zvfBwHG//oZChPRfYjB8Q6gUmfVeyenNMN8vBHw==
X-Received: by 2002:adf:e6c5:: with SMTP id y5mr77061219wrm.235.1563788309029;
        Mon, 22 Jul 2019 02:38:29 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxAwbyRgs2VFGI7GAsbeEv0SEcSU7M3f7Gx7fVw4Wx6pHBVjbzW3bEow3NUH/NnoLYpC2KE
X-Received: by 2002:adf:e6c5:: with SMTP id y5mr77060478wrm.235.1563788303581;
        Mon, 22 Jul 2019 02:38:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563788303; cv=none;
        d=google.com; s=arc-20160816;
        b=gbtsz3AKldPO6rbZqSO3s8OxYMfBjFOIY4FaWWWi3R3hw0E7NWLWkbjd5ePWKIIkad
         kj3yIje37BvTRUfFwFXjDGF55feI/CT9/E16UCfuBN3lK3i2mhjnQVjAldult4/o5k2j
         1QjavVZo8OI0+mFguaOBZJlVbg1pd66U4RIqnHzg295KnI1gRin56OzQcSX1aUL0tGnK
         WXBXcxvj6Mshf9SA2ebn2UHnAuj6xM4US5VD4FoducAiKvPooobcjL4ZU+mKwMPTDrxo
         e/fX7wr1uzKDaJyIQMcZq+HutSrIMBgCqq7NuLF4orSIvrlWs6BQvbl0qnTKe03Vd+E6
         5qmg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=CJjf272c4QCg9mLbCqQ0djpoW3m6zPXzbl+Z7jgLL7s=;
        b=o/6xGKAB9CRbKPpuVfAGG7KvNOI4B+QlUfrRlPDxSHoo14gdv5jftYhy1aqKYkyiqm
         Eb4rL4UBUfMEJFGwKYqMm3eHwXD8O092jkS2QfnEhjAf3eTLTbgxYSjcmSmsE6zP1K7A
         O5In+jXaGLsJICkjrcf82Pd87zJMEjsBw3TzudJv2PNOIHFgUTRqbvmH2yAWlb93QwuE
         Zm/0K2nACRtXX9SZv9KSoY2uMfmf33WpHcodn/UI5bXEXAHKAtiQ+/5HeyR+l2i27cXn
         zGUqyc20EWGWZ73MyLMsVbmCbCRt1ayeLE7sY4fdCoRV2AAxhk2EOT9n3qe6ZpvXHPVb
         ukeg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: from verein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id v19si20481098wrd.29.2019.07.22.02.38.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Jul 2019 02:38:23 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) client-ip=213.95.11.211;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: by verein.lst.de (Postfix, from userid 2407)
	id 1925268C4E; Mon, 22 Jul 2019 11:38:23 +0200 (CEST)
Date: Mon, 22 Jul 2019 11:38:22 +0200
From: Christoph Hellwig <hch@lst.de>
To: Ralph Campbell <rcampbell@nvidia.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	stable@vger.kernel.org, Christoph Hellwig <hch@lst.de>,
	Dan Williams <dan.j.williams@intel.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Jason Gunthorpe <jgg@mellanox.com>,
	Logan Gunthorpe <logang@deltatee.com>,
	Ira Weiny <ira.weiny@intel.com>,
	Matthew Wilcox <willy@infradead.org>,
	Mel Gorman <mgorman@techsingularity.net>, Jan Kara <jack@suse.cz>,
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
	Michal Hocko <mhocko@suse.com>,
	Andrea Arcangeli <aarcange@redhat.com>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>
Subject: Re: [PATCH v2 2/3] mm/hmm: fix ZONE_DEVICE anon page mapping reuse
Message-ID: <20190722093822.GF29538@lst.de>
References: <20190719192955.30462-1-rcampbell@nvidia.com> <20190719192955.30462-3-rcampbell@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190719192955.30462-3-rcampbell@nvidia.com>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

> +		/*
> +		 * When a device_private page is freed, the page->mapping field
> +		 * may still contain a (stale) mapping value. For example, the
> +		 * lower bits of page->mapping may still identify the page as
> +		 * an anonymous page. Ultimately, this entire field is just
> +		 * stale and wrong, and it will cause errors if not cleared.
> +		 * One example is:
> +		 *
> +		 *  migrate_vma_pages()
> +		 *    migrate_vma_insert_page()
> +		 *      page_add_new_anon_rmap()
> +		 *        __page_set_anon_rmap()
> +		 *          ...checks page->mapping, via PageAnon(page) call,
> +		 *            and incorrectly concludes that the page is an
> +		 *            anonymous page. Therefore, it incorrectly,
> +		 *            silently fails to set up the new anon rmap.
> +		 *
> +		 * For other types of ZONE_DEVICE pages, migration is either
> +		 * handled differently or not done at all, so there is no need
> +		 * to clear page->mapping.
> +		 */
> +		if (is_device_private_page(page))
> +			page->mapping = NULL;
> +

Thanks, especially for the long comment.

Reviewed-by: Christoph Hellwig <hch@lst.de>

