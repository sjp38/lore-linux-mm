Return-Path: <SRS0=1HZa=QY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 16AB5C4360F
	for <linux-mm@archiver.kernel.org>; Sun, 17 Feb 2019 11:29:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id ABDD1222EB
	for <linux-mm@archiver.kernel.org>; Sun, 17 Feb 2019 11:29:49 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="bILEhpIU"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org ABDD1222EB
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1FF8C8E0002; Sun, 17 Feb 2019 06:29:49 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1D8968E0001; Sun, 17 Feb 2019 06:29:49 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 09ED48E0002; Sun, 17 Feb 2019 06:29:49 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id BF55E8E0001
	for <linux-mm@kvack.org>; Sun, 17 Feb 2019 06:29:48 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id 71so10426351plf.19
        for <linux-mm@kvack.org>; Sun, 17 Feb 2019 03:29:48 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=rXiUAXlA4Y4NVU1+nGtiu2iiqqDtjUNA9mpoGknFqWQ=;
        b=I4IqNv21pDkNZbbs8fX1V6gky7mCFlXKIsxtH4v2bhLvA3zf2Dqkg1n3x4xCOeVy7I
         2KiX3PByV0QT6VH61trKWI0qrE4z6FLKybMMF5wPNkMkinEetrjE2IHeXh9YlPNcM77a
         02s4dCObY6UmPTWaELMcSj3wNwI2uAGuFOK9CAgc1VEiWGnGx6jHSRJoYBWfMp9jfN+O
         I49sXl1bYBsU6q+iF+fuWGcRI/fOD72rF5u1mG9lzDruG4TvI0vuuqYmKoTpS8tuUowh
         IblbZB88GfYuCU4t85DX0gSbs6NH9K3fq7wfd8SSIBsuX8AKcVLpP6RbzZ4emEEqN/6h
         VLJQ==
X-Gm-Message-State: AHQUAuYU/dqYLS7vjh8+6qXgPDoTM7jJmXv4OcsyuFLYa6V4JQ9H1Ylr
	T7MDHtRG9ywa1UPYUwfIZygrVkxkd+DTMr4x8NnbrkOM0A+m1uHmK1Iq2odqmJxsAXxHJ8BGEWp
	XMOCJZrXhwc+8otOpiLziTZtBeS/wTuMHOfK/hanzt47BMRx9d0AlQMYO7W07sODOIg==
X-Received: by 2002:a17:902:8e8b:: with SMTP id bg11mr19992928plb.332.1550402988388;
        Sun, 17 Feb 2019 03:29:48 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZePMxz491X4q1eGX6Uog0FonnoEGuTruH+L0aaOxw8Ot23gxkZr+/92EZ4fsid+XG4lO6L
X-Received: by 2002:a17:902:8e8b:: with SMTP id bg11mr19992877plb.332.1550402987593;
        Sun, 17 Feb 2019 03:29:47 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550402987; cv=none;
        d=google.com; s=arc-20160816;
        b=VbSjzUOF0W3yUCAXxC7p4moPjsFD1HcS3Xwf5cFSkT6PTW+nzc4c88d6rdNpa+7MgW
         PUzfKP+7Y9oljD4UblQ1yh4BWF5Y9YnslOPt+Ii2xISvhyf0SMRYdbFndmZvmLbMG7uz
         nNve0A/WMuqInVSwG41c99wevplBjBR+X8P/TBn3suRHEFqal/r4CI7gFaLf1qyk4yY7
         Qh2K9TXCPzaZtUrwRZHP6MSRykElM1T4vQUZnJVutMDWPc9D/uFYzFmBjy1nHmzhOxe+
         n/FA860ZbXcadic81hhdHAcOO0A+S98z39Rud12escVS8M7T/SVYkUda2LutAfSrcLc6
         /b8A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=rXiUAXlA4Y4NVU1+nGtiu2iiqqDtjUNA9mpoGknFqWQ=;
        b=R8c8ADE0e+SgSLMCQFjmZqihl6CwfMUxPLfhzOQqIwicBDCP/C4b1YYCwIVV0dQmc5
         UyrKxbnxqyvz8qzZh8SbyinNa2GdwuZZxp93W+8ID/iU9KV5xrBSCDm9Y097UJbOUQIl
         xzRSufWYWTgaaxVle5stqdTQolIE7EaT2b5Pr3asUb9vU37O/llP8HBGm2m8asLG5hns
         KwOedy0KAKbW3lGFsHwjhh5sYuoMWx+ugCOEURd5XMY1un4qfxpt0EPucMlXeis6Z423
         AlDFbCOkyYf/oCK5WTQXfLNmlDS9daC8FLhK5hTdSilSR0+YbWN/NH/M9VXDkK3h+DnR
         UjyQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=bILEhpIU;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id z3si4755623pgr.90.2019.02.17.03.29.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 17 Feb 2019 03:29:47 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=bILEhpIU;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=rXiUAXlA4Y4NVU1+nGtiu2iiqqDtjUNA9mpoGknFqWQ=; b=bILEhpIUWBFNWSR42Wf71Z99F
	AhGCHBIy/mlttSXoA1pWjgcAeH3AhOiAeg0yN7/YCU8hODtO/MYWkwW0jN/dbsttWYCYg3QuC8CFF
	uCeaspFD090sg7VcupXePFXHnDcCkLYG1gNKy/QtXP5MiPgpr6fFck+BRYN/69StopET93VAeQFFt
	3+2iDoxJcjncSU6R0++wShu3sMBLEZSxTKOytpXkzstjlMtZ5PybcJN6/KjtjlL0Uf2/KlcU/HCCM
	xCQgcLxIOFtUhrmOd5tUn+c//WQIYteh9BEp85M8HPNtrZ9pQgx2tfHjaah81uUelMvz/4PDYnD1q
	isJcGcoqg==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1gvKdm-0004aK-8D; Sun, 17 Feb 2019 11:29:46 +0000
Date: Sun, 17 Feb 2019 03:29:46 -0800
From: Matthew Wilcox <willy@infradead.org>
To: ziy@nvidia.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Michal Hocko <mhocko@kernel.org>,
	"Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Vlastimil Babka <vbabka@suse.cz>,
	Mel Gorman <mgorman@techsingularity.net>,
	John Hubbard <jhubbard@nvidia.com>,
	Mark Hairgrove <mhairgrove@nvidia.com>,
	Nitin Gupta <nigupta@nvidia.com>,
	David Nellans <dnellans@nvidia.com>
Subject: Re: [RFC PATCH 01/31] mm: migrate: Add exchange_pages to exchange
 two lists of pages.
Message-ID: <20190217112943.GP12668@bombadil.infradead.org>
References: <20190215220856.29749-1-zi.yan@sent.com>
 <20190215220856.29749-2-zi.yan@sent.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190215220856.29749-2-zi.yan@sent.com>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Feb 15, 2019 at 02:08:26PM -0800, Zi Yan wrote:
> +struct page_flags {
> +	unsigned int page_error :1;
> +	unsigned int page_referenced:1;
> +	unsigned int page_uptodate:1;
> +	unsigned int page_active:1;
> +	unsigned int page_unevictable:1;
> +	unsigned int page_checked:1;
> +	unsigned int page_mappedtodisk:1;
> +	unsigned int page_dirty:1;
> +	unsigned int page_is_young:1;
> +	unsigned int page_is_idle:1;
> +	unsigned int page_swapcache:1;
> +	unsigned int page_writeback:1;
> +	unsigned int page_private:1;
> +	unsigned int __pad:3;
> +};

I'm not sure how to feel about this.  It's a bit fragile versus somebody adding
new page flags.  I don't know whether it's needed or whether you can just
copy page->flags directly because you're holding PageLock.

> +static void exchange_page(char *to, char *from)
> +{
> +	u64 tmp;
> +	int i;
> +
> +	for (i = 0; i < PAGE_SIZE; i += sizeof(tmp)) {
> +		tmp = *((u64 *)(from + i));
> +		*((u64 *)(from + i)) = *((u64 *)(to + i));
> +		*((u64 *)(to + i)) = tmp;
> +	}
> +}

I have a suspicion you'd be better off allocating a temporary page and
using copy_page().  Some architectures have put a lot of effort into
making copy_page() run faster.

> +		xa_lock_irq(&to_mapping->i_pages);
> +
> +		to_pslot = radix_tree_lookup_slot(&to_mapping->i_pages,
> +			page_index(to_page));

This needs to be converted to the XArray.  radix_tree_lookup_slot() is
going away soon.  You probably need:

	XA_STATE(to_xas, &to_mapping->i_pages, page_index(to_page));

This is a lot of code and I'm still trying to get my head aroud it all.
Thanks for putting in this work; it's good to see this approach being
explored.

