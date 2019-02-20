Return-Path: <SRS0=8949=Q3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CC5B5C10F07
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 21:03:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 86A5D214AF
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 21:03:25 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="Ton1IpYU"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 86A5D214AF
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1DF4D8E0032; Wed, 20 Feb 2019 16:03:25 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1B3FD8E0002; Wed, 20 Feb 2019 16:03:25 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 07CB08E0032; Wed, 20 Feb 2019 16:03:25 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id B96118E0002
	for <linux-mm@kvack.org>; Wed, 20 Feb 2019 16:03:24 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id x11so6016768pln.5
        for <linux-mm@kvack.org>; Wed, 20 Feb 2019 13:03:24 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=nmbRDXdT50ITWrkNYUhHuegzkM5FDZwPlBIvVUFrslE=;
        b=nWbDn67VbepgVDzD4t0pJ3tlVDiTH/gcZb7L11f1F17VeCGORreBA8EcjBSkh34jc5
         TEQ5dOwDe9pXxyWjqmC41hYYx+OkNFRpbbpqEUx68WowSU1WdPkHglViDEGf0w5dRZlt
         wObg1UAA80oYDcdd07wHT1Rx853XzEbk1QDVKZsbv1u7KKgKTYMqWtJrqeH4/2vaWZWq
         3FF06wQFjcZINCqLbctYpB3ceGfJxq+c4INZArbAhBlqtSyMkLTM3fWW2mp9Clh5lZ6V
         /olz3/rFPkk65Vf+XFLcEMS+A0D7Ujcp+HdCOHtahCgyAULYUazxmwazeCH64nSyAMiv
         r5oA==
X-Gm-Message-State: AHQUAuYLIzH5s4/RhtS5arjAFTDiQnphvP8yOy4svVx/ESAk7f9nKhTB
	juo2gEwL3xbDF8b97+I4CTmKmWjbjO7vw5srvSgjyL7yoSd1eAX+FvgsIBvCgqtmj7KQNNRIfFd
	pkYwMMlRCm2xEiHPXyFnqc+RmZNR5MkCYKCE4lWAAb8DOn+uOhE8Qx5R3cdboP+HdfA==
X-Received: by 2002:a63:5702:: with SMTP id l2mr2460228pgb.2.1550696604436;
        Wed, 20 Feb 2019 13:03:24 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaFHVlTh5gD2WIIy2fBIY5y7I+5/EoUuwhvuUUu9reAHx+vkxVLtyBAFVxb2/N8jN6GiPni
X-Received: by 2002:a63:5702:: with SMTP id l2mr2460189pgb.2.1550696603788;
        Wed, 20 Feb 2019 13:03:23 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550696603; cv=none;
        d=google.com; s=arc-20160816;
        b=Mc2zjPaPfvEBpv+FSi57/olSBFkR5BcpZ/d5cLVpaZ3DEiL5Rp8C1B6SfOPih5hv53
         X69WHpKp4n4llFwZex1wwFpz7c2nraqXn7QoU+9p4xJw4a45J5cC2q7fYz842hDn0NMC
         IB+7+dBzknDY4R20vrHwBI2EZgq7CWdG6WWkH/cgTbYl3+ku7IAaNOcy80Tx+UPHkK48
         PEIRrKEfsf1Km+ly/PX0LCJgdCgFwH1/40WNJ4W2f3kukWD57UDZI1uAWSA4ROPP5Huq
         t79N0024CqvMokF8ioIdNx7MAaL2wpTVB50Sp3BT0pWahf2PS9In8Fooj9rgSEhPNczp
         2hfg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=nmbRDXdT50ITWrkNYUhHuegzkM5FDZwPlBIvVUFrslE=;
        b=ca/7Wqa78pU205SJnktIT66n5beWGAkBF6PEtrJcZg/ZNJrwzMJHs2UqO38DCkyHaj
         5BPl5ncmrllfVBXENbFEYxLA0EWssF1Z9mrH/7EDsL3OFovei2WUlQ3rNikepLufu87U
         lhlMNLRUXKmy2WgOZPnAIEmOSVx08LwMfzW1+2gsGjoaXs6Tvex2GXlJmNBtHD09jYch
         Z1EQ/sFlDmPjoOqFDZapblxZHcWRdJAVpmRcNwfBPT8dxgS6CBSdXkN3QxSAjYrQW2Lg
         bdezZrG+HkpaD934fooTaEENktRE1FqqV9fjVeAmKzP0ARkJTtxCy8ADmmTpGXgSY3yt
         9Mew==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=Ton1IpYU;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id k30si2136600pgi.146.2019.02.20.13.03.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 20 Feb 2019 13:03:23 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=Ton1IpYU;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=nmbRDXdT50ITWrkNYUhHuegzkM5FDZwPlBIvVUFrslE=; b=Ton1IpYURLOmkhW0iltcfuoEs
	TvcRQC2lQL47Lx3v6rP7SPfFAGEjMCkjN8kuO2Bu9Lb+40RBfqjRCr4ghjJ23Z0c7OsgkeoDP6nvK
	7YnhMV1/pGtymXwtR5TRX6l8oyVBtjI9q4uHNADrjueVgDn/hKuQPshdaqZoBydRBCLY44HdPD24a
	RZ+z9FgfM2DjXNq3M8uBszkQGFjFTLeiy3sovOnTuugz6MGJJa9s6FpiX9aGcef4xZlKnmqAj/SVp
	sH7xlZuPIeQqgQv+ZYIldCsDubHWXJ/6xw2Qnvev0CMzmaPFWiYSCtxOrNBwbM/bk2JQhaMPlou7A
	0tn7c8GSg==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1gwZ1P-0005my-Oh; Wed, 20 Feb 2019 21:03:15 +0000
Date: Wed, 20 Feb 2019 13:03:15 -0800
From: Matthew Wilcox <willy@infradead.org>
To: Yu Zhao <yuzhao@google.com>
Cc: Anshuman Khandual <anshuman.khandual@arm.com>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	"Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Nick Piggin <npiggin@gmail.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Joel Fernandes <joel@joelfernandes.org>,
	"Kirill A . Shutemov" <kirill@shutemov.name>,
	Mark Rutland <mark.rutland@arm.com>,
	Ard Biesheuvel <ard.biesheuvel@linaro.org>,
	Chintan Pandya <cpandya@codeaurora.org>,
	Jun Yao <yaojun8558363@gmail.com>,
	Laura Abbott <labbott@redhat.com>,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
	linux-arch@vger.kernel.org, linux-mm@kvack.org
Subject: Re: [PATCH v2 1/3] arm64: mm: use appropriate ctors for page tables
Message-ID: <20190220210315.GM12668@bombadil.infradead.org>
References: <20190214211642.2200-1-yuzhao@google.com>
 <20190218231319.178224-1-yuzhao@google.com>
 <863acc9a-53fb-86ad-4521-828ee8d9c222@arm.com>
 <20190219053205.GA124985@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190219053205.GA124985@google.com>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Feb 18, 2019 at 10:32:05PM -0700, Yu Zhao wrote:
> pgtable_pmd_page_ctor() must be used on user pmd. For kernel pmd,
> it's okay to use pgtable_page_ctor() instead only because kernel
> doesn't have thp.

I'm not sure that's true.  I think you can create THPs in vmalloc
these days.  See HAVE_ARCH_HUGE_VMAP which is supported by arm64.

