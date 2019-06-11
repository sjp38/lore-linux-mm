Return-Path: <SRS0=/KmR=UK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	T_DKIMWL_WL_HIGH autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 767F7C31E46
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 22:19:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0C12E20874
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 22:19:11 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="MmAm/Rlq"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0C12E20874
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 635E56B000D; Tue, 11 Jun 2019 18:19:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5E7696B000E; Tue, 11 Jun 2019 18:19:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4ADEB6B0010; Tue, 11 Jun 2019 18:19:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 173266B000D
	for <linux-mm@kvack.org>; Tue, 11 Jun 2019 18:19:11 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id f10so4958391plr.17
        for <linux-mm@kvack.org>; Tue, 11 Jun 2019 15:19:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=f+/TMOqBnpdI4SrKtluTIqBhu1SEbeCSvLFRdRIaWAo=;
        b=AaMX2LQ3cEelB48cmgMKMSl72ceePaXjqmWZdafGQY3AYZ4CDB/LFQAVSnUQLLdNBO
         tFnHz/fp0MDeUZe220mu871kIAMorYBTDgNX3aueJ06BmqDoqBiDfioFBjlb7cl0tUw9
         rwf/mlbn4p5MNbL84gknGpdqkbAYe8uuvFuYjZ9zfz/TdOV4GbLFCzszTGHREmS1rF2Q
         SBbFwhl7Dp4ecxVAn64poKbf7HjT4qpW+ONs8jIwO1Wl6DM9A2PqUUzOOPvNGQTp0NM1
         N0QoA59xudCdKuRNLTXIUG9YFfny9laBPFLx+BXmjBXdGF0IrUUExbGy1E4XleRWu0vD
         4G7w==
X-Gm-Message-State: APjAAAV/i2ulBQ/gHAn0GssJ7X2yO6CLbSrofCWWhSQTUIKvCp3Pmdpq
	OPINsrPAJPdEC3hWCBvGA0DXhUY0Oi1AvyR1SKbLdMwreF5Xghta5E8NzvvB01nQu8jHelseE5A
	d9zuucaDNaiChKMxchBbFTCHslQzW/moLk8KTmw4+grxa3W0wvTutV2mb75PNAkXTrA==
X-Received: by 2002:a63:e603:: with SMTP id g3mr22753468pgh.167.1560291550600;
        Tue, 11 Jun 2019 15:19:10 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwWDla7FbHbeoN9hkmQoDOa09QDJG1j0eOUrzHBmR+m4GKosI27yRSWD6mB81HTli+FyYBg
X-Received: by 2002:a63:e603:: with SMTP id g3mr22753405pgh.167.1560291549540;
        Tue, 11 Jun 2019 15:19:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560291549; cv=none;
        d=google.com; s=arc-20160816;
        b=0ydtSyhmSia10RZDFaAr6IOIZcfqmgDlVPyGK3RoOm7oKif+7lMRSf9N7idY46DyuY
         yPwL0zTEz92A/Pva9aqpPmO/Q89UZNYWvgANl9HtQRbWkVpArB0Bc6OzL8j1qfwc3nVo
         ZR9QK65O11gDVyZuQGfUXydVBCCHSG3mSGgrqIbZ3qvEoBa3B8NRQzOdPkGa9wI+ItGw
         61gFBSIhAi2a9A1ovMGQIB70X8/zjCEaKPmJ2J+VSwIRNEYyU4gyVbG3mAY+4sMmvKVb
         ZZhKxuDKAyr9eReFw9B7XIqKwsStzu4Y8eLqDv15h0RH8bGX/Lllkg4v7b65FGept9mU
         PWBA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=f+/TMOqBnpdI4SrKtluTIqBhu1SEbeCSvLFRdRIaWAo=;
        b=i6YdL8rwOtB1FDBAqKncS0zuR4RM+RajOUyEGCvJ2hQ3om6QSa+wcecmr2j9tWjp5q
         pg83zSkzNqdZKcZrSjZBNodRN1mqt657atWauoCfNUA2CcWhD1q40uWehQSJN76Wfqnz
         vGY7lyXZcO3SqAVmbUq1PFA0OWBeW2+N/B1SgcirV3MoTYo4RZDQXxQEhYyCpezqNp/c
         A3jcgy8Scjw/V/WVZmhvhtyKzGEz0EgQEO8I5S6lKOw7JgKqiPMjOwq+0G7Bul/b2aQN
         +6TfpFGwVJEeZEdlgi5tVIrBAzmc5XilWg526XfdKWZmvWI2vpt5vPPrDQiwhYHK0uIk
         tp0g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b="MmAm/Rlq";
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id o3si13283785plk.167.2019.06.11.15.19.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Jun 2019 15:19:09 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b="MmAm/Rlq";
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from akpm3.svl.corp.google.com (unknown [104.133.8.65])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id AE6802086D;
	Tue, 11 Jun 2019 22:19:08 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1560291549;
	bh=JRnontjDmVMLabiF6n7OXpnQaHOmJ0mPnBv9JJmBYHQ=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=MmAm/Rlq9xHW4QftY68w195BiVipJj7BtYU46+bxK1b6KmlDNAfwO9DhQg05xARCu
	 FEqfWAw+qoktRhbWY3KD/8J8BYYdnL1bEpW3I++EHV7Ci44iqPz0amWpf/bVcshNmA
	 +PpL5Jv9DPHAHQwerlof7S5AdLJlA4FWjEP1NbEs=
Date: Tue, 11 Jun 2019 15:19:08 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Anshuman Khandual <anshuman.khandual@arm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
 linux-arm-kernel@lists.infradead.org, catalin.marinas@arm.com,
 will.deacon@arm.com, ard.biesheuvel@arm.com, osalvador@suse.de,
 david@redhat.com, mhocko@suse.com, mark.rutland@arm.com
Subject: Re: [PATCH V5 - Rebased] mm/hotplug: Reorder
 memblock_[free|remove]() calls in try_remove_memory()
Message-Id: <20190611151908.cdd6b73fd17fda09b1b3b65b@linux-foundation.org>
In-Reply-To: <1560252373-3230-1-git-send-email-anshuman.khandual@arm.com>
References: <36e0126f-e2d1-239c-71f3-91125a49e019@redhat.com>
	<1560252373-3230-1-git-send-email-anshuman.khandual@arm.com>
X-Mailer: Sylpheed 3.7.0 (GTK+ 2.24.32; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 11 Jun 2019 16:56:13 +0530 Anshuman Khandual <anshuman.khandual@arm.com> wrote:

> Memory hot remove uses get_nid_for_pfn() while tearing down linked sysfs
> entries between memory block and node. It first checks pfn validity with
> pfn_valid_within() before fetching nid. With CONFIG_HOLES_IN_ZONE config
> (arm64 has this enabled) pfn_valid_within() calls pfn_valid().
> 
> pfn_valid() is an arch implementation on arm64 (CONFIG_HAVE_ARCH_PFN_VALID)
> which scans all mapped memblock regions with memblock_is_map_memory(). This
> creates a problem in memory hot remove path which has already removed given
> memory range from memory block with memblock_[remove|free] before arriving
> at unregister_mem_sect_under_nodes(). Hence get_nid_for_pfn() returns -1
> skipping subsequent sysfs_remove_link() calls leaving node <-> memory block
> sysfs entries as is. Subsequent memory add operation hits BUG_ON() because
> of existing sysfs entries.
> 
> [   62.007176] NUMA: Unknown node for memory at 0x680000000, assuming node 0
> [   62.052517] ------------[ cut here ]------------
> [   62.053211] kernel BUG at mm/memory_hotplug.c:1143!
> [   62.053868] Internal error: Oops - BUG: 0 [#1] PREEMPT SMP
> [   62.054589] Modules linked in:
> [   62.054999] CPU: 19 PID: 3275 Comm: bash Not tainted 5.1.0-rc2-00004-g28cea40b2683 #41
> [   62.056274] Hardware name: linux,dummy-virt (DT)
> [   62.057166] pstate: 40400005 (nZcv daif +PAN -UAO)
> [   62.058083] pc : add_memory_resource+0x1cc/0x1d8
> [   62.058961] lr : add_memory_resource+0x10c/0x1d8
> [   62.059842] sp : ffff0000168b3ce0
> [   62.060477] x29: ffff0000168b3ce0 x28: ffff8005db546c00
> [   62.061501] x27: 0000000000000000 x26: 0000000000000000
> [   62.062509] x25: ffff0000111ef000 x24: ffff0000111ef5d0
> [   62.063520] x23: 0000000000000000 x22: 00000006bfffffff
> [   62.064540] x21: 00000000ffffffef x20: 00000000006c0000
> [   62.065558] x19: 0000000000680000 x18: 0000000000000024
> [   62.066566] x17: 0000000000000000 x16: 0000000000000000
> [   62.067579] x15: ffffffffffffffff x14: ffff8005e412e890
> [   62.068588] x13: ffff8005d6b105d8 x12: 0000000000000000
> [   62.069610] x11: ffff8005d6b10490 x10: 0000000000000040
> [   62.070615] x9 : ffff8005e412e898 x8 : ffff8005e412e890
> [   62.071631] x7 : ffff8005d6b105d8 x6 : ffff8005db546c00
> [   62.072640] x5 : 0000000000000001 x4 : 0000000000000002
> [   62.073654] x3 : ffff8005d7049480 x2 : 0000000000000002
> [   62.074666] x1 : 0000000000000003 x0 : 00000000ffffffef
> [   62.075685] Process bash (pid: 3275, stack limit = 0x00000000d754280f)
> [   62.076930] Call trace:
> [   62.077411]  add_memory_resource+0x1cc/0x1d8
> [   62.078227]  __add_memory+0x70/0xa8
> [   62.078901]  probe_store+0xa4/0xc8
> [   62.079561]  dev_attr_store+0x18/0x28
> [   62.080270]  sysfs_kf_write+0x40/0x58
> [   62.080992]  kernfs_fop_write+0xcc/0x1d8
> [   62.081744]  __vfs_write+0x18/0x40
> [   62.082400]  vfs_write+0xa4/0x1b0
> [   62.083037]  ksys_write+0x5c/0xc0
> [   62.083681]  __arm64_sys_write+0x18/0x20
> [   62.084432]  el0_svc_handler+0x88/0x100
> [   62.085177]  el0_svc+0x8/0xc

This seems like a serious problem.  Once which should be fixed in 5.2
and perhaps the various -stable kernels as well.

> Re-ordering memblock_[free|remove]() with arch_remove_memory() solves the
> problem on arm64 as pfn_valid() behaves correctly and returns positive
> as memblock for the address range still exists. arch_remove_memory()
> removes applicable memory sections from zone with __remove_pages() and
> tears down kernel linear mapping. Removing memblock regions afterwards
> is safe because there is no other memblock (bootmem) allocator user that
> late. So nobody is going to allocate from the removed range just to blow
> up later. Also nobody should be using the bootmem allocated range else
> we wouldn't allow to remove it. So reordering is indeed safe.
> 
> ...
>
> 
> - Rebased on linux-next (next-20190611)

Yet the patch you've prepared is designed for 5.3.  Was that
deliberate, or should we be targeting earlier kernels?


