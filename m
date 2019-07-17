Return-Path: <SRS0=+T2N=VO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3F9A4C7618F
	for <linux-mm@archiver.kernel.org>; Wed, 17 Jul 2019 15:14:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EC0DD2184E
	for <linux-mm@archiver.kernel.org>; Wed, 17 Jul 2019 15:14:07 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="OC6gP2ow"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EC0DD2184E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8C7696B0003; Wed, 17 Jul 2019 11:14:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 878F06B000C; Wed, 17 Jul 2019 11:14:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7670D8E0001; Wed, 17 Jul 2019 11:14:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4DA266B0003
	for <linux-mm@kvack.org>; Wed, 17 Jul 2019 11:14:07 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id g21so14622211pfb.13
        for <linux-mm@kvack.org>; Wed, 17 Jul 2019 08:14:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:to:to:cc:cc:cc:cc:cc
         :cc:cc:subject:in-reply-to:references:message-id;
        bh=RuIfP/Kyd5QUstidhHOXhVTrHF1M8Ek8CzX8iyB4Wu4=;
        b=Whrw8A8MwR9WnwR1wGpatpdFiUuw17CnWznj/omuRSiycZfmhlj4ZHZ533mHmeyS88
         BHNhPrP+yP8YyvAkPaaD9VWuaElgI6WYBDVX06ZhGRG5BbDFBhfVX+YQEd6mpgY9eDqO
         Ii/lgltuNLKRLo9z3pyxV8OnlZPaX0XobOdG2GPFBYY0LA6DvjG6EeqhMe1Y537U1+T2
         vPlzCvwu9bmnqE6GX9XMVXbgH6epAuugmYreTLfybmafgKlKn6lyR6yMcOHYyZDUnzw6
         XipdIVEw0rIofuwfISH6p5I0m1nL1HRm65WpL0ifnRx5q4pXA5mLyVZ9i+yT0mxD4Bos
         lubg==
X-Gm-Message-State: APjAAAXDtexpnz76OQP7LlIAnKnt7ApSxjLJKnwcK4o9gMiFqVFAEdZr
	EuY74ul0HAp10I9PBL/W0n2CkHkC6EnRYdK8+Vj3FK+a2IQROJaXHkeugaG95P9EQkfmJD7LGBP
	Ojt8tlWXS4wPsVOt9wRNTNkhHjxp64uvv4w4DHm4IDfyTmxvAS0BoS+adYc+nX2ymRQ==
X-Received: by 2002:a17:902:42d:: with SMTP id 42mr41752954ple.228.1563376446940;
        Wed, 17 Jul 2019 08:14:06 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxkQZkHTekGlR85TR75PNaoVsx84mKLBjrFduqdH9VfYQvQCTVHyBvvJKd8GGvrRPiGB5qE
X-Received: by 2002:a17:902:42d:: with SMTP id 42mr41752859ple.228.1563376446003;
        Wed, 17 Jul 2019 08:14:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563376445; cv=none;
        d=google.com; s=arc-20160816;
        b=vHkrdi68QBzc+vrH2qxi+RjXqFKR9cx2xUBwLekAnVlq/0mygoIyp32D8NEIVTHcVM
         4Guj+m0Uu7eTHKP+23h97kY+9RJ60nSOkbrMzIVohrvZCSSCP0Vf4pYIeuX5M/TbVi+x
         rRvwgN6RH5EzR3CNkPvAtnLkBp/QELVOmp6AnmHGtDKFQWUOSIIOMkqthD1xTx8P6tOv
         LmSByO87roJfLM0S9ZlwpAAHLJQMqiEw/X7Po6qMq8zdp2M76lhLCQNfvDqNxrpT40yP
         4rV7mPZYpHxyFpM7z5QKAlxn2yDGeLEt4p6tMw7PFtNj7ao8OEvti+UH1Usk+pCfya5V
         XbiA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:references:in-reply-to:subject:cc:cc:cc:cc:cc:cc:cc:to
         :to:to:from:date:dkim-signature;
        bh=RuIfP/Kyd5QUstidhHOXhVTrHF1M8Ek8CzX8iyB4Wu4=;
        b=Sci5PqvuQyr6Yb9mKFnP61gM0wBx/pqX6L9THXGIqUo5MC5pfI0VgFDRheXPMRTkYC
         W8Nf0K33GvS1FUeSqvUB+gO5u9jBue09IcvaLCqvdxRMHW159zsJHgEuHc3ve43JQP9B
         SRbLwAvT3aOqwAcEKIJYnFkqc8Iuba91Er61Yw47W/uOvBo5SxPtUbPS18NQwcKzOFCU
         /PBz3/tc4w2BLhfuUdch8qAEPHn4rdfhcivDkPyQslWaErVufj4Yki2o1+aF/fcKCHEb
         UOEJ1KkE8yMUdmUlloedZ5vVrRhK8McdKwUTciaXbsS5A4JIzPlNIqZF4oplsnW87rRD
         Shvw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=OC6gP2ow;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id t191si24370075pgd.370.2019.07.17.08.14.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Jul 2019 08:14:05 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=OC6gP2ow;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from localhost (unknown [23.100.24.84])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 759AB21841;
	Wed, 17 Jul 2019 15:14:05 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1563376445;
	bh=aInrbX5qxpHP++gY/qZsLEvnaPPN4DnxOPIFesgSYyI=;
	h=Date:From:To:To:To:CC:Cc:Cc:Cc:Cc:Cc:Cc:Subject:In-Reply-To:
	 References:From;
	b=OC6gP2owJZvIYhbaTB8FRWCUgKI2OQwAsL6Cbp4xPBOuM5ZDf/vT/lSjbD1LrJ/gi
	 dJzqL2GbXntslQxJo6R0HH9aPgj7dRpvz1Mt9dgi4Cwc/VS0dadog1N9BdyS3IMSPK
	 sxcNWczrchfA1khTRAFLv9bGOnxDEZdaVtGG661g=
Date: Wed, 17 Jul 2019 15:14:04 +0000
From: Sasha Levin <sashal@kernel.org>
To: Sasha Levin <sashal@kernel.org>
To: Ralph Campbell <rcampbell@nvidia.com>
To: <linux-mm@kvack.org>
CC: <linux-kernel@vger.kernel.org>, Ralph Campbell <rcampbell@nvidia.com>,
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Mike Kravetz <mike.kravetz@oracle.com>
Cc: Christoph Hellwig <hch@lst.de>
Cc: Jason Gunthorpe <jgg@mellanox.com>
Cc: <stable@vger.kernel.org>
Cc: stable@vger.kernel.org
Subject: Re: [PATCH 3/3] mm/hmm: Fix bad subpage pointer in try_to_unmap_one
In-Reply-To: <20190717001446.12351-4-rcampbell@nvidia.com>
References: <20190717001446.12351-4-rcampbell@nvidia.com>
Message-Id: <20190717151405.759AB21841@mail.kernel.org>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

[This is an automated email]

This commit has been processed because it contains a "Fixes:" tag,
fixing commit: a5430dda8a3a mm/migrate: support un-addressable ZONE_DEVICE page in migration.

The bot has tested the following trees: v5.2.1, v5.1.18, v4.19.59, v4.14.133.

v5.2.1: Build OK!
v5.1.18: Build OK!
v4.19.59: Build OK!
v4.14.133: Failed to apply! Possible dependencies:
    0f10851ea475 ("mm/mmu_notifier: avoid double notification when it is useless")


NOTE: The patch will not be queued to stable trees until it is upstream.

How should we proceed with this patch?

--
Thanks,
Sasha

