Return-Path: <SRS0=pjJT=VR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C1D7FC76195
	for <linux-mm@archiver.kernel.org>; Sat, 20 Jul 2019 12:23:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8983A217F5
	for <linux-mm@archiver.kernel.org>; Sat, 20 Jul 2019 12:23:36 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="MD0ud0O4"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8983A217F5
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2E0A76B0007; Sat, 20 Jul 2019 08:23:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 26A228E0003; Sat, 20 Jul 2019 08:23:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0BED96B000A; Sat, 20 Jul 2019 08:23:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id CD35F6B0007
	for <linux-mm@kvack.org>; Sat, 20 Jul 2019 08:23:35 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id f2so17211628plr.0
        for <linux-mm@kvack.org>; Sat, 20 Jul 2019 05:23:35 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:to:to:cc:cc:cc:cc
         :subject:in-reply-to:references:message-id;
        bh=EYhfvDDY6IqspQEGoZec8R3KfhdWZh5hfacKWATQOJM=;
        b=HWdT/K2VtSx3elrRwseo52zZ/domd2LhUKQI/9ZvitCzjyUl50g+zJCN1ftbPN32mq
         lhWq1HSGW4uBlvsQ1ZTkPlFYENQHB0+fRrL6WEMuhtrRJkA7tjVUc6ABiuaLrwfEjf3I
         KtETiH97ROZESumF/0d+KrtKUMxnDZ8aVMjIquaAB+b8JPNQlZFHdJ9oz7jQHCWKKHW3
         XE2szaxmOx+p4YppNlArBkWoRqCRW8oLnhr35V+4MH6s8d0a4GYnj2eVO37QB8QToVha
         PiA9wNgoI9hVCGRHu1E3bgWCiuAQGXja376t80VrdolSiXz2znb+hSCquT4HARsXkwWy
         jq+g==
X-Gm-Message-State: APjAAAUr6P/wwUNk2OBfwoL97c1DZzH7GumBLPssCasgZ59h+hZ1bAmV
	i9TlWQTdCc9BpWY2dn7ASVZImN3Up9MBR2STEj4eGQp+Nm51X1Rt6qFyZHlAULq5b0aSa2Jgodn
	hZ60DsxooxQb/tEZD5V4YtaAz7/+5IaGKDQZkK4Lpdz1vXVX1y0/bh997ScvMNUdMHQ==
X-Received: by 2002:a17:902:6b85:: with SMTP id p5mr59873536plk.225.1563625415325;
        Sat, 20 Jul 2019 05:23:35 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxYD6AyEOvMxHqYwnoXDilZoaE+mK0sEmh1SHm2ctcn0qSb78VOOVG4w6eWb89OCd2vj4VS
X-Received: by 2002:a17:902:6b85:: with SMTP id p5mr59873493plk.225.1563625414701;
        Sat, 20 Jul 2019 05:23:34 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563625414; cv=none;
        d=google.com; s=arc-20160816;
        b=hKwIYjhMSWFYZDcjM8EWsaHddO72ucSmLgTW6f8LJZRrFLCiyIcxm+OrIjH4oIEDdM
         OkwtBawMMXUEdC5rzJ+nzzHbhV6Ub5A3JpaC7aEwqKJ+O8L63VlwsD8Sox3GuH531Lwf
         YicTjXI27iwz3wVMPuVrJC9BjLXVDmtFdwfGpxSeHr5i5yAhszwcS3A7JoJXQFx0U4qQ
         Su5GxBqunmjyyECcT9u2YX6xaBDTxZQRuCcvm0XXMcmGXwNyzyOuh4SIYmTTt8RE1yib
         wecagsNZgIB7X9l44mYm99kFZmR0pQoiNoM8D+wcv4KJFJh08Eb8q6+hd78oqqckEvhg
         cCfA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:references:in-reply-to:subject:cc:cc:cc:cc:to:to:to:from
         :date:dkim-signature;
        bh=EYhfvDDY6IqspQEGoZec8R3KfhdWZh5hfacKWATQOJM=;
        b=mDXRdXibJ/8xmSh+0CZ9vAUj0iJkjmKH1sHp5NgKaZq6rBwwjo2WlBRafSQusl3yKo
         Lo+ikNRK4BWScPhA8s+nwYR3AhxPR2O7qKxFH05N0ShumQ//v8o5y6heFVSd8RlSvf14
         5YvlHj82qmsLArkX+J2miTdg1v/kWKUan42JYCveYVEij+/tBjfdqSUqrq6xIWrH02D4
         N70OdAfFZ6J8aUAqOGSxYitRJ6Me9kxj5yI4eimh+GDZmag2aHTZduuURiY6acM72HB7
         p/NM5Q0A6h+b6FvgEWjtAY4vsrWLt8naEI9AjedJOI+huh1267vhnusJj3Fn0rPw3ZKX
         WpPg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=MD0ud0O4;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id z4si4375312plk.364.2019.07.20.05.23.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 20 Jul 2019 05:23:34 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=MD0ud0O4;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from localhost (unknown [23.100.24.84])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 24ECD2183E;
	Sat, 20 Jul 2019 12:23:34 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1563625414;
	bh=Hw87YVpKuneyFxXD4ilr0afGyoDe8yoC/5gaRvCfXnk=;
	h=Date:From:To:To:To:CC:Cc:Cc:Cc:Subject:In-Reply-To:References:
	 From;
	b=MD0ud0O4wOiL+bjcMXY92p/BRBOv/gvVmbQ6i/q+LDPtr0iElSNIcXd8ys4oR7b2d
	 XhuD9NOwzKt9snOgFh1vi2QJsgDWt0kMWZo4zqrYxuJtuMsCZuPAZqLiNtHMykky6x
	 S7LFOVS5BqImvSN0Z8XI7sDKhZvA6FKyIUuSuTFY=
Date: Sat, 20 Jul 2019 12:23:33 +0000
From: Sasha Levin <sashal@kernel.org>
To: Sasha Levin <sashal@kernel.org>
To: Ralph Campbell <rcampbell@nvidia.com>
To: <linux-mm@kvack.org>
CC: <linux-kernel@vger.kernel.org>, Ralph Campbell <rcampbell@nvidia.com>,
Cc: stable@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: stable@vger.kernel.org
Subject: Re: [PATCH] mm/migrate: initialize pud_entry in migrate_vma()
In-Reply-To: <20190719233225.12243-1-rcampbell@nvidia.com>
References: <20190719233225.12243-1-rcampbell@nvidia.com>
Message-Id: <20190720122334.24ECD2183E@mail.kernel.org>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

[This is an automated email]

This commit has been processed because it contains a "Fixes:" tag,
fixing commit: 8763cb45ab96 mm/migrate: new memory migration helper for use with device memory.

The bot has tested the following trees: v5.2.1, v5.1.18, v4.19.59, v4.14.133.

v5.2.1: Build OK!
v5.1.18: Build OK!
v4.19.59: Failed to apply! Possible dependencies:
    41b4deeaa123 ("RDMA/umem: Make ib_umem_odp into a sub structure of ib_umem")
    597ecc5a0954 ("RDMA/umem: Get rid of struct ib_umem.odp_data")
    5d6527a784f7 ("mm/mmu_notifier: use structure for invalidate_range_start/end callback")
    ac46d4f3c432 ("mm/mmu_notifier: use structure for invalidate_range_start/end calls v2")
    b5231b019d76 ("RDMA/umem: Use ib_umem_odp in all function signatures connected to ODP")
    c9990ab39b6e ("RDMA/umem: Move all the ODP related stuff out of ucontext and into per_mm")
    d4b4dd1b9706 ("RDMA/umem: Do not use current->tgid to track the mm_struct")

v4.14.133: Failed to apply! Possible dependencies:
    155494dbbbf4 ("drm/amdgpu: Update kgd2kfd_shared_resources for dGPU support")
    179c02fe90a4 ("drm/tve200: Add new driver for TVE200")
    1b0c0f9dc5ca ("drm/amdgpu: move userptr BOs to CPU domain during CS v2")
    1b1f42d8fde4 ("drm: move amd_gpu_scheduler into common location")
    1ed3d2567c80 ("drm/amdgpu: keep the MMU lock until the update ends v4")
    3fe89771cb0a ("drm/amdgpu: stop reserving the BO in the MMU callback v3")
    4c660c8fbbf7 ("drm/amdgpu: Add submit IB function for KFD")
    528e083d85bd ("drm/amdgpu: rename rmn to amn in the MMU notifier code (v2)")
    60de1c1740f3 ("drm/amdgpu: use a rw_semaphore for MMU notifiers")
    8cce58fe698a ("drm/amd: add new interface to query cu info")
    93065ac753e4 ("mm, oom: distinguish blockable mode for mmu notifiers")
    9f0a0b41ffcc ("drm/amdgpu: Add support for reporting VRAM usage")
    a216ab09955d ("drm/amdgpu: fix userptr put_page handling")
    a46a2cd103a8 ("drm/amdgpu: Add GPUVM memory management functions for KFD")
    ac46d4f3c432 ("mm/mmu_notifier: use structure for invalidate_range_start/end calls v2")
    b72cf4fca2bb ("drm/amdgpu: move taking mmap_sem into get_user_pages v2")
    ca666a3c298f ("drm/amdgpu: stop using BO status for user pages")
    d8d019ccffb8 ("drm/amdgpu: Add KFD eviction fence")
    e52482dec836 ("drm/amdgpu: Add MMU notifier type for KFD userptr")
    ebdebf428ae6 ("drm/amdgpu: add amdgpu interface to query cu info")


NOTE: The patch will not be queued to stable trees until it is upstream.

How should we proceed with this patch?

--
Thanks,
Sasha

