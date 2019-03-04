Return-Path: <SRS0=F7ZL=RH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_NEOMUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AC7D9C43381
	for <linux-mm@archiver.kernel.org>; Mon,  4 Mar 2019 08:19:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6BE0B20863
	for <linux-mm@archiver.kernel.org>; Mon,  4 Mar 2019 08:19:24 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="l/VKjl5b"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6BE0B20863
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 07EDE8E0004; Mon,  4 Mar 2019 03:19:24 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 02DA28E0001; Mon,  4 Mar 2019 03:19:23 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E11958E0004; Mon,  4 Mar 2019 03:19:23 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f200.google.com (mail-lj1-f200.google.com [209.85.208.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7292A8E0001
	for <linux-mm@kvack.org>; Mon,  4 Mar 2019 03:19:23 -0500 (EST)
Received: by mail-lj1-f200.google.com with SMTP id x16so911605ljb.15
        for <linux-mm@kvack.org>; Mon, 04 Mar 2019 00:19:23 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=WmNWNx1ySeryfAiTC7nsxWTTEIzxK5H5BDemAWXAwzo=;
        b=sWVA+7ykwPnqpYx6DHB3ryse/CyogwSsRvXOpfD542DWLfQ+XguzWjpbF2u+rQByJQ
         KHQMWt9nzSRa/q7GKvw9rLNBsS+K3uvayazjVhdH8odA/6CH/BVpXOo/3OTZ9Yof+XLr
         mjYWvVaeGQjVYVRGITzRsdyJGaek9UnIEaPXLjo9qjgdjCzVmUQZZOtvaZDdLiY2zqhW
         rh4VAW+rlRI5nkYROwOgE4lPfZ4HLZhQ4otpdTD9R7wxP6vpab6Y30TOQEIZAckPdz38
         ZsH9di5jVEQHmoKp2fORlLTPMiZg49vEZyP05YeigL62UggIEKd98EDsOJWtic1xuexm
         xIwA==
X-Gm-Message-State: APjAAAW8iyKDirTbr5pcD4OH047Nm3JtKO6PPditViboZ8iM95W7+AMb
	P61Q+mqVbPOFd9JjN7uPmBdKyzp0j3ggcC4l3X0VHRoLmhBBbNRDqpfTdMF1cXdZxy56G7xWgC3
	4pfffxY4vJ8SjfX4D7kmFHvSswygyxgIrcMJ10m7QCPCe2BVpD3AmZdwzbWOpbYPBrbp7sqSR/i
	GftFvskoADN5UrORuMq3VKXLMCtfUflWGjrcmMV06NB2XqkG11sZ+c9ytEqXzmLIVHUCzlcvnhL
	yKb5fD3JLT0R+HyErImCL5NptI3FBYo+ss5EURPDflneWNOWlBZXbve7VLaKXKxvcZT5HfR0aXK
	PSYzXLchDjITOcpFmXG50f1tTxgYFq4vZIOV5H1UTdce5khUCHvnC/CW0nUNAu9QbIfvi/xQ6Ug
	A
X-Received: by 2002:a2e:9a8b:: with SMTP id p11mr9814474lji.66.1551687562654;
        Mon, 04 Mar 2019 00:19:22 -0800 (PST)
X-Received: by 2002:a2e:9a8b:: with SMTP id p11mr9814442lji.66.1551687561625;
        Mon, 04 Mar 2019 00:19:21 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551687561; cv=none;
        d=google.com; s=arc-20160816;
        b=N1TxoHXaBZL3P24/yJ4tc/vii2mRgBHKxUd1kA1E5wuW2QdvEwTnH4TcZMhYvmYar8
         PWZWY4BLP+J753Q1iQk/xLAqe5VU0ovuOpUeRwEEPyBj+CGV3wmr07d53HpMMlRkC6FP
         3QDfq6GFwS7ebsLg6t58IMskkgegQSLVXC6t7gker1LnSkKFjjO+IO8FMJzUrj+8uJIS
         FFjvKXOu9IgBnkiwpGxJ+UJH+p+SOw0fGgbce5JL7HU0AaEm9O7A/FdL5hiVasmI3Gz5
         +BED4De9cCXTLQE9bKedCh0OeeSDFSBG5vrDEzZwhTZGiUVoxjhJ82+czvfMqUNd2gYZ
         dxqg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=WmNWNx1ySeryfAiTC7nsxWTTEIzxK5H5BDemAWXAwzo=;
        b=XQ4y+uzrhNwtHWiNW2Z0x4oNQAZTLdD1O/gJWwb5ULDhvHeD1NuJHesEln3VxLXeZu
         hMP/cfghTJHololNWQEMrQulkb730m1qJo0ZDXwPm3PV+Z4iKjhubMfrxROr5Tpuf3yA
         mclO+3J92CsQzU7+3NneSNkd941EIDiFie57Jlfoc8GDJ4yxMs6PQrTQu6Ywr7sqChWR
         dqGzHI+hbxTXynAp2b0VFldQKP2NMj/TtPMicB1uDTONC0xwAYnMOAy8Xl+W1d1F+Vxh
         CtM5VALA9hfpnAijhjrsgufpx0MRGC4praIDTdOQnLdWBVuJyCJrD9PCJceWrqn/S09I
         LlbQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b="l/VKjl5b";
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z14sor956502lfj.62.2019.03.04.00.19.21
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 04 Mar 2019 00:19:21 -0800 (PST)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b="l/VKjl5b";
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=WmNWNx1ySeryfAiTC7nsxWTTEIzxK5H5BDemAWXAwzo=;
        b=l/VKjl5b23njYyAzEe09qekKA+RlAwEsIYnGsfJn3nNoGpnfcYbol39NQJj7XC9/JU
         JtVDDmbrjadDfawxx2TfqKSTDXfHkwAW8LDG2JGzjoyofIjLTKWGsO7xS8VCqQeQf3iD
         O8WR/kKsYi9HbIr4qLrDxAiXTAAXNXeqw3avrUYKujwT6b1Xwh+pyup/nS6mpla6vKOa
         tXLqPekRpOmVAV60LJckMDfUyipTz9rR7rWzTDnLmFqxFyHq6dHhxeDpnoRLJsTB/4af
         5Be7BlyE+BWCJlcStNCIAmvrR8WDSwFto/QisIW7qQ1WyqlVHodhMC2IegOqe8/VFvg2
         7DUg==
X-Google-Smtp-Source: APXvYqw/IVd57815JEYjo5mbLCVARTCNsm8OSH2lJnZkM1s5xEfunSdzCKm0b22DHcHpWA/wjGpcMg==
X-Received: by 2002:a19:ca46:: with SMTP id h6mr8042457lfj.142.1551687561118;
        Mon, 04 Mar 2019 00:19:21 -0800 (PST)
Received: from kshutemo-mobl1.localdomain (mm-159-97-122-178.mgts.dynamic.pppoe.byfly.by. [178.122.97.159])
        by smtp.gmail.com with ESMTPSA id d26sm1389830ljc.15.2019.03.04.00.19.20
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Mar 2019 00:19:20 -0800 (PST)
Received: by kshutemo-mobl1.localdomain (Postfix, from userid 1000)
	id 441613007CD; Mon,  4 Mar 2019 11:19:19 +0300 (+03)
Date: Mon, 4 Mar 2019 11:19:19 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
To: Jan Stancek <jstancek@redhat.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, willy@infradead.org,
	peterz@infradead.org, riel@surriel.com, mhocko@suse.com,
	ying.huang@intel.com, jrdr.linux@gmail.com, jglisse@redhat.com,
	aneesh.kumar@linux.ibm.com, david@redhat.com, aarcange@redhat.com,
	raquini@redhat.com, rientjes@google.com,
	mgorman@techsingularity.net, linux-kernel@vger.kernel.org
Subject: Re: [PATCH v3] mm/memory.c: do_fault: avoid usage of stale
 vm_area_struct
Message-ID: <20190304081918.rrhyhyze237bpkqf@kshutemo-mobl1>
References: <20190302185144.GD31083@redhat.com>
 <5b3fdf19e2a5be460a384b936f5b56e13733f1b8.1551595137.git.jstancek@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5b3fdf19e2a5be460a384b936f5b56e13733f1b8.1551595137.git.jstancek@redhat.com>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Mar 03, 2019 at 08:28:04AM +0100, Jan Stancek wrote:
> LTP testcase mtest06 [1] can trigger a crash on s390x running 5.0.0-rc8.
> This is a stress test, where one thread mmaps/writes/munmaps memory area
> and other thread is trying to read from it:
> 
>   CPU: 0 PID: 2611 Comm: mmap1 Not tainted 5.0.0-rc8+ #51
>   Hardware name: IBM 2964 N63 400 (z/VM 6.4.0)
>   Krnl PSW : 0404e00180000000 00000000001ac8d8 (__lock_acquire+0x7/0x7a8)
>   Call Trace:
>   ([<0000000000000000>]           (null))
>    [<00000000001adae4>] lock_acquire+0xec/0x258
>    [<000000000080d1ac>] _raw_spin_lock_bh+0x5c/0x98
>    [<000000000012a780>] page_table_free+0x48/0x1a8
>    [<00000000002f6e54>] do_fault+0xdc/0x670
>    [<00000000002fadae>] __handle_mm_fault+0x416/0x5f0
>    [<00000000002fb138>] handle_mm_fault+0x1b0/0x320
>    [<00000000001248cc>] do_dat_exception+0x19c/0x2c8
>    [<000000000080e5ee>] pgm_check_handler+0x19e/0x200
> 
> page_table_free() is called with NULL mm parameter, but because
> "0" is a valid address on s390 (see S390_lowcore), it keeps
> going until it eventually crashes in lockdep's lock_acquire.
> This crash is reproducible at least since 4.14.
> 
> Problem is that "vmf->vma" used in do_fault() can become stale.
> Because mmap_sem may be released, other threads can come in,
> call munmap() and cause "vma" be returned to kmem cache, and
> get zeroed/re-initialized and re-used:
> 
> handle_mm_fault                           |
>   __handle_mm_fault                       |
>     do_fault                              |
>       vma = vmf->vma                      |
>       do_read_fault                       |
>         __do_fault                        |
>           vma->vm_ops->fault(vmf);        |
>             mmap_sem is released          |
>                                           |
>                                           | do_munmap()
>                                           |   remove_vma_list()
>                                           |     remove_vma()
>                                           |       vm_area_free()
>                                           |         # vma is released
>                                           | ...
>                                           | # same vma is allocated
>                                           | # from kmem cache
>                                           | do_mmap()
>                                           |   vm_area_alloc()
>                                           |     memset(vma, 0, ...)
>                                           |
>       pte_free(vma->vm_mm, ...);          |
>         page_table_free                   |
>           spin_lock_bh(&mm->context.lock);|
>             <crash>                       |
> 
> Cache mm_struct to avoid using potentially stale "vma".
> 
> [1] https://github.com/linux-test-project/ltp/blob/master/testcases/kernel/mem/mtest06/mmap1.c
> 
> Signed-off-by: Jan Stancek <jstancek@redhat.com>
> Reviewed-by: Andrea Arcangeli <aarcange@redhat.com>

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

-- 
 Kirill A. Shutemov

