Return-Path: <SRS0=2U+7=VU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.1 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CF47DC76190
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 18:14:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7C21C20665
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 18:14:16 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="JCBoGa/9"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7C21C20665
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0072D8E0018; Tue, 23 Jul 2019 14:14:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EFA118E0002; Tue, 23 Jul 2019 14:14:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DC2F58E0018; Tue, 23 Jul 2019 14:14:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id A6EEF8E0002
	for <linux-mm@kvack.org>; Tue, 23 Jul 2019 14:14:15 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id f25so26665572pfk.14
        for <linux-mm@kvack.org>; Tue, 23 Jul 2019 11:14:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=meFPjAHnVpkx5LzG9td2xbKYymV0m46R0toM8uhLgg4=;
        b=C279xrggYAhAbnSk8jM9fQ7pubaKjrKwkj8qBwN2Jl8hxbNRtAf5O3kabGeuT3g2gx
         vRTozCgHoE0thBlJ1OlTrVHNa7NV8qY6ipGirJMCoe1aSnd1NySn83/vCUISTH41YM4z
         +NQ8RNW7bFMO/0Nqk0Mdq9ClsEdTpcajnLRV7A7t2Arcy+fIG9ePw3qRYyEvYsU69bHT
         pTryrrhN6ILJHHqx5WW1X3bKmV6ATZVcOuM6jffxHNcC4VvW3cJLKOSLsqnA+iiiNCn5
         ZwQYuOgLw2Z87zaT7KRqBZagNALAKOdJBb6y99yhNRjhiJ1O75FN5Z3QPL5+v0P/mA+q
         cuFA==
X-Gm-Message-State: APjAAAVCqqQxF83HkdC27aiei5H9rPO4GtGriwdiCTRtS6JVATKnVYM9
	3VZYFv/X2Jhmxv2DLTZhnBsjxkzpAHfUte0BLsNDhR8PgN+5ozmR1ih73cmuMzoKdHWRxl7Wccw
	UAG/j86UIe4giTehf83ErAMZzgl7tCWZq2+WhqMrMn7C6oJomi2cpe0UvX8cfSYQjCg==
X-Received: by 2002:a65:6406:: with SMTP id a6mr40966175pgv.393.1563905655201;
        Tue, 23 Jul 2019 11:14:15 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzN4PQilaUG4Ai1XNpValfs674eL4FHG3CIThCnO+x54yOmpp5FSdEw0wb8Musof7PYnu4q
X-Received: by 2002:a65:6406:: with SMTP id a6mr40966126pgv.393.1563905654477;
        Tue, 23 Jul 2019 11:14:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563905654; cv=none;
        d=google.com; s=arc-20160816;
        b=JOU8J+sB5EirklQLTs9DX6dHAD9+R6pw4cekseywxtz6jjgavJuIK4SrhU1KfofZRB
         8JySXG/ks3cBXiivkmWYm9HQcTDtnQMk/YmS21w3yL+4tULJvBt5VR9zG+G6PhhsPESe
         ar7iF+b9HKZYxASSD/GXro1SENeSEPYEWZnaKKbvnVWeD28P8nVrzSOIbRUGGiWn/tah
         XpdTWEejwUvePXWVyVLwUwYeYSPUoXJ0IHTcj6WebRNIaNTTVfSnrFLS2ZNuZqZiUSlq
         xZSq1Ucycdh1bfbcg0xRVAp+3DpKZPFw1BIXQ3jQ8JnA0diM+fn28BAmVRvFzPoYzG6F
         ReQg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=meFPjAHnVpkx5LzG9td2xbKYymV0m46R0toM8uhLgg4=;
        b=TH5ve2COxSxFsY7z5RTZ93YeHMMVsKzLfQdTxb7fAjrKSeex7LjGMMJDY4+WHIte0P
         VHSPu7LN1HOpOtN8pRzZegs6JPp97nzXVx0v0kZIa4MZ7wynobNvHkKhEBIl9kUY3xI0
         vwSAvrso2K0tJ/SIDXFYJYVr5PJaLqsvTyH7HYwHGGPOUY94uXrIUoB4lp6kdcQG41/P
         ofJ0SAqozxWMvaYpUYw9qIw6U98jAISUNmngEUbbcLvM9p1v+0UEpuXfVx8UQH6B7jN4
         N9M59bUNwWPJNsuK3DadPVvunyk4G90JJl0JNoud5I3UqTBvtb/l996fm/SGTAP78v1Y
         2XJQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b="JCBoGa/9";
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id 67si14583086plf.400.2019.07.23.11.14.14
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 23 Jul 2019 11:14:14 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b="JCBoGa/9";
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=meFPjAHnVpkx5LzG9td2xbKYymV0m46R0toM8uhLgg4=; b=JCBoGa/9fMlH12kemgaHenbGi
	Y4ZMyaL5fQuZnEcxRikVrj03Lz0tgfVMCuczzN07zpVBD0rNInixq1H9UAaW6FSvOqwF11DL7A4fo
	CfObJnXMtoO3//rBTxCSrSu/pCnlVVWIYTXirei8pOS7LsJcimLotK/Oy9EcFQTrrTHg+pTQaDFsm
	D4vP8YZnwRIeci4FPJgi976tbB2AVhRiwW/sIREyXx23Xj3gW5lvMlYV4bGksXwIZAdbK7CtbgMyr
	G3cz7l2Kig4hHN7JNCmZNWvVb07hCTvLGJgOL6sgItjf/8EYQjF8uss8/NDmslnZgsdZ9tDkucoHA
	9xe/HMC/A==;
Received: from willy by bombadil.infradead.org with local (Exim 4.92 #3 (Red Hat Linux))
	id 1hpzIj-00021d-9d; Tue, 23 Jul 2019 18:14:13 +0000
Date: Tue, 23 Jul 2019 11:14:13 -0700
From: Matthew Wilcox <willy@infradead.org>
To: Ira Weiny <ira.weiny@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
	Atul Gupta <atul.gupta@chelsio.com>, linux-crypto@vger.kernel.org
Subject: Re: [PATCH v2 1/3] mm: Introduce page_size()
Message-ID: <20190723181413.GN363@bombadil.infradead.org>
References: <20190721104612.19120-1-willy@infradead.org>
 <20190721104612.19120-2-willy@infradead.org>
 <20190723004307.GB10284@iweiny-DESK2.sc.intel.com>
 <20190723160248.GK363@bombadil.infradead.org>
 <20190723175838.GA29729@iweiny-DESK2.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190723175838.GA29729@iweiny-DESK2.sc.intel.com>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jul 23, 2019 at 10:58:38AM -0700, Ira Weiny wrote:
> > @@ -1092,7 +1092,7 @@ int chtls_sendmsg(struct sock *sk, struct msghdr *msg, size_t size)
> >  			if (page && off == pg_size) {
> >  				put_page(page);
> >  				TCP_PAGE(sk) = page = NULL;
> > -				pg_size = PAGE_SIZE;
> > +				pg_size = 0;
> 
> Yea...  I was not sure about this one at first...  :-/

I'm not sure we actually need to change pg_size here, but it seemed
appropriate to set it back to 0.

> >  							   __GFP_NORETRY,
> >  							   order);
> > -					if (page)
> > -						pg_size <<= order;
> >  				}
> >  				if (!page) {
> >  					page = alloc_page(gfp);
> > -					pg_size = PAGE_SIZE;
> >  				}
> >  				if (!page)
> >  					goto wait_for_memory;
> 
> Side note: why 2 checks for !page?

Because page is assigned to after the first check ...

