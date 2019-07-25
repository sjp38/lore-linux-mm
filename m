Return-Path: <SRS0=Q21e=VW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DC4E9C76186
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 02:03:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A1CD522387
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 02:03:43 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="RzkjMoPL"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A1CD522387
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 348D48E0022; Wed, 24 Jul 2019 22:03:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2D28E8E001C; Wed, 24 Jul 2019 22:03:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1730E8E0022; Wed, 24 Jul 2019 22:03:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id DFE348E001C
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 22:03:42 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id n4so24797930plp.4
        for <linux-mm@kvack.org>; Wed, 24 Jul 2019 19:03:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:to:to:cc:cc:cc:cc:cc
         :cc:cc:cc:subject:in-reply-to:references:message-id;
        bh=FxhxY7Kn1uJ+k0ZNnnc5WKY/A7tH9qvVLK2CnuEsOHI=;
        b=Uu1O6S99BBALSJD5vBKnZfnn+rU1wEPY9mEaZNIdT/qA1/VRHiOAoD4KEUiKf5kSXT
         kvF/hn5NAsSXPrXEmcZXX4v6NDa6ZhgoXt+7UPGAtaFc/sL1jx83PvafFpVNpGX8vvzF
         BvU/7DS3uDsD7DP7lPwtVRNjed/ZDe6+q4ShtVNojUkL+dVf4SCxwVjIVC0JkB8U4qzG
         lPAd4FhoXyhUNNLpUfC462DakBI455o0YYBgX2+xUKCK14um/DQrFlOjlamatNx42ho8
         9ve4ak7FsQf6GXge123CyFq5I+D5UZ1NbS2pZP5O6Db7Ks0l5vlNaUFb7zGfhAKeQ3Aj
         ia3A==
X-Gm-Message-State: APjAAAVm7CJaVOkaPImRLNXtu02UnUF/Zq+KxoBk0BPEBjXyY4IqhWAO
	WVmPRwzQNhxGcJHISG0KzS02uhASZTj7XypZMlN5Igi8ah00go/O+yIsHFLrNKPOnsDwDpWO47S
	yGNkAwiaIKEaSAS/4Je6PmWGofSsyK2U3Q1kEeO4X2YE4v2A5b2FbN4rP1LXuo6UB2Q==
X-Received: by 2002:a17:90a:5806:: with SMTP id h6mr87879542pji.126.1564020222487;
        Wed, 24 Jul 2019 19:03:42 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw6Gw5dUljG7obNHY8jbGuXkTNvtYx6d/UNZk9MW2Uk8mcv+JTZ9ewH47KCh7BNZwptpifV
X-Received: by 2002:a17:90a:5806:: with SMTP id h6mr87879478pji.126.1564020221539;
        Wed, 24 Jul 2019 19:03:41 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564020221; cv=none;
        d=google.com; s=arc-20160816;
        b=fnE86wx2HnSc9f7omw7GEKQ3WZgwdJhdxy6NDKGJpDJewx3+sov3Mc9pyNXYxr0jf1
         NBc2TAsqzSqnS7Pyb4PcH8HBb3U349zh22iXXTUuh/DTvaSA0M3INvXRmOfsSYTSFFVL
         S2EGCBxDYfLZE0zBVahdHwjLDtfBME/+7+XLq995k+Cn5ARavRmiGpJcb4TeC0CUVEbd
         BpVhbRKYmVqp/EGUyipo22eVBJR5RCDe8bjKYYW8Hb3auoNOYyrx3q2ekydrrdh3uTMo
         yPxzPjV2IfiC/gQDJYEPqvlLvw+CldS678FffXC9M48TAw9YLl1Cvh38hkK5hAY/P54k
         01sg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:references:in-reply-to:subject:cc:cc:cc:cc:cc:cc:cc:cc
         :to:to:to:from:date:dkim-signature;
        bh=FxhxY7Kn1uJ+k0ZNnnc5WKY/A7tH9qvVLK2CnuEsOHI=;
        b=uIhrosp950/g1LgiQH9vFEUolJmuDVaYWgy3Jj4l6MY9nEVPD+ehZ433/bIGklsvr4
         Zspv3JQ9iFyh1d0ivWYJxAKKq7Aczr+NGTJ0t0ce5fPXG+bG3I9H9VGwOGLh+73XvYWQ
         GHIqutaNN12rLQ+5BMekrXGS/fuUYSB3PuSs9X00tEIajL6etJN+qdBVHmYOWGg/zflk
         tcBX8L9AuMgSFTjyraBC14ytmUJ7I8RP8UrHBYGXxuK7uU2Vd8o9htxuKGLDUfOeJHH+
         CBcU9FGImB2PHEKpUl0GhV8fHyTsWU4tsuuJXAfShmt51HLOWiiiaZ37NB1oNhWlETNU
         NObg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=RzkjMoPL;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id 189si16843241pgj.416.2019.07.24.19.03.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Jul 2019 19:03:41 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=RzkjMoPL;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from localhost (unknown [23.100.24.84])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id D2EA021951;
	Thu, 25 Jul 2019 02:03:40 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1564020221;
	bh=6BseBO9BTLytaD6ATHn8Qmo+seGh5f/lE/Clqi0CzIo=;
	h=Date:From:To:To:To:CC:Cc:Cc:Cc:Cc:Cc:Cc:Cc:Subject:In-Reply-To:
	 References:From;
	b=RzkjMoPLknuhk8IhxxUU4kFLGYiiqohCKnb/UlJqhNHiJbFF8X0IXTECGz3h/QR2e
	 xHiXTyxt+bwLeiw6h28hB0xiNZVc6HP/enmWylAyZJC/jzstQn1shffNVENF8MxpvL
	 Skh1wvc9uHPEtaibqaeafX25GY6seLIni7P248sI=
Date: Thu, 25 Jul 2019 02:03:39 +0000
From: Sasha Levin <sashal@kernel.org>
To: Sasha Levin <sashal@kernel.org>
To: Ralph Campbell <rcampbell@nvidia.com>
To: <linux-mm@kvack.org>
CC: <linux-kernel@vger.kernel.org>, Ralph Campbell <rcampbell@nvidia.com>,
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Mike Kravetz <mike.kravetz@oracle.com>
Cc: Christoph Hellwig <hch@lst.de>
Cc: Jason Gunthorpe <jgg@mellanox.com>
Cc: John Hubbard <jhubbard@nvidia.com>
Cc: <stable@vger.kernel.org>
Cc: stable@vger.kernel.org
Subject: Re: [PATCH v3 3/3] mm/hmm: Fix bad subpage pointer in try_to_unmap_one
In-Reply-To: <20190724232700.23327-4-rcampbell@nvidia.com>
References: <20190724232700.23327-4-rcampbell@nvidia.com>
Message-Id: <20190725020340.D2EA021951@mail.kernel.org>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

[This is an automated email]

This commit has been processed because it contains a "Fixes:" tag,
fixing commit: a5430dda8a3a mm/migrate: support un-addressable ZONE_DEVICE page in migration.

The bot has tested the following trees: v5.2.2, v5.1.19, v4.19.60, v4.14.134.

v5.2.2: Build OK!
v5.1.19: Build OK!
v4.19.60: Build OK!
v4.14.134: Failed to apply! Possible dependencies:
    0f10851ea475 ("mm/mmu_notifier: avoid double notification when it is useless")


NOTE: The patch will not be queued to stable trees until it is upstream.

How should we proceed with this patch?

--
Thanks,
Sasha

