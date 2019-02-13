Return-Path: <SRS0=uhAD=QV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B1312C43381
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 00:00:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6D829218FF
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 00:00:04 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="fhfcX3vp"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6D829218FF
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0D4A98E0002; Wed, 13 Feb 2019 19:00:04 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 083208E0001; Wed, 13 Feb 2019 19:00:04 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EB2C08E0002; Wed, 13 Feb 2019 19:00:03 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id AB0378E0001
	for <linux-mm@kvack.org>; Wed, 13 Feb 2019 19:00:03 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id 202so2885601pgb.6
        for <linux-mm@kvack.org>; Wed, 13 Feb 2019 16:00:03 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=PVFA16fPab14F0anc6dqP0hd/bRvwu2w6Thhi/SlaUU=;
        b=F/KGzAcERQE78xMjGTWV2wZAOS2+uKCK/6sSBSFUXRVTJnpvsPSUkd9lcyirlQ7xVP
         gZ3oypaAnUeGj1osp+5EiIh+WVeVx4FpbhLNNFwywRI5aw9My9krZc+0zYbLtqrZKSba
         SzyoJ8bTFtM+yVtK94ZPHmAwVbV1tZYovyJna5CTZuOURbf+5sfWk9mb93zoWGbZdI+X
         jcJjJ6IuFlUnXU1M17druYnyZzZDjCVzrD0srXuVLVtZnEGIKw+8fAryEdjlfx6WUjmO
         weRyU7+S34pM7cuZKncG1AFefTFrQluiex3OmdZhQjTeLY5LOblH66IySFezbjzC7mRT
         1Dmw==
X-Gm-Message-State: AHQUAuZJaUr/ywKRd0nG9l5E/yN0ckM96nPSNJIQj1gb2QTogYhF0AFR
	JotrucX9rOpq7ZYg7KegTQ4nVaFtcGCf8VSKjDSHVNu89MSPqIgklRAxLQ5DbXO6KZvurj6K3e2
	deJGSf/V/BzyAMGJ86fOAOOCPxJaoBGk8dVSRqPmFR5YFhIrisJr6/1xs2EvbPEud9w==
X-Received: by 2002:a63:2706:: with SMTP id n6mr802551pgn.352.1550102403285;
        Wed, 13 Feb 2019 16:00:03 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYVCFJsgpbVpd8bFCXgw1jRBgQP5KKRlfanT2PrXWdXyNj9zVBOlSwZhvjGe9lVGcbigg63
X-Received: by 2002:a63:2706:: with SMTP id n6mr802489pgn.352.1550102402438;
        Wed, 13 Feb 2019 16:00:02 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550102402; cv=none;
        d=google.com; s=arc-20160816;
        b=z5iYfcVv8QgGi9ffd1gpXK8pm/qA7zYXpN43/BF5aF7uUcYV7W5F8e2IpdfH0+Vacy
         qR57YJEmBNrdR8XOFX/tytOu0K28P88gu0Nyh2F/zqD4wdtkyY28yrF82Gu7YSMmPUMj
         i/kfx4QAvY8BFqv3ILgBAFI7AoFtNnfhYAXLcM3HVv69bEg38ilxMc7iHWdFKv0szwqe
         1iTbvZ3VOAKS0fTSGrRDB/aacC+Z9gtcxgNkgdNZN2ldx5jEcckbFx7D8oOPTSu4OSWa
         UDQ/f7EEYMDH8B1rTPbxKYNGVDS2Zz8fZHEqqwQQOMfMkNOq/yVlFbSAuaRqAy2UzNYT
         cCdA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=PVFA16fPab14F0anc6dqP0hd/bRvwu2w6Thhi/SlaUU=;
        b=ASCstkHfXZ0o0wz/X4GcM6A3Me74nYTnn5QWTxocvZ5HQDvlOXtSkP5cptQ5oniWp/
         oYzka/+hzZ0pk7dYNr475mZQKDhY/dUrx2YYtoc4McDnTpBLxo1qg2vYznKhOlZOYdf2
         9BjsYwFjBmbwvSuq3JsezBd+c0jxWbwXYUP12/6koA4XGWQm1r/sktOWzINLpFJLxLoO
         iBEnOM0tG7Rm/HKXO3hgqxS6TSxhVrPdqdFhK0MpnRqL2Zjyw/w0eMxrq9YeQVcX8TuA
         XvhbCxbnp4fbksbxixSiydmqHgWSPJwZolmBJmUOL35KuKjvPFRGM+aihDGgZzmax7i/
         hKdg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=fhfcX3vp;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id k21si673929pgb.514.2019.02.13.16.00.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 13 Feb 2019 16:00:02 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=fhfcX3vp;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=PVFA16fPab14F0anc6dqP0hd/bRvwu2w6Thhi/SlaUU=; b=fhfcX3vpU0XvRHaFptsnAOzMN
	U7/tNjNCx17+KO2tYnVSm+VQmM2Zko7tMmLLa3xlAZZ6JfkSjAUzDjq5VUGL/KawSLADoMRjUaxYI
	3Ui49mEEKe/FPcXLrEvnyY2uylokjAdpPCbbZ9RzgAcFLbsNrjEkKFo9iIfo5LxD4EGEQjEmTYPEb
	QGLtCnH2up4h/wn14ImrAAqrECuAY1EnO5IoxmNdkY1Zec2HNtQ9gnGRLu5tx71ZG4NnpbeGaCccy
	EX7+3GNuCHZDz+2WXyEEB5kc8RAT6ezK/G3g70qPEXgDV5oz9O3+8uj88i3PIZx3V0Ew94/r+N9Ak
	ZOZsB07AA==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1gu4Rc-0005fL-5B; Thu, 14 Feb 2019 00:00:00 +0000
Date: Wed, 13 Feb 2019 15:59:59 -0800
From: Matthew Wilcox <willy@infradead.org>
To: Song Liu <songliubraving@fb.com>
Cc: "lsf-pc@lists.linux-foundation.org" <lsf-pc@lists.linux-foundation.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	linux-raid <linux-raid@vger.kernel.org>,
	"bpf@vger.kernel.org" <bpf@vger.kernel.org>,
	"linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
	"Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [LSF/MM TOPIC] (again) THP for file systems
Message-ID: <20190213235959.GX12668@bombadil.infradead.org>
References: <77A00946-D70D-469D-963D-4C4EA20AE4FA@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <77A00946-D70D-469D-963D-4C4EA20AE4FA@fb.com>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Feb 13, 2019 at 10:00:10PM +0000, Song Liu wrote:
> I would like to discuss remaining work to bring THP to (non-tmpfs) file systems.
> This topic has been discussed multiple times in previous LSF/MM summits [1][2].
> However, there hasn't been much progress since late 2017 (the latest work I can
> find is by Kirill A. Shutemov [3]).

... this was literally just discussed.

Feel free to review
https://lore.kernel.org/lkml/20190212183454.26062-1-willy@infradead.org/

with particular reference to the last three paragraphs of
https://lore.kernel.org/lkml/20190208042448.GB21860@bombadil.infradead.org/

> Therefore, we would like discuss (for one more time) what is needed to bring
> THP to file systems like ext4, xfs, btrfs, etc. Once we are aligned on the
> direction, we are more than happy to commit time and resource to make it happen.

I believe the direction is clear.  It needs people to do the work.
We're critically short of reviewers.  I got precious little review of
the original XArray work, which made Andrew nervous and delayed its
integration.  Now I'm getting little review of the followup patches
to lay the groundwork for filesystems to support larger page sizes.
I have very little patience for this situation.

