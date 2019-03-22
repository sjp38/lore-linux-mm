Return-Path: <SRS0=SIh7=RZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E52A5C4360F
	for <linux-mm@archiver.kernel.org>; Fri, 22 Mar 2019 13:22:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9DA142075E
	for <linux-mm@archiver.kernel.org>; Fri, 22 Mar 2019 13:22:57 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="Outupez3"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9DA142075E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 570E16B0005; Fri, 22 Mar 2019 09:22:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4F8DF6B000E; Fri, 22 Mar 2019 09:22:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 39A036B0010; Fri, 22 Mar 2019 09:22:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id F09066B0005
	for <linux-mm@kvack.org>; Fri, 22 Mar 2019 09:22:56 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id b11so2344341pfo.15
        for <linux-mm@kvack.org>; Fri, 22 Mar 2019 06:22:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=pVMvJImQW0OeH4Rh98mg2ke73+cWCgSW7c1J8Xsu5cU=;
        b=bUmOTrR0F0z8V/qigATrYMzsglt4lp9tdRhi3SMiMvueV3cYfAed9ouAt/9NB/vVUb
         6BfjbS50ti973PBzCPFu/qnP1OI0yPOzcXpND6V7C6UNb1Ww17ND/i1Tx2mYsJj17akO
         uK1idA2MGvXtgA3kvvr6oodWG9UydDdBnzIlVuxAubOv3BZ/64Ma3iZHQ6MeE5x6mQZD
         sVGlBFMuCtr77xiZoejPvPWHuvtdr6oU36btUWFELsCrzYlArvTRPw9KkzCmhonHIFFJ
         POxdadb8cg1B0AoSAWivYbFaf4sNyqZo4YQ6BXUKqsVp6V0RGsxUmELmM9qX0kS6Jo7t
         3lQw==
X-Gm-Message-State: APjAAAXxG8HvB7YVwKeGwBUQQd9BxR7xyNNWXB/5LMjspbDXQxScn5AW
	DrvtGueG+NquPOMgzv9PPOe6xeiPPLgpo+PQ86cPw1gVhkCXE7PUi1axcooEYJdPDHWFck7VdOm
	VBjCRWazY08vSXUpXRavxvS/gy9aeTg8isb+d+N2eJm36DN2YQHNww2dzlXA8JX2+iw==
X-Received: by 2002:a65:4981:: with SMTP id r1mr8958752pgs.62.1553260976660;
        Fri, 22 Mar 2019 06:22:56 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwuWOnSbNU3hrf+0Y/niCMydqhkwQ8R1vBSjdAG4N4zOs+HTrmRCS/U6+b4Ud+yKMlgKuDY
X-Received: by 2002:a65:4981:: with SMTP id r1mr8958687pgs.62.1553260975962;
        Fri, 22 Mar 2019 06:22:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553260975; cv=none;
        d=google.com; s=arc-20160816;
        b=IHn4cSq1iPm8fOCgGyLm3GieIn6T0SFcGJhQDTuTus9NBEczKuGHiz1VblXMM41gcE
         oOVNfpH0QMRQSPyPvc17XQKdVZ1Nj2YVnXZOT8RHRCojG8FjKrlQ7JKw1QnE43ZeEwe7
         0Ds10koXpM66r0t/7s479C5FXr7lF+eYKZxKuMd/opGKPZeFTxNnZCugUJAd4pebtdLR
         nTcciFEolY5fbHaRKmxW9eO+S1IRy7Mf68K7y+rUde8Qq3cm9/yJLCIoNhM2BkWtzyuS
         BWWzvtLIPObUDlgUyVGDiU/rzN1BohJxKqC5HeTr8gRrOIXk/kG17AybjhTuch5Y2yBO
         AWjQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=pVMvJImQW0OeH4Rh98mg2ke73+cWCgSW7c1J8Xsu5cU=;
        b=ohgszB2us0yPGElSyAY633mnSvrj6jNfgsO9DDQhj/v/koWsZIGhYFlHudtiVIMZm3
         J7BD3rISTD5XH5IAKja2EJULPsFmnGkSJcD4VGwM8YNrWfR1fp4iwkGz0CRL8FUFdP+I
         //XIN9dBE/fKIXiX7t5QOAngwViwf2QueafpN4TgX5+ibSAhq83JBmYXvBOk0iVrVpix
         iaJKddm6rNr6PuBpNXOJW+Rn67Rn8ILu8CsvBfK0lJNsSyp0IrTqm71IC74x0gD3yGiI
         wz0Ch5Phz3SZIcRmaXx2fluI58bqtbAx+BvW4eqGLAvjILDexGwsILHaGBCbONEJX7EO
         CKUg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=Outupez3;
       spf=pass (google.com: best guess record for domain of batv+727712e9dcf37bb32c64+5689+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+727712e9dcf37bb32c64+5689+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id 136si6676590pfc.170.2019.03.22.06.22.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 22 Mar 2019 06:22:55 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+727712e9dcf37bb32c64+5689+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=Outupez3;
       spf=pass (google.com: best guess record for domain of batv+727712e9dcf37bb32c64+5689+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+727712e9dcf37bb32c64+5689+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=pVMvJImQW0OeH4Rh98mg2ke73+cWCgSW7c1J8Xsu5cU=; b=Outupez3XLTGt1QElWjkzrYtj
	OS+shtHW6+ntvAHU6UUmXXrcSOm8CVIsleV3aqMHBgiNZ/03PlY31jodt8i9paxSXmVshoQUwEM2v
	PkiB/ixTsglqAC5IIhYbvg+jY6hRetrnRSG03YxOngCoVmJ+C1O6rztb2WWszX5zDmi51f9F5gsRO
	zBNv6WMNG0XgH25iSnfLlzkYCvhJIgfYWmLjAoNEOFBJls7zzqT6O1QNHoiRdF10HgM1/7YCJyQzX
	1VCotT7q39nXERmKEpbODBag0cNcPUZiJBhmbkLTBeDddmjyzgWW4eZtcEEUgwcb6dtmxI+HW8FTQ
	MNljU8lgQ==;
Received: from hch by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1h7K8E-0004vo-Md; Fri, 22 Mar 2019 13:22:46 +0000
Date: Fri, 22 Mar 2019 06:22:46 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Alexandre Ghiti <alex@ghiti.fr>
Cc: Christoph Hellwig <hch@infradead.org>,
	Russell King <linux@armlinux.org.uk>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Ralf Baechle <ralf@linux-mips.org>,
	Paul Burton <paul.burton@mips.com>, James Hogan <jhogan@kernel.org>,
	Palmer Dabbelt <palmer@sifive.com>,
	Albert Ou <aou@eecs.berkeley.edu>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Luis Chamberlain <mcgrof@kernel.org>,
	Kees Cook <keescook@chromium.org>,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
	linux-mips@vger.kernel.org, linux-riscv@lists.infradead.org,
	linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
Subject: Re: [PATCH 4/4] riscv: Make mmap allocation top-down by default
Message-ID: <20190322132246.GB18602@infradead.org>
References: <20190322074225.22282-1-alex@ghiti.fr>
 <20190322074225.22282-5-alex@ghiti.fr>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190322074225.22282-5-alex@ghiti.fr>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

> +config HAVE_ARCH_MMAP_RND_BITS
> +	def_bool y

This already is defined in arch/Kconfig, no need to duplicate it
here, just add a select statement.

