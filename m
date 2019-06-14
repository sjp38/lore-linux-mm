Return-Path: <SRS0=BXMS=UN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 201ECC31E4D
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 21:56:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D525521873
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 21:56:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="Xc0bQGEe"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D525521873
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 70E1E6B000C; Fri, 14 Jun 2019 17:56:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 697DA6B000D; Fri, 14 Jun 2019 17:56:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 560B86B000E; Fri, 14 Jun 2019 17:56:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1DB476B000C
	for <linux-mm@kvack.org>; Fri, 14 Jun 2019 17:56:39 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id d3so2818778pgc.9
        for <linux-mm@kvack.org>; Fri, 14 Jun 2019 14:56:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:to:to:cc:cc:cc
         :subject:in-reply-to:references:message-id;
        bh=DRenn5JRpDITJT+8WAkhhzqQoIX7nfofPKC6XjXaHW4=;
        b=Yg5s7df7gi8f/xk2b5NmYzNzWUmpjNsyhF30SYsSTnuB9WZXh9N+QopYNhVsczxWhH
         1MD1VDl/0PtuIeQvJd9NbfC6iZd+K58zp5V/j9xmkU10lVpA3zjxY8hd4EFM5nJvp2rT
         IU4z+dz5RJ7SMrLtirwi5AQJm8rPZ/DSs4l/ICORXP5iEgrBnLXL3f/lyOz/8gki42vq
         +8sarLZdycA+frs5b0nmBwP5zKfg2vQl1F1FCHht8hYB+Fc2aftoq9lxlcvZIvgTpZyY
         rvKVqAaDhUGeDesG3nHtAIzZFMfUGHYgPXWdJqSumWmiAAfTKZ0SGbPBE3QgttCIOBx9
         EOlQ==
X-Gm-Message-State: APjAAAXqy58CyC37Es2igotYWSPPCYVYIe4kqq2mE827nBuSfAE4fTXx
	whl4lwJB9ArZOt3eNdHu+xPBVZmHwigqY0AJECjavFVlLWRyY3dBwMXHYQqNcjhEYeR9/WV/nSk
	urxpjs5WxnKZ6MaMf8QBAAQKJX5Oc8/V7E+nxyV3SRT6BeSfY7Fat8BN7ecSH3YEb8Q==
X-Received: by 2002:a17:90a:8d86:: with SMTP id d6mr12632038pjo.127.1560549398730;
        Fri, 14 Jun 2019 14:56:38 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwLYxdSQA64z6wSk7ijKZiL/oh09c5lYWaIXXCs046of9PG6P5Q6CdZeheyWsoUDO019AcA
X-Received: by 2002:a17:90a:8d86:: with SMTP id d6mr12632017pjo.127.1560549398052;
        Fri, 14 Jun 2019 14:56:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560549398; cv=none;
        d=google.com; s=arc-20160816;
        b=KAKuwu70XBXAAgoonBZWqy+ZXlIc6wGG+fkyaBzCcJ1phup8/nk/DU19v4zfigfnMD
         XdpAly2zqerObvff7El65IXKJwchF5WmefhPHeHs5U/rvZ1ARO8v19rsAekxg3A8jR+8
         XeIyLwd42D+QTHzCRws3HRwzLP/BReGgeANE00g+WP+bcd4qsxVc9qlSIJOjASQcmeJj
         MjIFdDA2CzPB7FrTSuKcdJxMqMaHslYxQK0zNGW8z26qzR6JkgTILWp9Ofg40cA+mqjy
         qfv0I/ejyFrPVb9eIOAUUQVK4cldjgoEVoHWOvli0KJ7Rwx4Q2B6HNxRwvRtbXG4yyFq
         GCuQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:references:in-reply-to:subject:cc:cc:cc:to:to:to:from
         :date:dkim-signature;
        bh=DRenn5JRpDITJT+8WAkhhzqQoIX7nfofPKC6XjXaHW4=;
        b=OgZfE355x5ntnOcSF31C1yfDyrCxJ+nf5Z6XNEXaJrCv+F7em9jHZxXxEL7lzD5pP9
         2TrOfvM54sreP3/BPWuegJ8GESez1IToXNPtvb9o3Y9h8bkBbFsnvOt19LXNyoFCQo/h
         4zvBm7D/z7Vi1N5DX8epyIgqvk/c6zzzBznTv0n8F3cjzYX2i1VMPQ8TctGxkg+1mVVG
         8mzT/BUO6YD6sRli9perZZpLnTj+6WvXNrofkcMO+dsf5mlprFI4mE0zMzgquWTvsR9H
         mzjEEyPAmS2OTv9Le5x9XY0YkcSY39dGyHv4/DbijroHoEAfZl9EZl24WKM93bCAJHFO
         0wOg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=Xc0bQGEe;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id a2si3487980pgq.298.2019.06.14.14.56.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Jun 2019 14:56:38 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=Xc0bQGEe;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from localhost (unknown [23.100.24.84])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 7E71521473;
	Fri, 14 Jun 2019 21:56:37 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1560549397;
	bh=S4QtfExTtOz2u5kiFXwsdNdDqX3zQuJFRx8efOBqAj4=;
	h=Date:From:To:To:To:Cc:Cc:Cc:Subject:In-Reply-To:References:From;
	b=Xc0bQGEeOWSG9E8nVni9rn+HzEL8twYZ9anX8Ly/yQQawTp3zYZxb7BaK2BhIdTiW
	 24w7BG9Ms5isR//cOpbT6a2mAPMVYOpDxBlct7SAuOFgFhYlegeUBEqK/jokRVCGNJ
	 0qhxfRxIn+X5Q1M7XeRPRneFyVYYAVzt8dvKLRrg=
Date: Fri, 14 Jun 2019 21:56:36 +0000
From: Sasha Levin <sashal@kernel.org>
To: Sasha Levin <sashal@kernel.org>
To:   Mikhail Zaslonko <zaslonko@linux.ibm.com>
To:     akpm@linux-foundation.org
Cc:     linux-kernel@vger.kernel.org, linux-mm@kvack.org,
Cc: <stable@vger.kernel.org>
Cc: stable@vger.kernel.org
Subject: Re: [PATCH v2 1/1] memory_hotplug: fix the panic when memory end is not on the section boundary
In-Reply-To: <20181105150401.97287-2-zaslonko@linux.ibm.com>
References: <20181105150401.97287-2-zaslonko@linux.ibm.com>
Message-Id: <20190614215637.7E71521473@mail.kernel.org>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

[This is an automated email]

This commit has been processed because it contains a -stable tag.
The stable tag indicates that it's relevant for the following trees: all

The bot has tested the following trees: v5.1.9, v4.19.50, v4.14.125, v4.9.181, v4.4.181.

v5.1.9: Failed to apply! Possible dependencies:
    Unable to calculate

v4.19.50: Failed to apply! Possible dependencies:
    Unable to calculate

v4.14.125: Failed to apply! Possible dependencies:
    4da2ce250f98 ("mm: distinguish CMA and MOVABLE isolation in has_unmovable_pages()")
    da024512a1fa ("mm: pass the vmem_altmap to arch_remove_memory and __remove_pages")
    fb52bbaee598 ("mm: move is_pageblock_removable_nolock() to mm/memory_hotplug.c")

v4.9.181: Failed to apply! Possible dependencies:
    133ff0eac95b ("mm/hmm: heterogeneous memory management (HMM for short)")
    3859a271a003 ("randstruct: Mark various structs for randomization")
    4ef589dc9b10 ("mm/hmm/devmem: device memory hotplug using ZONE_DEVICE")
    5613fda9a503 ("sched/cputime: Convert task/group cputime to nsecs")
    60f3e00d25b4 ("sysv,ipc: cacheline align kern_ipc_perm")
    8c8b73c4811f ("sched/cputime, powerpc: Prepare accounting structure for cputime flush on tick")
    a19ff1a2cc92 ("sched/cputime, powerpc/vtime: Accumulate cputime and account only on tick/task switch")
    b18b6a9cef7f ("timers: Omit POSIX timer stuff from task_struct when disabled")
    b584c2544041 ("powerpc/vmemmap: Add altmap support")
    baa73d9e478f ("posix-timers: Make them configurable")
    c3edc4010e9d ("sched/headers: Move task_struct::signal and task_struct::sighand types and accessors into <linux/sched/signal.h>")
    d3df0a423397 ("mm/hmm: add new helper to hotplug CDM memory region")
    d69dece5f5b6 ("LSM: Add /sys/kernel/security/lsm")
    d7d9b612f1b0 ("powerpc/vmemmap: Reshuffle vmemmap_free()")
    da024512a1fa ("mm: pass the vmem_altmap to arch_remove_memory and __remove_pages")
    fb52bbaee598 ("mm: move is_pageblock_removable_nolock() to mm/memory_hotplug.c")

v4.4.181: Failed to apply! Possible dependencies:
    11a6f6abd74a ("powerpc/mm: Move radix/hash common data structures to book3s64 headers")
    15b1624b7807 ("powerpc: Use defines for __init_tlb_power[78]")
    18569c1f134e ("powerpc/64: Don't try to use radix MMU under a hypervisor")
    1a01dc87e09b ("powerpc/mm: Add mmu_early_init_devtree()")
    26b6a3d9bb48 ("powerpc/mm: move pte headers to book3s directory")
    2bfd65e45e87 ("powerpc/mm/radix: Add radix callbacks for early init routines")
    3dfcb315d81e ("powerpc/mm: make a separate copy for book3s")
    5c3c7ede2bdc ("powerpc/mm: Split hash page table sizing heuristic into a helper")
    756d08d1ba16 ("powerpc/mm: Abstract early MMU init in preparation for radix")
    b275bfb26963 ("powerpc/mm/radix: Add a kernel command line to disable radix")
    b584c2544041 ("powerpc/vmemmap: Add altmap support")
    c3ab300ea555 ("powerpc: Add POWER9 cputable entry")
    c610ec60ed63 ("powerpc/mm: Move disable_radix handling into mmu_early_init_devtree()")
    da024512a1fa ("mm: pass the vmem_altmap to arch_remove_memory and __remove_pages")
    f64e8084c94b ("powerpc/mm: Move hash related mmu-*.h headers to book3s/")
    fb52bbaee598 ("mm: move is_pageblock_removable_nolock() to mm/memory_hotplug.c")


How should we proceed with this patch?

--
Thanks,
Sasha

