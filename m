Return-Path: <SRS0=FSMz=T5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_HIGH
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 87FF2C28CC2
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 13:14:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 259CE21734
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 13:14:54 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="NtZbITyh"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 259CE21734
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 854FE6B000D; Wed, 29 May 2019 09:14:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 805186B0010; Wed, 29 May 2019 09:14:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 71BFB6B0266; Wed, 29 May 2019 09:14:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3CAB66B000D
	for <linux-mm@kvack.org>; Wed, 29 May 2019 09:14:53 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id 11so1841143pfb.4
        for <linux-mm@kvack.org>; Wed, 29 May 2019 06:14:53 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:to:to:cc:cc:cc:cc:cc
         :cc:cc:subject:in-reply-to:references:message-id;
        bh=2QLlYUo3yDINOwox4iowVyYZx+7dH05my2U03N0Ji1w=;
        b=L10VKIgG6wcUbisj9QHShKVVisVJ6qTc2UNziNV+/oeIFFpRfUV1rKtZmHvazhcQMM
         k1TGe+WAPlC2HaJ8Sl/Xz0UOtDVATL9yLbBt+IHc9b7Hmek+NEMyqS9Uv22ousmWZ5lU
         Y4bPubm8nO0Uy0/uy7AO9rXG3mQ22+n1Bz9NB8XxaIo/n9THSNudEBg0b0wVlV+X39iu
         t11KnqK5ycTLQayG6xBB1vkPcnEpRKeIfUp77Ih1qFp3QI+3FagSGttwvqZ+YB8mxFsW
         8oyBW/RyqxQPY2RVKiEDckXDVujXE2Fgb4vUMvCov0URfQful5pdZv+mq/bzs4in8sTQ
         v30g==
X-Gm-Message-State: APjAAAUhRTCx6WWsipbafxx/Z2/9IId69HI3hDbxj7PY94g6x4sXOqR0
	g1qyNqxGjN/HByCYgJJZKRxA6yhsOp+hADRtgmYkDAXopmFzfDA3c1imO+56qwSmVtEXVhiMgl2
	yOgBApQYIXWZpn4tao0+7Nz+swwAq6BRmY1j6JwUh/2PD6S9BvEabQ2omNhB79dEmmA==
X-Received: by 2002:a17:902:b949:: with SMTP id h9mr94930611pls.50.1559135692756;
        Wed, 29 May 2019 06:14:52 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyBJclGLzA8H0i1QfSu+eQ+d/dcanANLxuduSaU1kEBG+pVU9kscP710sc+UksNQhq0zBXE
X-Received: by 2002:a17:902:b949:: with SMTP id h9mr94930503pls.50.1559135691711;
        Wed, 29 May 2019 06:14:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559135691; cv=none;
        d=google.com; s=arc-20160816;
        b=jmZ9bwacZtHumoqz+vTads0ArwLz/e0d7EWu9C464J7l5q7mbTgemMFBBfBzz2YpDm
         WyALNg/6hi8f/iXNDVuYxvrWpjaH7NG3Ah08lRFGN1a+RbWzn0+PSUDfmOKRwHNfTXhi
         AlYXM/A7BHc8wzP4Bw0+OYJ3nfIlgfBzAix85/u78Oh013oDoxNWXaoarWJSAdPLBVI4
         xwMPa4kY4XWZJ1GRWqFRLStvYntGKbtPbcDN3W+3ionFtaemqknLTAGtS/kX7DhmwbXJ
         2Ct8M5Ln36m/zoN5kwQL+voTZf7LfdRmv9M8+czJSMJQe+FD+g0e+xxJI8SM83lpXB/3
         iV1w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:references:in-reply-to:subject:cc:cc:cc:cc:cc:cc:cc:to
         :to:to:from:date:dkim-signature;
        bh=2QLlYUo3yDINOwox4iowVyYZx+7dH05my2U03N0Ji1w=;
        b=SGPJ+IobXHsB5t5JggVeUFZMYWmy775pPAbE7Dc0l30hb/9O3csjfHAXR0lbh3W7lS
         FszMt7Z6bffqkk1WOTraccsGByskT0p696rLNpvIQEhrcxYe63VC7urf/zfW0xU9K4Ge
         jqsyFu0C4iw9UcarII5+nxjg2MRaKnk/TMeIVLPZeeeEfm8jXeulaEYKIr+59nBogtzb
         GqTAZrfJiDaC8jrdLYXYTml0YpwlDTgtVKVtvOefv57LCZU6gqvU0V8f8GA+lzeIuchu
         OtHGDQ3tgO2a30j5KwPn6bjFFh0DWP6058biBygrqU87ky+GQX9hYALs1k6VYECcMz9V
         BN3A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=NtZbITyh;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id gn18si9757139plb.273.2019.05.29.06.14.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 May 2019 06:14:51 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=NtZbITyh;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from localhost (unknown [23.100.24.84])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 0599B205F4;
	Wed, 29 May 2019 13:14:50 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1559135691;
	bh=TH0+Cn1CVS4kDMZfvBNkCU2G3eHOI42o2f7LDWTZbTI=;
	h=Date:From:To:To:To:Cc:Cc:Cc:Cc:Cc:Cc:Cc:Subject:In-Reply-To:
	 References:From;
	b=NtZbITyhIMzRUtnLPvk4vNamSem4JBBGiT8KFVRm9GQYLAsFcwpXPoJE7NvPPefxr
	 Jlvu6wsW2pNzg4K7Ry6C0vlkLXohRRQ35PPYYjd25YlcJgbjYh3AG4U970Ct8CcDiK
	 GZTJ7bPSkNeeb2bMGzxywH/iBvxC+1ZRblobU+Es=
Date: Wed, 29 May 2019 13:14:49 +0000
From: Sasha Levin <sashal@kernel.org>
To: Sasha Levin <sashal@kernel.org>
To: Jiri Slaby <jslaby@suse.cz>
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org,
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: <cgroups@vger.kernel.org>
Cc: <stable@vger.kernel.org>
Cc: <linux-mm@kvack.org>
Cc: Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>
Cc: stable@vger.kernel.org
Subject: Re: [PATCH -resend v2] memcg: make it work on sparse non-0-node systems
In-Reply-To: <20190522091940.3615-1-jslaby@suse.cz>
References: <20190522091940.3615-1-jslaby@suse.cz>
Message-Id: <20190529131451.0599B205F4@mail.kernel.org>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

[This is an automated email]

This commit has been processed because it contains a "Fixes:" tag,
fixing commit: 60d3fd32a7a9d list_lru: introduce per-memcg lists.

The bot has tested the following trees: v5.1.4, v5.0.18, v4.19.45, v4.14.121, v4.9.178, v4.4.180.

v5.1.4: Build OK!
v5.0.18: Build OK!
v4.19.45: Build OK!
v4.14.121: Failed to apply! Possible dependencies:
    0200894d11551 ("new helper: destroy_unused_super()")
    2b3648a6ff83b ("fs/super.c: refactor alloc_super()")
    39887653aab4c ("mm/workingset.c: refactor workingset_init()")
    8e04944f0ea8b ("mm,vmscan: Allow preallocating memory for register_shrinker().")
    c92e8e10cafea ("fs: propagate shrinker::id to list_lru")

v4.9.178: Failed to apply! Possible dependencies:
    0200894d11551 ("new helper: destroy_unused_super()")
    14b468791fa95 ("mm: workingset: move shadow entry tracking to radix tree exceptional tracking")
    2b3648a6ff83b ("fs/super.c: refactor alloc_super()")
    39887653aab4c ("mm/workingset.c: refactor workingset_init()")
    4d693d08607ab ("lib: radix-tree: update callback for changing leaf nodes")
    6d75f366b9242 ("lib: radix-tree: check accounting of existing slot replacement users")
    8e04944f0ea8b ("mm,vmscan: Allow preallocating memory for register_shrinker().")
    c92e8e10cafea ("fs: propagate shrinker::id to list_lru")
    f4b109c6dad54 ("lib: radix-tree: add entry deletion support to __radix_tree_replace()")
    f7942430e40f1 ("lib: radix-tree: native accounting of exceptional entries")

v4.4.180: Failed to apply! Possible dependencies:
    0200894d11551 ("new helper: destroy_unused_super()")
    0cefabdaf757a ("mm: workingset: fix premature shadow node shrinking with cgroups")
    0e749e54244ee ("dax: increase granularity of dax_clear_blocks() operations")
    14b468791fa95 ("mm: workingset: move shadow entry tracking to radix tree exceptional tracking")
    162453bfbdf4c ("mm: workingset: separate shadow unpacking and refault calculation")
    2b3648a6ff83b ("fs/super.c: refactor alloc_super()")
    39887653aab4c ("mm/workingset.c: refactor workingset_init()")
    52db400fcd502 ("pmem, dax: clean up clear_pmem()")
    612e44939c3c7 ("mm: workingset: eviction buckets for bigmem/lowbit machines")
    689c94f03ae25 ("mm: workingset: #define radix entry eviction mask")
    6e4eab577a0ca ("fs: Add user namespace member to struct super_block")
    8e04944f0ea8b ("mm,vmscan: Allow preallocating memory for register_shrinker().")
    ac401cc782429 ("dax: New fault locking")
    b2e0d1625e193 ("dax: fix lifetime of in-kernel dax mappings with dax_map_atomic()")
    c92e8e10cafea ("fs: propagate shrinker::id to list_lru")
    d91ee87d8d85a ("vfs: Pass data, ns, and ns->userns to mount_ns")
    e4b2749158631 ("DAX: move RADIX_DAX_ definitions to dax.c")
    f7942430e40f1 ("lib: radix-tree: native accounting of exceptional entries")
    f9fe48bece3af ("dax: support dirty DAX entries in radix tree")


How should we proceed with this patch?

--
Thanks,
Sasha

