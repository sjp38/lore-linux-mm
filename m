Return-Path: <SRS0=0yrr=TY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 288CEC072B5
	for <linux-mm@archiver.kernel.org>; Fri, 24 May 2019 06:34:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DAB3720879
	for <linux-mm@archiver.kernel.org>; Fri, 24 May 2019 06:34:48 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="N5xiqRQb"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DAB3720879
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 740116B0005; Fri, 24 May 2019 02:34:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6F0646B0006; Fri, 24 May 2019 02:34:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5B8796B0007; Fri, 24 May 2019 02:34:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 26E546B0005
	for <linux-mm@kvack.org>; Fri, 24 May 2019 02:34:48 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id t1so6144378pfa.10
        for <linux-mm@kvack.org>; Thu, 23 May 2019 23:34:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=u2o3UzKkWTUfB1f82a7SGgQAWjeYiA8xLwM3pufnUuk=;
        b=ZveUS2r7KF1cWnB2F7bJ+U15JI2QVnRqt1+5vKBRDL/l6sQOL0BmziFhjTZdPYj13d
         pJd8RSulFA5KczJtQUyRkuV/tt7r4U9+x9AfMaZ8Q/wXuzqRNCfspoZiM96k9oZtipP2
         tQq+D09nDgaPeBaRkScgRVkSuNgy5xLsbp8BnOZxtPH5C5N0Dx7kIKIVrAY4ir07dIa1
         r0UXng6pVBOwL6PaAexVkHZAH4DPo0hKq9SYLMoZX0m/IPPmBMfntZtbV4vS0yejnr9o
         BmvBg4snPG/tZrGr6yxfoiEcG3A3XPpDlyx56N3vEWmlNWZXGsHUVEveKtqAvLPic+cJ
         T/pA==
X-Gm-Message-State: APjAAAX2vW2Ijhu5ukDhdNWXvyyFCPLnTfzqrCToxOK21ubE5264OZ0q
	76KRXsl6Wq9Up8AJjuxe7cyl1yYTr8EZJ2Gw1/lPF1xdSXwGGU4Ina7c6eDNIUa/8dxrPIeNcsU
	g1twrvCVXb3hVeTfwxTjE20whSXrDSuBa7Iek6z8SyJqAE7lMPGzkA2CDm8UbBjR3jw==
X-Received: by 2002:a17:902:728a:: with SMTP id d10mr1798620pll.90.1558679687650;
        Thu, 23 May 2019 23:34:47 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzk/V6Y+/9Ho2LmTZfmbZqn/J0tc6eqWr6RJstgUnFqW86ADEe5vH0WKMtw90uXrmkqllz4
X-Received: by 2002:a17:902:728a:: with SMTP id d10mr1798585pll.90.1558679686881;
        Thu, 23 May 2019 23:34:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558679686; cv=none;
        d=google.com; s=arc-20160816;
        b=jiSWrhW1p8kfUW9nWCFblBdJJi1tQqI1t5sBHd1q5XpUorV6q1DtSmNQ86ahHUnqST
         J0aSR5Y3Nu2dLj4FMcXopDK6wBKoOkb+eXqULRHJbQee3Vp9lPepjeZL99A5QgNpa7GW
         jXF2hmRrE1ci5Av0tLL1hl+DMVVR/bcA0vq3MRw3dtYmFkNY5I96KkCEnvPpkQC3x+r1
         42O2+66FNV+zrs+DMyg85k1OXJ+fJLUdGpw8lgGKC6wiXWbQe7SVXKHW3cWWiwCldP4f
         uFy5xpEsRsxM/P1Anh3gqKTcZT6YAWnwszNH8KqJAonZBcnxjytfNmFAv8SQo0/sp4kD
         SXkg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=u2o3UzKkWTUfB1f82a7SGgQAWjeYiA8xLwM3pufnUuk=;
        b=aMPPq36A3PpZmgi23u8iYM8n+6ZbH/i/KEs10/VoFL3qFTW8tJ5mN7TyHkYixculxT
         B+bq0duwiqjna47EshNb9SmtBUPIDgnsfHPod05cx5PvDhhgn21cYaNYkQKmHJMlHsth
         H35FVllo1g+aTonzC40oLx2OykNcrcdfpqt5vzEAp9yBrLO3T1vJnoYf1IUGRIGpCd43
         eUJy0rmH7wjUjvgnkh0Vmy2xUlkWFmf1KfoJetTGCMT397voBPRvUQM1l0v5XuB8mB9H
         fa/94zRhYpYN+BgXwH6kbFO0NS3ydpDhYDECaFRxD/IMAF9cZouCnZ8r2jAS1cRskiS2
         MxQA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=N5xiqRQb;
       spf=pass (google.com: best guess record for domain of batv+78cc17f237ae777ce2e2+5752+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+78cc17f237ae777ce2e2+5752+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id d27si2751902pgl.202.2019.05.23.23.34.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 23 May 2019 23:34:46 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+78cc17f237ae777ce2e2+5752+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=N5xiqRQb;
       spf=pass (google.com: best guess record for domain of batv+78cc17f237ae777ce2e2+5752+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+78cc17f237ae777ce2e2+5752+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=u2o3UzKkWTUfB1f82a7SGgQAWjeYiA8xLwM3pufnUuk=; b=N5xiqRQbHA+cr341IMqdw3WRQ
	J7QcoS7dgTMX7zji3unStp3THlp87kkVok02ZaDqTyJbMiKs3Fai2BOv522JbCFs9EJDZV2biDi9K
	5l0JvFczpAiCfj6UXURHVCpx/KyxMvernW1LjZncqrH+x3f0Vz8z/uoVQsGYCMJyRlBNxZxsBMyGB
	rdlRL0VKbK9fArypn1AO18jR+PGWpIjnhosCn7xejkd/26F8ooB+3f5Dl5UypAzatEG1uJ1qTZHhY
	q+sojMX4NpLVbtKVlN0+C8DySDGNLIAIu6uwytVX93Ctigm+LIvHpMjd9qOmBisJFTY+s1kPHKdPE
	sAdxfTf5A==;
Received: from hch by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hU3mt-0005Al-Db; Fri, 24 May 2019 06:34:43 +0000
Date: Thu, 23 May 2019 23:34:43 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Kirill Tkhai <ktkhai@virtuozzo.com>, linux-mm@kvack.org
Subject: Re: [PATCH] mm: Introduce page_size()
Message-ID: <20190524063443.GA11151@infradead.org>
References: <20190510181242.24580-1-willy@infradead.org>
 <eb4db346-fe5f-5b3e-1a7b-d92aee03332c@virtuozzo.com>
 <20190522130318.4ad4dda1169e652528ecd7af@linux-foundation.org>
 <20190523015511.GD6738@bombadil.infradead.org>
 <20190523143315.9191b62231fc57942b490079@linux-foundation.org>
 <20190523214402.GA1075@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190523214402.GA1075@bombadil.infradead.org>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, May 23, 2019 at 02:44:02PM -0700, Matthew Wilcox wrote:
> > I think you'll find that PAGE_SIZE is unsigned long on all
> > architectures.
> 
> arch/openrisc/include/asm/page.h:#define PAGE_SIZE       (1 << PAGE_SHIFT)

Well, the whole context is:

ifdef __ASSEMBLY__
#define PAGE_SIZE       (1 << PAGE_SHIFT)
#else
#define PAGE_SIZE       (1UL << PAGE_SHIFT)
#endif

Which reminds me that there is absolutely not point in letting
architectures even defined this.

Add a Kconfig PAGE_SHIFT symbol, and let common code define
PAGE_SHIFT/PAGE_SIZE/PAGE_MASK..

