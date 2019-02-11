Return-Path: <SRS0=4tVm=QS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0A169C282CE
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 19:09:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B71AF2229E
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 19:09:10 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="hHSxsAMm"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B71AF2229E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 407258E0139; Mon, 11 Feb 2019 14:09:10 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 38CFA8E0134; Mon, 11 Feb 2019 14:09:10 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 230418E0139; Mon, 11 Feb 2019 14:09:10 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id D19E38E0134
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 14:09:09 -0500 (EST)
Received: by mail-pl1-f199.google.com with SMTP id q20so13312pls.4
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 11:09:09 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:subject:message-id
         :mime-version:content-disposition:user-agent;
        bh=E91HbN5nHgQWlkJg36bcb7w4k7jQQ9V6f5qX1ZYtB7U=;
        b=M7LAv90w4MpJ0pXQBmY4oDSwwvsvRGdyH/jPij6/oA4FRiyPRIHCLviAC7WIlj11Vk
         7eU2BQp1UB2vxUPo/6hZkhcxeqCSv1sXclUOowqps9OfKKQvY1h7H6kPD3EeC6q7JF55
         LK/wMr/ldn/qI/S3ep8axcON+XUhDAdD9Ce0hEm8A2dPr2cErIDf37RPi1HfYgv0Xloq
         Z8t65ZtED14zF0GxYWETw/WxRyIurFkM4ovTe+EhtMTOFsaxPKXUsjxSkU+0NOfvVN8i
         9dtHTp0d15EmNNhqwwJwBg0FPOGc1g2YoSxeXvNFdtUydxrQuFSqmb9di43x/XGhDNNw
         xXIA==
X-Gm-Message-State: AHQUAubA/IuR1xU48oBDP6uRb5EZkUvVcXNh41xA/nk4prkCBjeaZcGY
	5zLOlXOGxBBB9wmteQpLgceUlBg6QsO5z8AzAlyjXeZZW1k+1j0VTEFdTyHz5rrkOanDRbgs+Hn
	QFgRa88jEyipOTuPPAF7agcILSvlHH1GOUoyWPWyb3SrUrXyhlzS9twtDdL2mSaBVlg==
X-Received: by 2002:a63:ea4f:: with SMTP id l15mr25101653pgk.102.1549912149502;
        Mon, 11 Feb 2019 11:09:09 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ib1ga45YtCchrqbbPRAyGnmGajyXNlRV77FGkOQup5WXVLWMSWlPZj131D/vf0qknQJpNn3
X-Received: by 2002:a63:ea4f:: with SMTP id l15mr25101592pgk.102.1549912148731;
        Mon, 11 Feb 2019 11:09:08 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549912148; cv=none;
        d=google.com; s=arc-20160816;
        b=0/vrTQe6RNnROeUlwhSVwvxM9X7VMM+EpINxPJCQWN4hePK5tgrQcvx61ZbIREt/Ef
         9FzkqU/fzzJux0eyXVkYHr2lO9i8zckM0MoDXFFwSFnWyij6gpfWXKdhhWQrU8Ahn4fu
         umJK3datbfkOgrJNDtdxuDr87LFh/4//9qjlfqmgipkH6okhsxt476On+wT82G3/aqrW
         N3/6L6NMY8pjgZL7xMtHNRNm81iB0zZSpxytg+iz3p1ObnLjsdRL4n/drnMFLX1H9WeM
         /ObqT1IAGrKTpQoyptWKAXaSJ6soWgZdeWblpOiDeyUDv/EN2Gr6b+KWoH1ccewySuZS
         O5vA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:content-disposition:mime-version:message-id:subject:to
         :from:date:dkim-signature;
        bh=E91HbN5nHgQWlkJg36bcb7w4k7jQQ9V6f5qX1ZYtB7U=;
        b=unWHjzqCobbEuO8Neif3hl2LXxisWzkxe5pM4MIf1/N+bNbUONfi6nZvQGQKMmcces
         XxwRVM49kWEoxoQ0Or4wSq+eE+Fj8eKSsrSrnuv11EaaydNZQYdxgO3edcSwfn6VwSu3
         vY0Rv74/5GDGTxDbYWFx4ga86Y5t6+pyxH+q4ntRYfU/hOo0RJWTPCWnVdQTcxXer9zH
         Kx68Czw+bCiXkc8+3e1+14ssJLgCnLpyvSdX30X0Ct6hoP+0FseB6WP6w7W0hIcuxt2H
         +JWgfNYLW2p4f6XP5cRSIwivlOPCrPYtQEkBGbf1QDAvPsofnNdCnyTzIvOqk1rbnZXM
         WiuA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=hHSxsAMm;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id l81si4313124pfj.230.2019.02.11.11.09.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 11 Feb 2019 11:09:08 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=hHSxsAMm;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Type:MIME-Version:Message-ID:
	Subject:To:From:Date:Sender:Reply-To:Cc:Content-Transfer-Encoding:Content-ID:
	Content-Description:Resent-Date:Resent-From:Resent-Sender:Resent-To:Resent-Cc
	:Resent-Message-ID:In-Reply-To:References:List-Id:List-Help:List-Unsubscribe:
	List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=E91HbN5nHgQWlkJg36bcb7w4k7jQQ9V6f5qX1ZYtB7U=; b=hHSxsAMmj92F+UkkA4c3M/+VKT
	yQ5jUO2ewktGcO+333VTG5ss6Mx6XPed1P0SnjBQeoKYfaifUZG6G25fiDDU8XEnttW6+C9pKsaAf
	LZcTS9tsUysUMcLAlr4I4TchHavWk4/suAJVMW2a1Fa5bOa5DYflHKTITUrBRwgWLtVXHOCmyU2fl
	B6eD6KWiYUVomKD+J95AcLXGn2tZfhH3hhesZj2Ffq0Y+OPRZw6oW+i5Ml/Sg5d+QV4uupfFHeCvR
	LMaFKbP5QIwGMO/JEdPjCNgEZg4/bmAFI4XTGJtV8ZpuQPwN1NRlnRet0sakLbsaamToFoNoUFTSD
	qdKZq8lg==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1gtGx2-0005gf-8o; Mon, 11 Feb 2019 19:09:08 +0000
Date: Mon, 11 Feb 2019 11:09:08 -0800
From: Matthew Wilcox <willy@infradead.org>
To: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
Subject: [LSF/MM TOPIC] Eliminating tail pages
Message-ID: <20190211190908.GA21683@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000002, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


I can't follow simple instructions.

----- Forwarded message from Matthew Wilcox <willy@infradead.org> -----

Date: Mon, 11 Feb 2019 11:07:28 -0800
From: Matthew Wilcox <willy@infradead.org>
To: lsf-pc@lists.linux-foundation.org
Subject: [LSF/MM TOPIC] Eliminating tail pages
User-Agent: Mutt/1.9.2 (2017-12-15)


Tail pages are a pain.  All over the kernel, we call compound_head()
(or occasionally forget to ...).  So what would it take to eliminate them?

I'm doing my best to eliminate them from being stored in the page cache.
That's a nice first step, but the very first thing that functions like
find_get_entry(), find_get_entries(), et al do is convert any large
page they find to a tail page.  So we'll probably need to introduce new
functions which will return head pages and convert users over to them.
I know Kirill has a lot more experience with this.

Another place where we return tail pages is get_user_pages().  Callers of
get_user_pages() expect tail or small pages; they do things like calculate
the offset of the byte within the page by AND with PAGE_MASK.  There'll be
a lot of work to check all the users and convert them to something like

unsigned int page_offset(struct page *page, unsigned long addr);

Another thing to consider is that some architectures have a third-level
page size of 16GB (looking at you, POWER).  So an unsigned int isn't
going to cut it.  Do we want to support pages that large, or do we declare
that there will never be any point in supporting pages larger than 4GB?

There are probably other pitfalls I'm forgetting or have never known.
Something like this will be essential for the glorious future that
Christoph Lameter keeps talking about where we divide the memory up into
parts which are only accessible as 2MB pages and parts which support
legacy 4kB usages.

Useful participants:
Kirill Shutemov
Christoph Lameter
Hugh Dickins

probably also relevant to the DAX crew.

----- End forwarded message -----

