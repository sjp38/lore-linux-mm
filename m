Return-Path: <SRS0=luIg=QH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 250ACC169C4
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 14:12:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DAA07218DA
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 14:12:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="s68DREDN"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DAA07218DA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7A0FF8E0003; Thu, 31 Jan 2019 09:12:40 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 750B08E0001; Thu, 31 Jan 2019 09:12:40 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 666E18E0003; Thu, 31 Jan 2019 09:12:40 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 266CC8E0001
	for <linux-mm@kvack.org>; Thu, 31 Jan 2019 09:12:40 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id c14so2416193pls.21
        for <linux-mm@kvack.org>; Thu, 31 Jan 2019 06:12:40 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:to:to:cc:cc:cc
         :subject:in-reply-to:references:message-id;
        bh=U9TVDa6imypSWq+pHDN44PLBOtiVUrmx0fR+6hRP9AM=;
        b=N8pGhAJUvUczWe+xzS2c7UWj6PfOJHeor5eCRztcCaFmqyhwkrS8tG7O2Szox+y9Db
         AN29cJ0sPoTbemR+fvnGHYE/tDwzB6rBiLZNzUt3HUkgQawq8COLS6V/klKS2dSsnYRN
         BjAPg2IyrZ8CxjjacndshTAaFDwseU8ITgAMo98aKYCDP2MdbBvbRQ861Gpm9jYCBJi3
         Hh36/sTgc5dqBWttB9QIzFHMoriU8j5pheERZsMNOGpoIV0XE3r2JokrT4aZbk2dqHYY
         CSCW/a+sVR+xlw2CPnAarAoGEGadCmj3PC0XEquKUSGop12DQlwIauUO4onwF10pDdoZ
         Vj7w==
X-Gm-Message-State: AJcUukdGOBJPKk2yEKTSKVRiXbcggz7Oe9Yde8H3nBr5GENaWnzdUZX2
	3vlf2xtUldmd1dcbNSUs5igbb1oq8i9y+1C8qYeeyfE+dg5+xfQ6gU5qrQT9elnSQPHKA1iHC+M
	F8DNvwD7LFPNba3wrXrZ2qICJp+3rrxxjR06XYngl2Eq2usoEhUuKGd7izjf82/mLPA==
X-Received: by 2002:a62:8985:: with SMTP id n5mr35380515pfk.255.1548943959763;
        Thu, 31 Jan 2019 06:12:39 -0800 (PST)
X-Google-Smtp-Source: ALg8bN6UEpv8z5uL7qCKmo6030wVHbmz8cFeVqWRqa/6MqnxkWSxxEtDoWxZSIPs73oTLaYuTx5N
X-Received: by 2002:a62:8985:: with SMTP id n5mr35380467pfk.255.1548943959012;
        Thu, 31 Jan 2019 06:12:39 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548943958; cv=none;
        d=google.com; s=arc-20160816;
        b=wza/VLutgmLU+hrI7qIdPBaxO7XIC7ykFlR2bMvs4mJaqpobQFbTdlI+fQH3uVNEOv
         fVQ8NfEtHKKVRW/6x3TfUlQCmgGIIlvwTFjSpY+ZqDXzdy30GTIGgSl7dQWvR6hnBfCd
         Bu9pZG13YCSQjjoIe6/bU6jOnAnMxSgvaVG3HfIASuLaesXRoori6hOlt2rKVOU4Chdp
         jJgOtvFpqRsGebd3q7up4s/mdd9hNrd/J7qeqh8JL7L0a7MxRdncQyBUote7tX8e0OUP
         ckP0JQkZaWiUup84BK5puC/tUZ+HxEV0mGgxu49npMOt7RqvDgi1CUE9UTB2lgHNJGAm
         vAuQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:references:in-reply-to:subject:cc:cc:cc:to:to:to:from
         :date:dkim-signature;
        bh=U9TVDa6imypSWq+pHDN44PLBOtiVUrmx0fR+6hRP9AM=;
        b=m/Rg5/btqm77R6hBjHYBZuocaCeXoCNSFaVZpL2fVZqKEXuHHT2b9fp93T5mhAjzIC
         SFxY+SVM9KZ/DD7d/fpdYuz3f1fe/kxiCgWIWukNrXqkqG00M6lLPrOHgwfEH1bWdtOu
         djyuGhZA8QmBx2dDRaWFoqw6ZrJYS7As5QdBV5NN/Rg9GIAu5kXhJkwBIZrTAbgkN40F
         vtmSW8mDow6vA+O3e0SdwULQixvpPa5XOuQZuYVrf7Q0iLgGoheQHlCue14wVoNKRn49
         DlWZUQSqowUYc8+bExHBBVp9f0NTvUVVWB1bXr3xQX7E+Ovz7l5brXMuINvjj+6Cm2pl
         v4CQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=s68DREDN;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id w67si4448181pgw.84.2019.01.31.06.12.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 31 Jan 2019 06:12:38 -0800 (PST)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=s68DREDN;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from localhost (unknown [23.100.24.84])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 6D6C220881;
	Thu, 31 Jan 2019 14:12:38 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1548943958;
	bh=MI1VddUinR9xNJajpCtcEQ9bm+z/gTKbo2oUFPQ9vEs=;
	h=Date:From:To:To:To:Cc:Cc:Cc:Subject:In-Reply-To:References:From;
	b=s68DREDNPcIwV8jsJcjw8fk11wT1gS2uI3FzOT3r32FJKFSJAzhchPRXWAqfARUaj
	 o1F2E0tT5yy2m0QV5Wf9//hKPhArjTP5zvlXlmtnOHulDv4KVxRlVP9gLpAkdya0y3
	 mDhhvhHAyHCCfEV1EFUz0TK5/UPOXEOEqEPwLjKY=
Date: Thu, 31 Jan 2019 14:12:37 +0000
From: Sasha Levin <sashal@kernel.org>
To: Sasha Levin <sashal@kernel.org>
To:   Mike Kravetz <mike.kravetz@oracle.com>
To:     linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc:     Michal Hocko <mhocko@kernel.org>,
Cc: <stable@vger.kernel.org>
Cc: stable@vger.kernel.org
Subject: Re: [PATCH] huegtlbfs: fix page leak during migration of file pages
In-Reply-To: <20190130211443.16678-1-mike.kravetz@oracle.com>
References: <20190130211443.16678-1-mike.kravetz@oracle.com>
Message-Id: <20190131141238.6D6C220881@mail.kernel.org>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

[This is an automated email]

This commit has been processed because it contains a "Fixes:" tag,
fixing commit: 290408d4a250 hugetlb: hugepage migration core.

The bot has tested the following trees: v4.20.5, v4.19.18, v4.14.96, v4.9.153, v4.4.172, v3.18.133.

v4.20.5: Build OK!
v4.19.18: Build OK!
v4.14.96: Build OK!
v4.9.153: Failed to apply! Possible dependencies:
    2916ecc0f9d4 ("mm/migrate: new migrate mode MIGRATE_SYNC_NO_COPY")

v4.4.172: Failed to apply! Possible dependencies:
    09cbfeaf1a5a ("mm, fs: get rid of PAGE_CACHE_* and page_cache_{get,release} macros")
    0e749e54244e ("dax: increase granularity of dax_clear_blocks() operations")
    2916ecc0f9d4 ("mm/migrate: new migrate mode MIGRATE_SYNC_NO_COPY")
    2a28900be206 ("udf: Export superblock magic to userspace")
    4420cfd3f51c ("staging: lustre: format properly all comment blocks for LNet core")
    48b4800a1c6a ("zsmalloc: page migration support")
    5057dcd0f1aa ("virtio_balloon: export 'available' memory to balloon statistics")
    52db400fcd50 ("pmem, dax: clean up clear_pmem()")
    5b7a487cf32d ("f2fs: add customized migrate_page callback")
    5fd88337d209 ("staging: lustre: fix all conditional comparison to zero in LNet layer")
    a188222b6ed2 ("net: Rename NETIF_F_ALL_CSUM to NETIF_F_CSUM_MASK")
    b1123ea6d3b3 ("mm: balloon: use general non-lru movable page feature")
    b2e0d1625e19 ("dax: fix lifetime of in-kernel dax mappings with dax_map_atomic()")
    bda807d44454 ("mm: migrate: support non-lru movable page migration")
    c8b8e32d700f ("direct-io: eliminate the offset argument to ->direct_IO")
    d1a5f2b4d8a1 ("block: use DAX for partition table reads")
    e10624f8c097 ("pmem: fail io-requests to known bad blocks")

v3.18.133: Failed to apply! Possible dependencies:
    0722b1011a5f ("f2fs: set page private for inmemory pages for truncation")
    1601839e9e5b ("f2fs: fix to release count of meta page in ->invalidatepage")
    2916ecc0f9d4 ("mm/migrate: new migrate mode MIGRATE_SYNC_NO_COPY")
    31a3268839c1 ("f2fs: cleanup if-statement of phase in gc_data_segment")
    34ba94bac938 ("f2fs: do not make dirty any inmemory pages")
    34d67debe02b ("f2fs: add infra struct and helper for inline dir")
    4634d71ed190 ("f2fs: fix missing kmem_cache_free")
    487261f39bcd ("f2fs: merge {invalidate,release}page for meta/node/data pages")
    5b7a487cf32d ("f2fs: add customized migrate_page callback")
    67298804f344 ("f2fs: introduce struct inode_management to wrap inner fields")
    769ec6e5b7d4 ("f2fs: call radix_tree_preload before radix_tree_insert")
    7dda2af83b2b ("f2fs: more fast lookup for gc_inode list")
    8b26ef98da33 ("f2fs: use rw_semaphore for nat entry lock")
    8c402946f074 ("f2fs: introduce the number of inode entries")
    9be32d72becc ("f2fs: do retry operations with cond_resched")
    9e4ded3f309e ("f2fs: activate f2fs_trace_pid")
    d5053a34a9cc ("f2fs: introduce -o fastboot for reducing booting time only")
    e5e7ea3c86e5 ("f2fs: control the memory footprint used by ino entries")
    f68daeebba5a ("f2fs: keep PagePrivate during releasepage")


How should we proceed with this patch?

--
Thanks,
Sasha

