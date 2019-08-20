Return-Path: <SRS0=/Q+j=WQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 65C78C3A589
	for <linux-mm@archiver.kernel.org>; Tue, 20 Aug 2019 15:16:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 271B7216F4
	for <linux-mm@archiver.kernel.org>; Tue, 20 Aug 2019 15:16:46 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="n27ESrMg"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 271B7216F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C6D0C6B0006; Tue, 20 Aug 2019 11:16:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C1E3D6B000A; Tue, 20 Aug 2019 11:16:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B34C46B000C; Tue, 20 Aug 2019 11:16:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0020.hostedemail.com [216.40.44.20])
	by kanga.kvack.org (Postfix) with ESMTP id 90E496B0006
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 11:16:45 -0400 (EDT)
Received: from smtpin29.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 4E46B908B
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 15:16:45 +0000 (UTC)
X-FDA: 75843158370.29.iron68_1dce0ba4dc30e
X-HE-Tag: iron68_1dce0ba4dc30e
X-Filterd-Recvd-Size: 4341
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by imf47.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 15:16:44 +0000 (UTC)
Received: from localhost (unknown [40.117.208.15])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 6890A216F4;
	Tue, 20 Aug 2019 15:16:43 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1566314203;
	bh=ZJFP8htDlwZFVjYkf1uFTDjyJ/+1wk3SCOLTaEPbEc0=;
	h=Date:From:To:To:To:Cc:Cc:Cc:Subject:In-Reply-To:References:From;
	b=n27ESrMggJaa9YnLk3VMV934aaJbKrfeLCWxaGGCdPxpKcOnPTE9pAPiHyX19xTVC
	 ZPeLkbgYo5xVkwLKSzieUjqHHCURM8ab30ILtKBCcWHvcJf4BC/iuW9oZs+LNxoHwz
	 1aEijvEUEAvGBqGiplZZG4R0q16HBxnKIv2xYK/Y=
Date: Tue, 20 Aug 2019 15:16:42 +0000
From: Sasha Levin <sashal@kernel.org>
To: Sasha Levin <sashal@kernel.org>
To: Vlastimil Babka <vbabka@suse.cz>
To: linux-mm@kvack.org,
Cc: linux-kernel@vger.kernel.org,
Cc: stable@vger.kernel.org
Cc: stable@vger.kernel.org
Subject: Re: [PATCH v2 1/4] mm, page_owner: handle THP splits correctly
In-Reply-To: <20190820131828.22684-2-vbabka@suse.cz>
References: <20190820131828.22684-2-vbabka@suse.cz>
Message-Id: <20190820151643.6890A216F4@mail.kernel.org>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

[This is an automated email]

This commit has been processed because it contains a "Fixes:" tag,
fixing commit: a9627bc5e34e mm/page_owner: introduce split_page_owner and replace manual handling.

The bot has tested the following trees: v5.2.9, v4.19.67, v4.14.139, v4.9.189.

v5.2.9: Build OK!
v4.19.67: Failed to apply! Possible dependencies:
    426dcd4b600f ("hexagon: switch to NO_BOOTMEM")
    46515fdb1adf ("ixgbe: move common Rx functions to ixgbe_txrx_common.h")
    57c8a661d95d ("mm: remove include/linux/bootmem.h")
    6471f52af786 ("alpha: switch to NO_BOOTMEM")
    98fa15f34cb3 ("mm: replace all open encodings for NUMA_NO_NODE")
    d0bcacd0a130 ("ixgbe: add AF_XDP zero-copy Rx support")
    e0a9317d9004 ("hexagon: use generic dma_noncoherent_ops")
    f406f222d4b2 ("hexagon: implement the sync_sg_for_device DMA operation")

v4.14.139: Failed to apply! Possible dependencies:
    01417c6cc7dc ("powerpc/64: Change soft_enabled from flag to bitmask")
    0b63acf4a0eb ("powerpc/64: Move set_soft_enabled() and rename")
    1696d0fb7fcd ("powerpc/64: Set DSCR default initially from SPR")
    1af19331a3a1 ("powerpc/64s: Relax PACA address limitations")
    4890aea65ae7 ("powerpc/64: Allocate pacas per node")
    4e26bc4a4ed6 ("powerpc/64: Rename soft_enabled to irq_soft_mask")
    8e0b634b1327 ("powerpc/64s: Do not allocate lppaca if we are not virtualized")
    98fa15f34cb3 ("mm: replace all open encodings for NUMA_NO_NODE")
    9f83e00f4cc1 ("powerpc/64: Improve inline asm in arch_local_irq_disable")
    b5c1bd62c054 ("powerpc/64: Fix arch_local_irq_disable() prototype")
    c2e480ba8227 ("powerpc/64: Add #defines for paca->soft_enabled flags")
    ff967900c9d4 ("powerpc/64: Fix latency tracing for lazy irq replay")

v4.9.189: Failed to apply! Possible dependencies:
    010426079ec1 ("sched/headers: Prepare for new header dependencies before moving more code to <linux/sched/mm.h>")
    2077be6783b5 ("arm64: Use __pa_symbol for kernel symbols")
    39bc88e5e38e ("arm64: Disable TTBR0_EL1 during normal kernel execution")
    3f07c0144132 ("sched/headers: Prepare for new header dependencies before moving code to <linux/sched/signal.h>")
    68db0cf10678 ("sched/headers: Prepare for new header dependencies before moving code to <linux/sched/task_stack.h>")
    7c0f6ba682b9 ("Replace <asm/uaccess.h> with <linux/uaccess.h> globally")
    869dcfd10dfe ("arm64: Add cast for virt_to_pfn")
    9164bb4a18df ("sched/headers: Prepare to move 'init_task' and 'init_thread_union' from <linux/sched.h> to <linux/sched/task.h>")
    98fa15f34cb3 ("mm: replace all open encodings for NUMA_NO_NODE")
    9cf09d68b89a ("arm64: xen: Enable user access before a privcmd hvc call")
    bd38967d406f ("arm64: Factor out PAN enabling/disabling into separate uaccess_* macros")


NOTE: The patch will not be queued to stable trees until it is upstream.

How should we proceed with this patch?

--
Thanks,
Sasha

