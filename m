Return-Path: <SRS0=L4L0=TB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4E317C43219
	for <linux-mm@archiver.kernel.org>; Wed,  1 May 2019 13:37:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CF68C21670
	for <linux-mm@archiver.kernel.org>; Wed,  1 May 2019 13:37:00 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="ekXutGok"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CF68C21670
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 208826B0003; Wed,  1 May 2019 09:37:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1DECD6B0005; Wed,  1 May 2019 09:37:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0CF536B0006; Wed,  1 May 2019 09:37:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id C96396B0003
	for <linux-mm@kvack.org>; Wed,  1 May 2019 09:36:59 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id a5so8847489plh.14
        for <linux-mm@kvack.org>; Wed, 01 May 2019 06:36:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=GDvmo8APjKKAf1sS8t8MFe7S1hHEWEC3gdsaHrs41B8=;
        b=Tiz6jtJOcSdu6qLYk7vuioWVJ8N2uWhS1zYoyTE94zEHeFg3rHeB7F/3+GPj1Ja/nq
         ca4vAYmhSgkoPZa8rjUg4e0FwI6sFLIY7RsKQMsJM7Tuka2mk1z1acikRBSLOo5b0mIS
         tZW9WQMLCfg24FK+5TirNcFRsIcEvnH+E+7j/145KrRyPmKTy/fO23Cc3ZEp2AmAdhu+
         OShx9zRWdlGHyidF+H9hwE4KVI4/x2lZWvk8yYfuRDjmoKu6efbCFbhcDTR9T6Kxu6rI
         xLBTtsoeXL2++wwh0u4vXH4w4Q93GJBWuTkTNqOcoJlx3qMTUocLL7sE9vyNIk7Z40gU
         0XhQ==
X-Gm-Message-State: APjAAAXC7biuXTa+Z4hOq7gmJdcdvty3BTGJyEHz4ze/PJZx9G3XoMMT
	SS+ZuDUOdQ+iD2CyDvXXKQrCYtWlBIR5/yyFaGfFZjWS2Kr6WViD02VUvYtBbSGPedAuO7fpTxM
	oiCwm8YnhY/zJ6BYZOBwVCpwu7ip4PyKwCPLUxIsdcWBS8tY4NrGK1o6cBVHGhySviA==
X-Received: by 2002:a62:a513:: with SMTP id v19mr77593454pfm.212.1556717819419;
        Wed, 01 May 2019 06:36:59 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzDOQeO+W01mQkQcfvbLsYU/sbsJpOWNRZ7gFavr0Dbn0UyHNpdQdYQ92Za9/NY9/s5DpF0
X-Received: by 2002:a62:a513:: with SMTP id v19mr77593361pfm.212.1556717818541;
        Wed, 01 May 2019 06:36:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556717818; cv=none;
        d=google.com; s=arc-20160816;
        b=eeBSD/sOJzQd9T/PIij/Ir/tOts5ERRRa+KdeD7tp2el+Unoz77abd+MhUCJg1XRnk
         ua4Ql2YTG5AlI/qiY+dcotJ/jNvwdRMJW1pLc7RKnl6tDBDmpSVhvmuY16kbu4cWvUDp
         vP2LwJKkY27lp/Z6ScXDvPAa20gRkGOi/8V3UToaJ+dCcZfMWkG0gI54Uc9+If0NHtAI
         RTXMkdBb6e+lafApxpPcYHtB0XEL6p7ux/q8Pxhbfe8b/UuStK9mxEqKrVYSzLVgWhPs
         FWZ2O+rMn4pC4Ylgm2pmNS7h4P2wfimshK43BbqyJ82umPQTRD+FL//rQ4x0nwKPXyTw
         FLqg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=GDvmo8APjKKAf1sS8t8MFe7S1hHEWEC3gdsaHrs41B8=;
        b=M4EyyuLk6f2mIlChB7PdOpxoK7m3oF90k+sMnX8lTTSMVDMtP7J3cwd0THJNAyHGkY
         5iUiJgaV9EPrPMkrYtOfYN0qh2cf6lWuho7jb/Kz9+2yum97mM4IFABpWeEgjEsXy2vk
         4icFPwygSTYBEEt96m17edOlygGUShycZnfXfppnzhsQfOsnrIMM+jiKzKMNOIWSFxSq
         LNt2KcF/pVIz4LzYDT6i2gIHhNedR5JoR/qnU7WuvfaoFi6R3QJW1ri17fQ3H8LH1k1/
         zEUNOII1VWAb7/cWNqSqQFtgf+TnFFlX4/GBSw9X5aXx15FScOhoW4RgGo9NPZRCtd52
         E1Fw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=ekXutGok;
       spf=pass (google.com: best guess record for domain of batv+fbe6eae7536a933b5243+5729+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+fbe6eae7536a933b5243+5729+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id h19si8885269pgg.125.2019.05.01.06.36.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 01 May 2019 06:36:58 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+fbe6eae7536a933b5243+5729+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=ekXutGok;
       spf=pass (google.com: best guess record for domain of batv+fbe6eae7536a933b5243+5729+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+fbe6eae7536a933b5243+5729+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=GDvmo8APjKKAf1sS8t8MFe7S1hHEWEC3gdsaHrs41B8=; b=ekXutGokZQcHKQJr2Fg6jLrC+
	H0ANTOh0e+gQc5hh3bM3pwKr0Dbe4jxXpjVihwfbovHW/oXW/WJYNkKYvRnDgnXGKBrbQ4cTFhGxJ
	y4oT1xJ21qvem0IyOCq9HJC/8Mdbl8yxvlRcgW/JXEEtfeflPj02Pf+LrGTg56yWcOVoZsaQ+9M9T
	KqT/rnRmEXBXUv5baGG+wpb08YlM3tF4dz4A040wI0FlgIQ0iMiUibVVUOWQpEcWczMcWDUQudalT
	Z8OE2Pyq7tEAMpT0Dlqkpc2NLvc0ITaeZZNtbd1Z3irbAPO0IFDKIWgN6U3ueQdg9wwEIs2C7Uy0B
	49Dd++4rg==;
Received: from hch by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hLpPq-00035h-S7; Wed, 01 May 2019 13:36:54 +0000
Date: Wed, 1 May 2019 06:36:54 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Sami Tolvanen <samitolvanen@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
	Kees Cook <keescook@chromium.org>,
	Nick Desaulniers <ndesaulniers@google.com>,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH] mm: fix filler_t callback type mismatch with readpage
Message-ID: <20190501133654.GA26768@infradead.org>
References: <20190430214724.66699-1-samitolvanen@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190430214724.66699-1-samitolvanen@google.com>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This still leaves bugs around in jffs2 and nfs.  And it is a little
ugly.  This is what I'd like to do instead, so far untested.  I'll
post a series once it passes basic testing:

http://git.infradead.org/users/hch/misc.git/shortlog/refs/heads/filler-fixes

